/*
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { Contract } = require('fabric-contract-api');

class EnergyContract extends Contract {

  async initLedger(ctx) {
      console.info('============= START : Initialize Ledger ===========');
      console.info('============= END : Initialize Ledger ===========');
  }

}

module.exports = EnergyContract;
