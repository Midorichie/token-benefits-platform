import { StacksTestnet, StacksMainnet } from '@stacks/network';
import { deployContract, makeContractDeploy } from './helpers';

async function main() {
  const network = new StacksTestnet();
  const deployerKey = process.env.DEPLOYER_KEY!;

  await deployContract(
    makeContractDeploy("token", "contracts/token.clar", { network, key: deployerKey })
  );
  await deployContract(
    makeContractDeploy("benefits", "contracts/benefits.clar", { network, key: deployerKey })
  );
}

main().catch(console.error);
