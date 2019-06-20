#!/bin/bash

export PATH=${PWD}/bin:${PWD}:$PATH
export FABRIC_CFG_PATH=$PWD
export VERBOSE=false

# channel name defaults to "mychannel"
export CHANNEL_NAME="mychannel"

# Generates Org certs using cryptogen tool
function generateCerts() {
  which cryptogen
  if [ "$?" -ne 0 ]; then
    echo "cryptogen tool not found. exiting"
    exit 1
  fi
  echo
  echo "##########################################################"
  echo "##### Generate certificates using cryptogen tool #########"
  echo "##########################################################"

  if [ -d "crypto-config" ]; then
    rm -Rf crypto-config
  fi
  set -x

  ./bin/cryptogen generate --config=./crypto-config.yaml
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate certificates..."
    exit 1
  fi
  echo
 
}

function generateChannelArtifacts() {
  which configtxgen
  if [ "$?" -ne 0 ]; then
    echo "configtxgen tool not found. exiting"
    exit 1
  fi

  echo "##########################################################"
  echo "#########  Generating Orderer Genesis block ##############"
  echo "##########################################################"
  # Note: For some unknown reason (at least for now) the block file can't be
  # named orderer.genesis.block or the orderer will fail to launch!

  set -x

  ./bin/configtxgen -profile energy_chain -channelID byfn-sys-channel -outputBlock ./channel-artifacts/genesis.block
  
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate orderer(enertgy_chain) genesis block..."
    exit 1
  fi
  echo
  echo "#################################################################"
  echo "### Generating channel configuration transaction 'channel.tx' ###"
  echo "#################################################################"
  set -x
  ./bin/configtxgen -profile commonchannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi

  echo
  echo "#################################################################"
  echo "#######    Generating anchor peer update for prosumerMSP   ##########"
  echo "#################################################################"
  set -x
  ./bin/configtxgen -profile commonchannel -outputAnchorPeersUpdate ./channel-artifacts/prosumerMSPanchors.tx -channelID $CHANNEL_NAME -asOrg prosumerMSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for peosumerMSP..."
    exit 1
  fi

  echo
  echo "#################################################################"
  echo "#######    Generating anchor peer update for consumerMSP   ##########"
  echo "#################################################################"
  set -x
  ./bin/configtxgen -profile commonchannel -outputAnchorPeersUpdate \
    ./channel-artifacts/consumerMSPanchors.tx -channelID $CHANNEL_NAME -asOrg consumerMSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for consumerMSP..."
    exit 1
  fi

  echo

  echo "#################################################################"
  echo "#######    Generating anchor peer update for exchangeMSP   ##########"
  echo "#################################################################"
  set -x
  ./bin/configtxgen -profile commonchannel -outputAnchorPeersUpdate \
    ./channel-artifacts/exchangeMSPanchors.tx -channelID $CHANNEL_NAME -asOrg exchangeMSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for exchangeMSP..."
    exit 1
  fi
  echo
}


# default consensus type
CONSENSUS_TYPE="kafka"

generateCerts

generateChannelArtifacts
