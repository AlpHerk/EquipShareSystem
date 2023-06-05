const LibArray = artifacts.require("LibArray")
const EquipShare = artifacts.require("EquipShare")

module.exports = function(deployer) {
  deployer.deploy(LibArray)
  deployer.link(LibArray, EquipShare)
  deployer.deploy(EquipShare)
}