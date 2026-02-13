# Filecoin Onchain Cloud Treasury

## Developoer Setup

### Install dependencies
[This EVM assembler](https://github.com/wjmelements/evm) is used to build the proxy.
```sh
# https://wjmelements.github.io/evm/#installation

# Clone
git clone https://github.com/wjmelements/evm.git

# Build
make -C evm bin/evm

# Install
sudo install evm/bin/evm /usr/local/bin/
```

`forge` ([foundry](https://github.com/foundry-rs/foundry)) is used to build solidity projects.
```sh
# https://www.getfoundry.sh/introduction/installation

# Install to ~/.foundry/bin
curl -L https://foundry.paradigm.xyz | bash

# Add to path
source ~/.bashrc

# Install latest forge
foundryup
```

### Build

```sh
# Clone
git clone --recurse-submodules git@github.com:FilOzone/foc-treasury.git

# Build
make

# Test
make test

# TODO Deploy
```
