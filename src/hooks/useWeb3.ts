import { ElMessage } from 'element-plus'
import { web3, contract, contractAddress } from "./account"  
import { type Equipment, type User } from '@/stores/datatype'

// #region 数据预处理内核     

const AsyncFunction = Object.getPrototypeOf(async function() {}).constructor
/**
 * @param {*} error 以太坊错误 VM Exception while processing transaction revert
 * @returns 经处理后的文本
 */
export const revertErrorFilter = (error) => {
	console.error(error)
	try {
		return error.message.match(/revert\s+(.*)/i)[1]
	} catch {
		return error.message.split(':')[1]  
	}
}
/**
 * 
 * @param {*} obj 来自以太坊的原始类型: User | Equipment | LeasePact
 * @returns 符合规范的数据类型: User | Equipment | LeasePact
 */
const dataPreprocess = (obj) => {
	// 用于处理以太坊返回的 obj
	const newobj = {}
	for (let i in obj) {
		if (isNaN(Number(i))) {
			newobj[i] = obj[i]
		}
	} 
	if (obj.deposit) {
		// 对设备附加状态属性
		initEquipment(newobj)
	}
	return newobj
}

const initEquipment = (equipment) => { 
	if (equipment.occupyPeriod && equipment.occupyPeriod[0]) {
		switch(Number(equipment.occupyPeriod[0].occupyType)) {
			case 1: return equipment.occupytype = 1  // 占用
			case 2: return equipment.occupytype = 2  // 维修
			case 3: return equipment.occupytype = 3  // 冻结
		} 
	} else {
		return equipment.occupytype = 0
	}
}
/**
 * 
 * @param {*} methodName Solidity 函数名
 * @param  {...any} params Solidity 函数参数
 * @returns Solidity 函数返回值
 */
const contractMethodCall = async (methodName: string, ...params) => {
	// https://blog.csdn.net/z1832729975/article/details/102148778 
	const func = new AsyncFunction(
		'contract', 'ElMessage', 'from', 'revertErrorFilter', '...params',
		`return await contract.methods.${methodName}(...params)
		.call(from)
		.catch((err) => {
			ElMessage.error(revertErrorFilter(err))
		})
	`)  
	if(!globalThis.$ADDRESS) return 

	const origin = await func(
		contract, ElMessage, { from: globalThis.$ADDRESS }, revertErrorFilter, ...params
	)
	 
	if (origin && typeof origin != "object") {
		return origin
	} 
	else if (origin && typeof origin[0] == "object") {  
		const data = []  
		for (let i in origin) data[i] = dataPreprocess(origin[i]) 
		return data
	} 
	else if (origin && typeof origin[0] == "string") { 
		return dataPreprocess(origin)
	}  

}
/**
 * 描述：发送私钥签名的交易  
 * 此函数内部从浏览器缓存中自动解密出私钥以签名
 * @param {*} func 智能合约执行函数的ABI
 * @param {*} to 默认为合约地址
 */
const contractMethodSend = async (
	func: any,
	message = true, 
	to: string = contractAddress
) => {
	
	try {
		const data = func.encodeABI()
		if (!globalThis.$ACCOUNT) {
			console.log("无账号信息")
			return
		}
		const privateKey = globalThis.$ACCOUNT.privateKey
		const from = globalThis.$ACCOUNT.address

		const gasPrice = await web3.eth.getGasPrice()
		const gas = await web3.eth.estimateGas({ from, to, data }) 
		const nonce = await web3.eth.getTransactionCount(from, 'pending')
		const tx = { from, to, data, gasPrice, nonce, gas }
		const signedTx = await web3.eth.accounts.signTransaction(tx, privateKey)

		await web3.eth.sendSignedTransaction(signedTx.rawTransaction)
			.on('transactionHash', (hash) => {
				console.log(`Transaction hash: ${hash}\n`)
			})
			.on('receipt', (receipt) => {
				// console.log(`from: ${receipt.from}`)
				// console.log(`to: ${receipt.to}`)
				// console.log(`gasUsed: ${receipt.gasUsed}`)
			})
			.on('error', (err) => { 
				console.log(err.name + ": " + err.message)
			}) 
		return true

	} catch (error) { 
		if (message) {
			ElMessage.error(error.name + ": " + revertErrorFilter(error))
		}
		console.log(error) 
		return false
	}
}
// #endregion 




// #region ////////////////////  用户 API

export const getUser = async (num) => { 
	try {
		if (web3.utils.isAddress(num)) {
			return await contract.methods.getUser(num).call() as User
			// return await contractMethodCall("getUser", num) as User
		} else {
			return await contract.methods.getUserByID(num).call() as User
			// return await contractMethodCall("getUserByID", num) as User
		}
	} catch (error) {
		console.error(error)
	}

}

export const getUserAll = async () => {
	return await contractMethodCall("getUserAll") 
}

export const addUser = async (args) => {
	let data  
	if (args.addres && web3.utils.isAddress(args.addres)) {
		data = contract.methods.addUser(
			args.addres, args.name, args.avatar, args.email, args.tellphone, args.organization
		)
	} else {
		data = contract.methods.addUser(
			args.name, args.avatar, args.email, args.tellphone, args.organization
		)
	}
	return await contractMethodSend(data)
}
/**
 * 静默添加用户实体
 * @param args 用户信息: User
 */
