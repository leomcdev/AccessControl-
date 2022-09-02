const { keccak256 } = require("@ethersproject/keccak256");
const { expect } = require("chai");
const { ethers } = require("hardhat");

// this is standard, just change the func name and getcontractfactory
async function setState(_defaultAdmin) {
  const C = await ethers.getContractFactory("AssetState");
  const c = await C.deploy(_defaultAdmin);
  await c.deployed();
  return c;
}

// this is standard, just change the func name and getcontractfactory
async function setHandler(_defaultAdmin, _state) {
  const C = await ethers.getContractFactory("AssetHandler");
  const c = await C.deploy(_defaultAdmin, _state);
  await c.deployed();
  return c;
}

// this is standard, just change the func name and getcontractfactory
async function setECHandler(_defaultAdmin, _state) {
  const C = await ethers.getContractFactory("EcrecoverTest");
  const c = await C.deploy(_defaultAdmin, _state);
  await c.deployed();
  return c;
}

// need to give Leo  the system hash role?
describe("Test Leo State", function () {
  //add the variables you're working with
  var AssetState;
  var AssetHandler;
  var Ecrecover;

  // always runs first
  beforeEach(async function () {
    const [defaultAdmin, signer, user, user2, User] = await ethers.getSigners();
    AssetState = await setState(defaultAdmin.address);
    AssetHandler = await setHandler(defaultAdmin.address, AssetState.address);
    Ecrecover = await setECHandler(defaultAdmin.address, defaultAdmin.address);
  });

  it("should mint nft from group ", async function () {
    const [defaultAdmin, user, signer, user2] = await ethers.getSigners();

    // await expect(AssetState.connect(user).mint(user.address, [1])).to.be
    //   .reverted;

    const HANDLER = await AssetState.HANDLER();
    console.log("Hashen för HANDLER är: ", HANDLER);
    await AssetState.grantRole(HANDLER, AssetHandler.address);

    // get roll hash
    const MINTER = await AssetHandler.MINTER();
    console.log("Hashen för WHITELISTER är: ", MINTER);
    await AssetHandler.connect(defaultAdmin).grantRole(MINTER, user.address);

    await expect(AssetHandler.connect(user).mintInGroup(user.address, 1))
      .to.emit(AssetState, "Transfer")
      .withArgs(ethers.constants.AddressZero, user.address, 1000001);

    await expect(AssetHandler.connect(user).mintInGroup(user.address, 1))
      .to.emit(AssetState, "Transfer")
      .withArgs(ethers.constants.AddressZero, user.address, 1000002);

    await expect(AssetHandler.connect(user).mintInGroup(user.address, 1))
      .to.emit(AssetState, "Transfer")
      .withArgs(ethers.constants.AddressZero, user.address, 1000003);

    await expect(AssetHandler.connect(user).mintInGroup(user.address, 2))
      .to.emit(AssetState, "Transfer")
      .withArgs(ethers.constants.AddressZero, user.address, 2000001);

    await expect(AssetHandler.connect(user).mintInGroup(user.address, 2))
      .to.emit(AssetState, "Transfer")
      .withArgs(ethers.constants.AddressZero, user.address, 2000002);

    let tk = 3000011;
    console.log(tk / 1000000);

    expect(await AssetHandler.connect(user).getAssetGroup(1000000)).to.be.equal(
      1
    );
  });

  it("ecrecover: verify sign", async function () {
    const [defaultAdmin, signer, user, user2] = await ethers.getSigners();
    var obj = ethers.utils.defaultAbiCoder.encode(
      ["address"],
      [signer.address]
    );
    console.log("defadmin", defaultAdmin); //0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
    console.log("signer", signer);
    const { v, r, s } = await createSignature(obj);

    HANDLER = await Ecrecover.HANDLER();

    await Ecrecover.connect(defaultAdmin).grantRole(HANDLER, signer.address);

    // expect(
    //   await Ecrecover.connect(signer).mintAndSigns(v, r, s)
    // ).to.be.revertedWith("ERC721: token already minted");

    expect(
      await Ecrecover.connect(signer).mintAndSigns(v, r, s)
    ).to.be.revertedWith("Signature invalid");

    await Ecrecover.connect(signer).mintAndSigns(v, r, s);

    async function createSignature(obj) {
      obj = ethers.utils.arrayify(obj);
      console.log("obj", obj);
      console.log("obj length:", obj.length);
      const prefix = ethers.utils.toUtf8Bytes(
        "\x19Ethereum Signed Message:\n" + obj.length
      );
      const serverSig = await defaultAdmin.signMessage(obj);
      console.log("serversig:", serverSig);
      const sig = ethers.utils.splitSignature(serverSig);
      console.log("sig:", sig);
      return { ...sig, prefix };
    }
  });
});
