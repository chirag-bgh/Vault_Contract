const { ethers } = require("hardhat");
const abi = require("../abi.json");

describe("Vault contract", async function () {
  let Vault, myvault, signer;
  let whaleAccount = "0x06959153B974D0D5fDfd87D561db6d8d4FA0bb0B";
  
  const wethAbi = new ethers.Contract("0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619", abi);
  const usdcAbi = new ethers.Contract("0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174", abi);

  const TOKEN_A_AMOUNT = "1000000000000000"; // 18 decimals
  const TOKEN_B_AMOUNT = "1000000"; //6 decimals
  
  beforeEach(async function () {
    Vault = await ethers.getContractFactory("Vault");
    myvault = await Vault.deploy();
    await myvault.deployed();

    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [whaleAccount],
    });
    signer = await ethers.getSigner(whaleAccount);

    await wethAbi.connect(signer).approve(myvault.address, TOKEN_A_AMOUNT);
    await usdcAbi.connect(signer).approve(myvault.address, TOKEN_B_AMOUNT);
  });

  it("should lock tokens to the vault contract and add liquidity to the LP lool", async function () {
    let txn1 = await myvault.connect(signer).lockTokens(TOKEN_A_AMOUNT, TOKEN_B_AMOUNT);
    console.log(txn1);    
    let txn2 = await myvault.connect(signer).allocateToPool();
    console.log(txn2);
  });
});
