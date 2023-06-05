import Web3 from "web3"
import { type Account, type EncryptedKeystoreV3Json} from 'web3-core';
import { type AbiItem } from 'web3-utils';
import { saveAs } from 'file-saver'
import { ElMessage } from 'element-plus'
import { abi } from "../../truffle/build/contracts/EquipShare.json" 

interface Aktpact {
	address : string
	keystore: EncryptedKeystoreV3Json
	token   : EncryptedKeystoreV3Json 
}

// Web3.givenProvider 可由 meta mask 提供 || 测试网 https://infura.io/dashboard || 本地私有链
export const web3 = new Web3("HTTP://127.0.0.1:8545")

export const contractAddress = "0xc58021244625d1aBA7dF6CfE1Fa12D7F79fa9a6d"

export const contract = new web3.eth.Contract(abi as AbiItem[], contractAddress)
 
/**
 * 描述：用户输入的密码，创建一个以太坊账号，并下载 KeyStore 文件
 * @param {*} password 
*/
export const createAccount = (password: string) => { 
	const account = web3.eth.accounts.create()  
	importKeyStore(account.privateKey, password)
	exportKeyStore(account.privateKey, password) 
	return account
}
/**
 * 描述：1.从自动解密浏览器缓存数据返回以太坊账号  
 * 2.或通过私钥和密码返回账号信息，并存入浏览器
 * @param {String} privateKey 用户私钥
 * @param {String} password 用户密码 
 */
export const getAccount = (index = 0, privateKey: string = "", password: string = "") => {
	let account: Account
	try {
		if (privateKey && password) {
			// 将私钥和密码加密后存入浏览器
			account = web3.eth.accounts.privateKeyToAccount(privateKey)
			importKeyStore(privateKey, password)
		} else if (privateKey) {
			// 未输入密码直接返回账号
			account = web3.eth.accounts.privateKeyToAccount(privateKey)
		} else {
			// 从浏览器读取并解密出 privateKey 和 password 
			account = readKeyStore(index) 
		}
		return account
	} catch (err) {
		ElMessage.error("登录失败，密码过期")
		console.error(err.message)
	}
}
 
/** 
 * @returns 含所有以太坊地址的列表
 */
export const getAddressLst = () => {
	const aktstr = localStorage.AKTPACTS
	if (aktstr) {
		const aktpacts:  Aktpact[] = JSON.parse(aktstr)
		const addresslst: string[] = []
		for (const item of aktpacts) {
			addresslst.push(item.address)
		}
		return addresslst
	} else {
		return null
	} 
}
/**
 * 描述：1.从自动解密浏览器缓存的 KEYPAIR 返回以太坊账号  
 * 2.或通过私钥和密码返回账号信息，并存入浏览器
 * @param {String} keystore  
 * @param {String} password 解密密码 
 */
export const getAccountByKeyStore = (keystore: EncryptedKeystoreV3Json, password: string) => {

	const account = web3.eth.accounts.decrypt(keystore, password)

	// 将成对的私钥和密码加密后存入浏览器
	importKeyStore(account.privateKey, password)

	if (!web3.utils.isAddress(account.address)) {
		throw "无效地址，因为 KeyStore 密码错误"
	}
	return account
}
/**
 * 描述：输入私钥、密码后下载 keyStore 文件
 * @param {*} privateKey 
 * @param {*} password 
 */
export const exportKeyStore = (privateKey: string, password: string) => {
	const account = web3.eth.accounts.privateKeyToAccount(privateKey)
	const fileName = account.address.slice(0, 6) + "..." + account.address.slice(-4)

	const keystore = JSON.stringify(web3.eth.accounts.encrypt(privateKey, password))
	var blob = new Blob([keystore], { type: "text/plain;charset=utf-8" });

	saveAs(blob, `KeyStore...${fileName.toUpperCase()}.json`);
}
/**
 * 描述：将 `KeyStore` 和 `对应Token` 存入浏览器
 * @param {String} privateKey 用户私钥
 * @param {String} password 用户密码 
 */
export const importKeyStore = (privateKey: string | object, password: string) => {
	let account: Account
	let keystore: EncryptedKeystoreV3Json
	if (typeof privateKey == "string") {
		keystore = web3.eth.accounts.encrypt(privateKey, password)
		account = web3.eth.accounts.privateKeyToAccount(privateKey)
	} else {
		keystore = privateKey as EncryptedKeystoreV3Json
		account = web3.eth.accounts.decrypt(keystore, password)
	}
	const token    = savePwdtoToken(password) 
	const aktpact: Aktpact = { keystore, token, address: account.address }
	
	const str = localStorage.AKTPACTS
	if (str) {
		const aktpacts: Aktpact[] = JSON.parse(str)
		for (const i in aktpacts) {
			if (aktpacts[i].address == aktpact.address) {
				aktpacts[i] = aktpact
				localStorage.AKTPACTS = JSON.stringify(aktpacts)
				return false
			}
		}
		aktpacts.push(aktpact)
		localStorage.AKTPACTS = JSON.stringify(aktpacts)
		return true
	} else {
		localStorage.AKTPACTS = JSON.stringify([aktpact])
		return true
	} 
}

const readKeyStore = (index = 0) => {
	// 从浏览器读取并解密出 privateKey 和 password
	const aktstr = localStorage.AKTPACTS
	if (aktstr) {
		const aktpacts: Aktpact[] = JSON.parse(aktstr)
		const keystore = aktpacts[index].keystore
		const password = getPwdFromToken(aktpacts[index].token) 
		return web3.eth.accounts.decrypt(keystore, password)
	} else {
		console.error("本地无私钥，请输入私钥")
	}
} 
/**
 * 描述：将用户密码加密成当天有效的 token  
 * 此处为方便开发，设计简易且不不安全
 * @param {*} password 
 * @returns token: EncryptedKeystoreV3Json   
 */ 
const savePwdtoToken = (password: string) => {
	const timestamp = new Date()
	timestamp.setHours(0, 0, 0, 0)

	const token = web3.eth.accounts.encrypt(web3.utils.utf8ToHex(password), timestamp.getTime().toString())

	return token
}
/**
 * 描述：将 token 解密成用户密码
 * @param {*} token: EncryptedKeystoreV3Json
 * @returns 用户密码: string
 */
const getPwdFromToken = (token: EncryptedKeystoreV3Json) => {
	const timestamp = new Date()
	timestamp.setHours(0, 0, 0, 0)

	const account = web3.eth.accounts.decrypt(token, timestamp.getTime().toString()) 

	return web3.utils.hexToUtf8(account.privateKey)
}

