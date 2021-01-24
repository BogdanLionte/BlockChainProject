var Marketplace = artifacts.require("Marketplace");
var ProductFactory = artifacts.require("Product_Factory");
var ManagerFactory = artifacts.require("Manager_Factory");
var EvaluatorFactory = artifacts.require("Evaluator_Factory");
var FreelancerFactory = artifacts.require("Freelancer_Factory");
var FinancerFactory = artifacts.require("Financer_Factory");
var TokenManager = artifacts.require("TokenManager")

module.exports = async function (deployer) {

    var tokenManager;
    var managerFactory;
    var evaluatorFactory;
    var freelancerFactory;
    var financerFactory;
    var productFactory;

    await deployer.deploy(ProductFactory);
    productFactory = await ProductFactory.deployed();

    await deployer.deploy(TokenManager);
    tokenManager = await TokenManager.deployed();

    await deployer.deploy(ManagerFactory, tokenManager.address);
    managerFactory = await ManagerFactory.deployed();

    await deployer.deploy(EvaluatorFactory, tokenManager.address);
    evaluatorFactory = await EvaluatorFactory.deployed();

    await deployer.deploy(FreelancerFactory, tokenManager.address);
    freelancerFactory = await FreelancerFactory.deployed();

    await deployer.deploy(FinancerFactory, tokenManager.address);
    financerFactory = await FinancerFactory.deployed();

    await deployer.deploy(Marketplace, productFactory.address, managerFactory.address, evaluatorFactory.address, freelancerFactory.address, financerFactory.address);


};

