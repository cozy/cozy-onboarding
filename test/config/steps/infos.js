/* global describe, it, before, after, afterEach */
'use strict'
let assert = require('chai').assert
let sinon = require('sinon')

describe('Step: infos', () => {
  let jsdom
  let infos

  before(function () {
    jsdom = require('jsdom-global')()
    infos = require('../../../src/config/steps/infos.coffee')
  })

  after(function () {
    jsdom()
  })

  describe('#isActive', () => {
    it('should return true when validation.success is false', () => {
      // arrange
      const instance = {}
      sinon.stub(infos, 'validate', () => { return { success: false } })

            // act
      let result = infos.isActive(instance)

      // assert
      assert.isTrue(result)

      infos.validate.restore()
    })

    it('should return false when validation.success is true', () => {
      // arrange
      const instance = {}
      sinon.stub(infos, 'validate', () => { return { success: true } })

            // act
      let result = infos.isActive(instance)

      // assert
      assert.isFalse(result)

      infos.validate.restore()
    })
  })

  describe('#getData', () => {
    afterEach(() => {
      delete infos.publicName
      delete infos.email
      delete infos.timezone
    })

    it('should return email value', () => {
            // arrange
      const expectedEmail = 'claude@causi.cc'
      infos.email = expectedEmail

            // act
      let data = infos.getData()

            // assert
      assert.equal(data.email, expectedEmail)
    })

    it('should return public_name value', () => {
            // arrange
      const expectedPublicName = 'Claude Causi'
      infos.publicName = expectedPublicName

            // act
      let data = infos.getData()

            // assert
      assert.equal(data.public_name, expectedPublicName)
    })

    it('should return timezone value', () => {
            // arrange
      const expectedTimezone = 'Europe/London'
      infos.timezone = expectedTimezone

            // act
      let data = infos.getData()

            // assert
      assert.equal(data.timezone, expectedTimezone)
    })

    it('should return undefined values when data have not been set', () => {
            // arrange

            // act
      let data = infos.getData()

            // assert
      assert.isUndefined(data.public_name)
      assert.isUndefined(data.email)
      assert.isUndefined(data.timezone)
    })
  })

  describe('#validate', () => {
    it('should not validate empty public_name', () => {
            // arrange
      const data = {
        public_name: ''
      }

      const expectedMessage = 'missing public_name'

            // act
      let validation = infos.validate(data)

            // assert
      assert.isFalse(validation.success)
      assert.isDefined(validation.errors)
      assert.isDefined(validation.errors['public_name'])
      assert.equal(validation.errors['public_name'], expectedMessage)
    })

    it('should not validate empty email', () => {
            // arrange
      const data = {
        email: ''
      }

      const expectedMessage = 'missing email'

            // act
      let validation = infos.validate(data)

            // assert
      assert.isFalse(validation.success)
      assert.isDefined(validation.errors)
      assert.isDefined(validation.errors['email'])
      assert.equal(validation.errors['email'], expectedMessage)
    })

    it('should not validate empty timezone', () => {
            // arrange
      const data = {
        timezone: ''
      }

      const expectedMessage = 'missing timezone'

            // act
      let validation = infos.validate(data)

            // assert
      assert.isFalse(validation.success)
      assert.isDefined(validation.errors)
      assert.isDefined(validation.errors['timezone'])
      assert.equal(validation.errors['timezone'], expectedMessage)
    })

    it('should validate valid public_name', () => {
            // arrange
      const data = {
        public_name: 'Claude Causi'
      }

            // act
      let validation = infos.validate(data)

            // assert
      assert.isUndefined(validation.errors['public_name'])
    })

    it('should validate valid email', () => {
            // arrange
      const data = {
        email: 'claude@causi.cc'
      }

            // act
      let validation = infos.validate(data)

            // assert
      assert.isUndefined(validation.errors['email'])
    })

    it('should validate valid timezone', () => {
            // arrange
      const data = {
        timezone: 'Africa/Abidjan'
      }

            // act
      let validation = infos.validate(data)

            // assert
      assert.isUndefined(validation.errors['timezone'])
    })

    it('should not validate invalid email', () => {
            // arrange
      const data = {
        email: 'claude.causi.cc'
      }

      let expectedMessage = 'invalid email format'

            // act
      let validation = infos.validate(data)

            // assert
      assert.isFalse(validation.success)
      assert.isDefined(validation.errors)
      assert.isDefined(validation.errors['email'])
      assert.equal(validation.errors['email'], expectedMessage)
    })

    it('should not validate invalid timzone', () => {
            // arrange
      const data = {
        timezone: 'Fakeland/Nowhere'
      }

      let expectedMessage = 'invalid timezone'

            // act
      let validation = infos.validate(data)

            // assert
      assert.isFalse(validation.success)
      assert.isDefined(validation.errors)
      assert.isDefined(validation.errors['timezone'])
      assert.equal(validation.errors['timezone'], expectedMessage)
    })

    it('should validate all valid data', () => {
            // arrange
      const data = {
        public_name: 'Claude Causi',
        email: 'claude@causi.cc',
        timezone: 'America/Guadeloupe'
      }

            // act
      let validation = infos.validate(data)

            // assert
      assert.isTrue(validation.success)
      assert.equal(validation.errors.length, 0)
    })
  })

  describe('#fetchData', () => {
    afterEach(() => {
      delete infos.publicName
      delete infos.email
      delete infos.timezone
    })

    it('should map data from instance', (done) => {
      // arrange
      const mockedData = {
        public_name: 'Claude Fetched',
        email: 'claude@fetched.com',
        timezone: 'Network/Fetch'
      }

      const instance = {
        attributes: mockedData
      }

      // act
      infos.fetchData(instance)

      setTimeout(() => {
        // assert
        assert.equal(infos.publicName, mockedData.public_name)
        assert.equal(infos.email, mockedData.email)
        assert.equal(infos.timezone, mockedData.timezone)
        done()
      }, 5)
    })
  })

  describe('#save', () => {
    it('should call onboarding.updateInstance', () => {
      // arrange
      const data = {
        password: 'plop',
        onboardedSteps: [
          'welcome',
          'agreement',
          'password',
          'infos'
        ]
      }

      const onboarding = {
        updateInstance: () => {}
      }

      sinon.stub(onboarding, 'updateInstance', () => Promise.resolve())

      infos.onboarding = onboarding

      // act
      infos.save(data)

      // assert
      assert(onboarding.updateInstance.withArgs(sinon.match(data)).calledOnce)

      delete infos.onboarding
    })

    it('should call `handleSaveSuccess`', (done) => {
      // arrange
      const data = {
        password: 'plop',
        onboardedSteps: [
          'welcome',
          'agreement',
          'password',
          'infos'
        ]
      }

      const onboarding = {
        updateInstance: () => {}
      }

      sinon.stub(onboarding, 'updateInstance', () => Promise.resolve(data))

      infos.onboarding = onboarding

      infos.handleSaveSuccess = sinon.spy()

      // act
      infos.save(data)

      setTimeout(() => {
                // assert
        assert(infos.handleSaveSuccess.withArgs(sinon.match(data)).calledOnce)

        // assert
        delete infos.onboarding
        delete infos.handleSaveSuccess
        done()
      })
    })
  })
})