export const addUserSilent = async (args) => {
	let data  
	if (args.addres && web3.utils.isAddress(args.addres)) {
		data = contract.methods.addUser(
			args.addres, args.name, args.avatar, args.email, args.tellphone, args.organization
		)
	} else {
		data = contract.methods.addUser(
			args.name, args.avatar, args.email, args.tellphone, args.organization
		)
	}
	try {
		return await contractMethodSend(data, false)
	} catch (error) {
		console.log(error, "dddd");
	} 
}
export const updateUser = async (args) => {
	let data
	console.log(args.addres, "cee");
	
	if (args.addres && web3.utils.isAddress(args.addres)) {
		data = contract.methods.updateUser(
			args.addres,
			args.name,
			args.avatar,
			args.email,
			args.tellphone,
			args.organization,
		)
	} else {
		data = contract.methods.updateUser(
			args.name,
			args.avatar,
			args.email,
			args.tellphone,
			args.organization
		)
	}
	return await contractMethodSend(data)
}
export const updateSelfUser = async (args) => {
	const data = contract.methods.updateUser(
			args.name,
			args.avatar,
			args.email,
			args.tellphone,
			args.organization
		)
	 
	return await contractMethodSend(data)
}
export const getBalance = async (address) => { 
	return await contractMethodCall("balanceOf", address) 
}
//#endregion //////////////////// 用户 API 


// #region //////////////////// 设备 API
export const getEquipment = async (equipmentId) => {
	return await contractMethodCall("getEquipment", equipmentId) as Equipment
} 
  
export const getEquipmentOwned = async () => {
	return await contractMethodCall("getEquipmentOwned", globalThis.$ADDRESS)
}

export const getEquipmentRented = async () => {
	return await contractMethodCall("getEquipmentRented", globalThis.$ADDRESS)
}

export const getEquipmentAll = async () => {
	return await contractMethodCall("getEquipmentAll")
}
/**
 * 
 * @param {*} equipmentId 
 * @param {*} startTime UNIX 时间戳(秒)
 * @param {*} endTime UNIX 时间戳(秒)
 * @returns 
 */
export const queryEquipAvailable = async (equipmentId, startTime, endTime) => {
	return await contractMethodCall("queryEquipAvailable", equipmentId, startTime, endTime)
}

export const addEquipment = async (args) => {
	let data
	if (args.owner) {
		data = contract.methods.addEquipment(
			args.owner,
			args.name,
			args.category,
			args.descLink,
			args.imagesLink,
			args.deposit,
			args.unitPrice
		)
	} else {
		data = contract.methods.addEquipment(
			args.name,
			args.category,
			args.descLink,
			args.imagesLink,
			args.deposit,
			args.unitPrice
		)
	}
	return await contractMethodSend(data)
}

export const removeEquipment = async (equipmentId) => {
	const data = contract.methods.removeEquipment(equipmentId)
	return await contractMethodSend(data)
}

export const updateEquipment = async (args) => {
	const data = contract.methods.updateEquipment(
		args.id,
		args.name,
		args.category,
		args.descLink,
		args.imagesLink,
		args.deposit,
		args.unitPrice
	)
	return await contractMethodSend(data)
}

export const maintainEquipment = async (equipmentId, startTime, endTime) => {
	const data = contract.methods.maintainEquipment(equipmentId, startTime, endTime)
	return await contractMethodSend(data)
}

export const endMaintainEquipment = async (equipmentId) => {
	const data = contract.methods.endMaintainEquipment(equipmentId)
	return await contractMethodSend(data)
}

export const freezeEquipment = async (equipmentId) => {
	const data = contract.methods.freezeEquipment(equipmentId)
	return await contractMethodSend(data)
}

export const scheduleFreezeEquipment = async (equipmentId, startTime) => {
	const data = contract.methods.scheduleFreezeEquipment(equipmentId, startTime)
	return await contractMethodSend(data)
}

export const unfreezeEquipment = async (equipmentId) => {
	const data = contract.methods.unfreezeEquipment(equipmentId)
	return await contractMethodSend(data)
}
// #endregion //////////////////// 设备 API




// #region //////////////////// 合同 API
export const getLeasePact = async (leaseId) => {
	let data
	if (leaseId) {
		data = await contract.methods.getLeasePact(leaseId).call()
	} else {
		data = await contract.methods.getLeasePact().call()
	}
	return data
}

export const getLeasePactOwned = async () => { 
	return await contractMethodCall("getLeasePactOwned", globalThis.$ADDRESS)
}

export const getLeasePactRented = async () => { 
	return await contractMethodCall("getLeasePactRented", globalThis.$ADDRESS)
}

export const getLeasePactAll = async () => {
	return await contractMethodCall("getLeasePactAll")
}

export const createLeasePact = async (equipmentId, startTime, endTime) => {
	const data = contract.methods.reserveEquipment(equipmentId, startTime, endTime)
	
	return await contractMethodSend(data)
}

export const cancelLeasePact = async (leaseId) => {
	const data = contract.methods.reserveCancel(leaseId)
	return await contractMethodSend(data)
}

export const approveLeasePact = async (leaseId) => {
	const data = contract.methods.reserveApprove(leaseId)
	return await contractMethodSend(data)
}

export const rejectLeasePact = async (leaseId) => {
	const data = contract.methods.reserveReject(leaseId)
	return await contractMethodSend(data)
}

export const poposeEndLeasePact = async (leaseId) => {
	const data = contract.methods.reservePopose(leaseId)
	return await contractMethodSend(data)
}

export const completeLeasePact = async (leaseId) => {
	const data = contract.methods.reserveComplete(leaseId)
	return await contractMethodSend(data)
}
// #endregion //////////////////// 合同 API



