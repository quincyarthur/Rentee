var Escrow = artifacts.require("Escrow");
var CryptoRent = artifacts.require("CryptoRent")

module.exports = function(deployer) {
    deployer.deploy(Escrow)
    deployer.deploy(CryptoRent)
};