# Employee Benefits Token Platform

A blockchain-based platform for managing employee benefits and rewards using Clarity smart contracts on the Stacks blockchain.

## Overview

The Employee Benefits Token Platform is a decentralized application designed to transform how companies manage employee benefits and rewards. By leveraging blockchain technology, this platform provides transparency, security, and efficiency in distributing and tracking employee benefits.

## Features

- **Fungible Token System**: Custom EBT (Employee Benefit Token) for benefits management
- **Benefits Claim System**: Transparent process for employees to claim various benefits
- **Reward Tiers**: Progressive reward system based on employee participation and tenure
- **Task Management**: Create and manage tasks that employees can complete to earn points
- **Administrative Controls**: Comprehensive management tools for contract owners

## Smart Contracts

The platform consists of two main smart contracts:

### 1. Benefits Token Contract (`benefits-token.clar`)

Core contract for managing the fungible token and benefits system.

- Implements the main EBT (Employee Benefit Token)
- Handles employee registration and deactivation
- Manages benefit types and claims
- Processes claim approvals

### 2. Benefit Rewards Contract (`benefit-rewards.clar`)

Companion contract that enables a rewards system based on employee participation.

- Implements reward tiers with different thresholds
- Manages tasks that employees can complete
- Tracks participation points
- Handles reward distribution

## Architecture

```
+------------------+         +-----------------+
|                  |         |                 |
| Benefits Token   | <-----> | Benefit Rewards |
| Contract         |         | Contract        |
|                  |         |                 |
+------------------+         +-----------------+
        ^                            ^
        |                            |
        v                            v
+--------------------------------------------------+
|                                                  |
|                 Employees                        |
|                                                  |
+--------------------------------------------------+
```

## Contract Interactions

- Employees can claim benefits using tokens from the Benefits Token contract
- Employees can complete tasks registered in the Benefit Rewards contract
- Admins can verify task completions and approve benefit claims
- The Benefit Rewards contract can mint new tokens for employees as rewards

## Setup and Deployment

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Development and testing framework for Clarity
- [Stacks CLI](https://docs.stacks.co/get-started/command-line-interface) - For deploying to testnet/mainnet

### Local Development

1. Clone the repository:
   ```bash
   git clone https://github.com/midorichie/token-benefits-platform.git
   cd token-benefits-platform
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Test contracts using Clarinet:
   ```bash
   clarinet check   # Syntax check
   clarinet test    # Run test suite
   ```

4. Start a local development environment:
   ```bash
   clarinet console
   ```

### Deployment

1. Configure your `.env` file with your deployment credentials.

2. Deploy to the Stacks testnet:
   ```bash
   clarinet deploy --testnet
   ```

3. For mainnet deployment (when ready):
   ```bash
   clarinet deploy --mainnet
   ```

## Usage Examples

### Register an Employee

```clarity
(contract-call? .benefits-token register-employee 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM "John Doe" "Engineering")
```

### Create a Benefit Type

```clarity
(contract-call? .benefits-token register-benefit-type "health-insurance" u500 "Standard health insurance coverage")
```

### Claim a Benefit

```clarity
(contract-call? .benefits-token claim-benefit "health-insurance" u1)
```

### Complete a Task

```clarity
(contract-call? .benefit-rewards complete-task "wellness-program" u1)
```

### Claim a Reward

```clarity
(contract-call? .benefit-rewards claim-tier-reward u1 .benefits-token)
```

## Security Considerations

- All administrative functions are protected with owner-only access controls
- Pause functionality for emergency situations
- Input validation on critical parameters
- Comprehensive error codes for debugging
- Protected contract state transitions

## Error Codes

| Code | Description |
|------|-------------|
| u100 | Not authorized |
| u101 | Insufficient balance |
| u102 | Not found |
| u103 | Already exists |
| u104 | Invalid status |
| u105 | Cooldown active / Contract paused |
| u106 | Inactive benefit/task |
| u107 | Task already verified |
| u108 | Claim already processed |
| u109 | Insufficient points |
| u110-u117 | Various input validation errors |
| u200 | Invalid input |
| u201 | Contract paused |

## Future Enhancements

- Integration with decentralized identity systems
- Advanced analytics dashboard
- Multi-signature administrative controls
- Automated disbursement schedules
- Mobile application for easy access

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Stacks Foundation for providing the blockchain infrastructure
- Hiro Systems for developing Clarinet
- The Clarity language documentation and community
