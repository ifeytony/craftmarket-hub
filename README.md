# CraftMarket Hub

A decentralized marketplace for handmade crafts and custom artisan commissions built on the Stacks blockchain.

## Overview

CraftMarket Hub empowers artisans to showcase their handmade crafts and connect directly with customers seeking unique, custom-made items. The platform ensures transparent commission tracking and artisan certification.

## Features

- Showcase handmade crafts with detailed material descriptions and creation timelines
- Commission custom crafts using STX tokens with direct artisan payments
- Track complete commission history and project timelines
- Curator certification system for artisan quality verification
- Immutable record of all craft commissions and transactions

## Smart Contract Functions

### Public Functions

- `showcase-craft`: Artisans can display their crafts with materials and commission pricing
- `commission-craft`: Customers can commission custom crafts by paying artisans
- `certify-craft`: Marketplace curator can certify artisan quality and authenticity

### Read-Only Functions

- `get-craft`: Retrieve complete craft information and artisan details
- `get-timeline-event`: View specific commission timeline events
- `get-timeline-length`: Check total number of timeline events for a craft

## Development

Built using Clarity smart contracts on the Stacks blockchain for transparent artisan commerce.

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet)
- [Stacks CLI](https://github.com/blockstack/stacks.js)

### Testing

Run tests using Clarinet:

```bash
clarinet test