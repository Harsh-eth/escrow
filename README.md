# Escrow Smart Contract

A simple escrow system built in Solidity to handle secure peer-to-peer payments on-chain.

The contract allows two parties to create a deal where funds are locked in the contract until the conditions of the deal are met.

## Features

- Create a deal between sender and receiver
- Sender deposits ETH into the contract
- Sender approves the deal when work is completed
- Receiver completes the deal and receives payment
- Sender can cancel before approval
- Owner can refund approved deals if necessary
- Events emitted for important actions

## Why I Built This

I built this project to better understand how financial state machines work in smart contracts and how to safely handle ETH transfers between two parties.

It helped me practice:
- managing deal states
- writing secure payment logic
- designing clear contract flows

## Tech Stack

- Solidity
- HTML / CSS
- JavaScript (ethers.js)

## Network

Deployed on Sepolia testnet.

## Contract Logic Overview

1. **Create Deal**  
   Sender creates a deal and deposits ETH.

2. **Approve Deal**  
   Sender approves the payment once the work is completed.

3. **Complete Deal**  
   Receiver claims the funds after approval.

4. **Cancel Deal**  
   Sender can cancel before the deal is approved.

5. **Refund Deal**  
   Contract owner can refund the sender in special cases.

## Learning Focus

- Solidity state management
- secure ETH transfers
- event logging
- basic access control

## Network
Deployed on Sepolia testnet

## Contract
https://sepolia.etherscan.io/address/0x99665FfA5B82E0eE927dD39205b73a597Cbd0434

