var TestContract = artifacts.require("TestContract");
var Marketplace = artifacts.require("Marketplace");
var ProductFactory = artifacts.require("Product_Factory");
var ManagerFactory = artifacts.require("Manager_Factory");
var EvaluatorFactory = artifacts.require("Evaluator_Factory");
var FreelancerFactory = artifacts.require("Freelancer_Factory");
var FinancerFactory = artifacts.require("Financer_Factory");
var StringUtils = artifacts.require("String_Utils");
var TokenManager = artifacts.require("TokenManager")

module.exports = async function (deployer) {

    var stringUtils;
    var tokenManager;
    var managerFactory;
    var evaluatorFactory;
    var freelancerFactory;
    var financerFactory;
    var productFactory;
    var marketplace;

    deployer.deploy(TestContract, 12345);

    await deployer.deploy(StringUtils);
    stringUtils = await StringUtils.deployed();

    await deployer.deploy(ProductFactory, stringUtils.address);
    productFactory = await ProductFactory.deployed();

    await deployer.deploy(TokenManager);
    tokenManager = await TokenManager.deployed();


    await deployer.deploy(ManagerFactory, stringUtils.address, tokenManager.address);
    managerFactory = await ManagerFactory.deployed();

    await deployer.deploy(EvaluatorFactory, stringUtils.address, tokenManager.address);
    evaluatorFactory = await ManagerFactory.deployed();

    await deployer.deploy(FreelancerFactory, stringUtils.address, tokenManager.address);
    freelancerFactory = await ManagerFactory.deployed();

    await deployer.deploy(FinancerFactory, stringUtils.address, tokenManager.address);
    financerFactory = await ManagerFactory.deployed();

    await deployer.deploy(Marketplace, productFactory.address, managerFactory.address, evaluatorFactory.address, freelancerFactory.address, financerFactory.address, stringUtils.address);


};

