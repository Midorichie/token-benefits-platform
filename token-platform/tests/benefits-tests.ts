import { Clarinet, Tx, Chain, Account } from "clarinet";

describe("Benefits issuance and redemption", () => {
  Clarinet.test({
    name: "issue and redeem benefit tokens",
    async fn(chain: Chain, accounts: Map<string, Account>) {
      const deployer = accounts.get("deployer")!;
      const bob = accounts.get("wallet_2")!;

      let issue = chain.mineBlock([
        Tx.contractCall("benefits", "issue-benefit", [Tx.principal(bob.address), Tx.uint(500)], deployer.address),
      ]);
      issue.receipts[0].result.expectOk().expectUint(500);

      let redeem = chain.mineBlock([
        Tx.contractCall("benefits", "redeem-benefit", [Tx.principal(bob.address)], bob.address),
      ]);
      redeem.receipts[0].result.expectOk().expectBool(true);
    },
  });
});
