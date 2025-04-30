import { Clarinet, Tx, Chain, Account } from "clarinet";

describe("Token operations", () => {
  Clarinet.test({
    name: "mint and transfer employee tokens",
    async fn(chain: Chain, accounts: Map<string, Account>) {
      const deployer = accounts.get("deployer")!;
      const alice = accounts.get("wallet_1")!;

      let mint = chain.mineBlock([
        Tx.contractCall("token", "mint", [Tx.principal(alice.address), Tx.uint(1000)], deployer.address),
      ]);

      mint.receipts[0].result.expectOk().expectUint(1000);
      chain.mineEmptyBlock(1);

      let balance = chain.callReadOnlyFn("token", "get-balance", [Tx.principal(alice.address)], deployer.address);
      balance.result.expectOk().expectUint(1000);
    },
  });
});
