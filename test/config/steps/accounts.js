'use strict'
const assert = require('chai').assert
const describe = require('mocha').describe
const it = require('mocha').it

let accounts = require('../../../src/config/steps/accounts.coffee')

describe('Step: accounts', () => {
  describe('#isActive', () => {
    it('should return true is the accounts app is installed', () => {
      let user = { apps: ['konnectors'] }
      assert.isTrue(accounts.isActive(user))
    })

    it('should return false is the accounts app is not installed', () => {
      let user = { apps: [] }
      assert.isFalse(accounts.isActive(user))
    })
  })
})
