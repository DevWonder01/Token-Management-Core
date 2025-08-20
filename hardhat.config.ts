// hardhat.config.ts

import "dotenv/config"
import "@nomiclabs/hardhat-etherscan"
import "@nomiclabs/hardhat-solhint"
import "@nomiclabs/hardhat-ethers"
import "@tenderly/hardhat-tenderly"
import "@nomiclabs/hardhat-waffle"
import "@openzeppelin/hardhat-upgrades"
import "hardhat-abi-exporter"
import "hardhat-deploy"
import "hardhat-deploy-ethers"
import "hardhat-gas-reporter"
import "hardhat-spdx-license-identifier"
import "hardhat-typechain"
import "hardhat-watcher"
import "solidity-coverage"

// import "./tasks"

import { HardhatUserConfig } from "hardhat/types"
import { removeConsoleLog } from "hardhat-preprocessor"

const accounts = {
  mnemonic: process.env.MNEMONIC || "test test test test test test test test test test test junk",
  // accountsBalance: "990000000000000000000",
}


const accountKey = [""]


const config: HardhatUserConfig = {
  abiExporter: {
    path: "./abi",
    clear: false,
    flat: true,
    // only: [],
    // except: []
  },
  solidity: {
    compilers: [
      {
        version: "0.8.20",
        settings: { 
          viaIR: true,
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.8.12",
        settings: {
          // viaIR: true,
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.8.4",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.8.7",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.8.2",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },

      {
        version: "0.8.1",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },

      {
        version: "0.8.0",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },      {
        version: "0.6.12",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.7.6",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },  
       },
      {
        version: "0.7.1",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.6.6",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.6.9",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.6.7",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.5.16",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.4.18",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  defaultNetwork: "hardhat",
  etherscan: {
    apiKey: "",
  },

  mocha: {
    timeout: 20000,
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
    dev: {
      // Default to 1
      default: 0,
    },
    treasury: {
      default: 1,
    },
    investor: {
      default: 2,
    },
  },
  networks: {
    mainnet: {
      url: "https://mainnet.infura.io/v3/${process.env.INFURA_API_KEY}",
      accounts,
      gasPrice: 120 * 1000000000,
      chainId: 1,
    },

     "sonic-testnet": {
      url : "https://sonic-testnet.drpc.org",
      accounts : [accountKey[0]],
      gasPrice: 120 * 1000000000,
      chainId: 57054,

    },


    localhost: {
    
    },
    hardhat: {
      forking: {
        enabled: true,
        url: "https://api.avax.network/ext/bc/C/rpc",
        blockNumber: 6394745,
      },
    },
  },
  paths: {
    artifacts: "artifacts",
    cache: "cache",
    sources: "contracts",
    tests: "test",
  },
  preprocess: {
    eachLine: removeConsoleLog((bre:any) => bre.network.name !== "hardhat" && bre.network.name !== "localhost"),
  },

  spdxLicenseIdentifier: {
    overwrite: false,
    runOnCompile: true,
  },

  typechain: {
    outDir: "types",
    target: "ethers-v5",
  },
  watcher: {
    compile: {
      tasks: ["compile"],
      files: ["./contracts"],
      verbose: true,
    },
  },
}

export default config