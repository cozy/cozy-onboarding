/* global describe, it */
'use strict'
let assert = require('chai').assert
let sinon = require('sinon')

let Step = require('../../src/lib/onboarding.coffee').Step

describe('Onboarding.Step', () => {
  describe('#constructor', () => {
    it('should map expected properties', () => {
      // arrange
      let options = {
        name: 'test',
        route: 'testroute',
        view: 'testview'
      }

      // act
      let result = new Step({step: options})

      // assert
      assert.isDefined(result.name)
      assert.isDefined(result.route)
      assert.isDefined(result.view)

      assert.equal(result.name, options.name)
      assert.equal(result.route, options.route)
      assert.equal(result.view, options.view)
    })

    it('should not map unexpected properties', () => {
      // arrange
      let options = {
        inject: 'inject'
      }

      // act
      let result = new Step({step: options})

      // assert
      assert.isUndefined(result.inject)
    })

    it('should override default isActive with new one', () => {
      // arrange
      let overridingIsActive = (user) => {}
      let options = {
        isActive: overridingIsActive
      }

      // act
      let step = new Step({step: options})

      // assert
      assert.equal(overridingIsActive, step.isActive)
    })
  })

  describe('#onCompleted', () => {
    it('should add given callback to step changed handlers', () => {
      // arrange
      let step = new Step({step: {}})
      let callback = () => {}

      // act
      step.onCompleted(callback)

      // assert
      assert.include(step.completedHandlers, callback)
    })

    it('should throw an error when callback is not a function', () => {
      // arrange
      let step = new Step({step: {}})
      let callback = 'I am a string'
      let fn = () => {
        // act
        step.onCompleted(callback)
      }

      // assert
      assert.throws(fn, 'Callback parameter should be a function')
    })
  })

  describe('#onFailed', () => {
    it('should add given callback to step failed handlers', () => {
      // arrange
      let step = new Step({step: {}})
      let callback = () => {}

      // act
      step.onFailed(callback)

      // assert
      assert.include(step.failedHandlers, callback)
    })

    it('should throw an error when callback is not a function', () => {
      // arrange
      let step = new Step({step: {}})
      let callback = 'I am a string'
      let fn = () => {
        // act
        step.onFailed(callback)
      }

      // assert
      assert.throws(fn, 'Callback parameter should be a function')
    })
  })

  describe('#triggerCompleted', () => {
    it('should not throw an error when completedHandlers is empty', () => {
      // arrange
      let step = new Step({step: {}})

      let fn = () => {
        // act
        step.triggerCompleted()
      }

      // assert
      assert.doesNotThrow(fn)
    })

    it('should call callback list', () => {
      // arrange
      let step = new Step({step: {}})

      let callback1 = sinon.spy()
      let callback2 = sinon.spy()

      step.onCompleted(callback1)
      step.onCompleted(callback2)

      // act
      step.triggerCompleted()

      // assert
      assert(callback1.calledOnce)
      assert(callback2.calledOnce)
      assert(callback1.calledWith(step))
      assert(callback2.calledWith(step))
    })
  })

  describe('#triggerFailed', () => {
    it('should not throw an error when completedHandlers is empty', () => {
      // arrange
      let step = new Step({step: {}})

      let fn = () => {
        // act
        step.triggerFailed()
      }

      // assert
      assert.doesNotThrow(fn)
    })

    it('should call callback list', () => {
      // arrange
      let step = new Step({step: {}})

      let callback1 = sinon.spy()
      let callback2 = sinon.spy()

      step.onFailed(callback1)
      step.onFailed(callback2)

      // act
      step.triggerFailed()

      // assert
      assert(callback1.calledOnce)
      assert(callback2.calledOnce)
      assert(callback1.calledWith(step))
      assert(callback2.calledWith(step))
    })
  })

  describe('#isActive', () => {
    it('should return true by default', () => {
      // arrange
      let step = new Step({step: {}})

      // act
      let result = step.isActive()

      // assert
      assert.isTrue(result)
    })

    it('should call overriding method', () => {
      // arrange
      let spy = sinon.spy()
      let step = new Step({step: { isActive: spy }})

      // act
      step.isActive()

      // assert
      assert(spy.calledOnce)
    })

    it('should not call overriding method on other steps', () => {
      // arrange
      let spy = sinon.spy()
      let step = new Step({
        step: {
          isActive: spy
        }
      })

      let step2 = new Step({step: {}})

      // act
      step.isActive()
      let result2 = step2.isActive()

      // assert
      assert(spy.calledOnce)
      assert.isTrue(result2)
    })
  })

  describe('#submit', () => {
    it('should call save if argument', () => {
      // arrange
      let step = new Step({step: {}})
      let data = {data: 'data'}
      let savePromise = Promise.resolve(data)
      let promiseStub = sinon.stub(step, 'save')
      promiseStub.returns(savePromise)

      // act
      step.submit(data)

      // assert
      assert(step.save.calledOnce)
    })

    it('should call save if no argument', () => {
      // arrange
      let step = new Step({step: {}})
      let savePromise = Promise.resolve()
      let promiseStub = sinon.stub(step, 'save')
      promiseStub.returns(savePromise)

      // act
      step.submit()

      // assert
      assert(step.save.calledOnce)
    })
  })

  describe('#handleSubmitSuccess', () => {
    it('should call triggerCompleted', () => {
      // arrange
      let step = new Step({step: {}})
      let spy = sinon.spy(step, 'triggerCompleted')

      // act
      step.handleSubmitSuccess()

      // assert
      assert(spy.calledOnce)
    })
  })

  describe('#handleSubmitError', () => {
    it('should call triggerFailed with error argument', () => {
      // arrange
      let step = new Step({step: {}})
      let spy = sinon.spy(step, 'triggerFailed')
      let errorObject = {error: 'error occured'}

      step.handleSubmitError(errorObject)

      // assert
      assert(spy.withArgs(errorObject).calledOnce)
    })
  })

  describe('#save', () => {
    it('should call onboarding updateInstance', () => {
      // arrange
      let step = new Step({step: { name: 'testStep' }})
      let data = {data: 'data'}

      step.onboarding = {
        updateInstance: () => {}
      }

      sinon.stub(step.onboarding, 'updateInstance', (data) => Promise.resolve(data))

      // act
      step.save(data)

      // assert
      assert(step.onboarding.updateInstance.withArgs(step.name, data).calledOnce)

      delete step.onboarding
    })
  })

  describe('#handleSaveSuccess', () => {
    it('should return data if no error', () => {
      // arrange
      let step = new Step({step: {}})
      const data = {content: 'value'}

      // act
      let response = step.handleSaveSuccess(data)

      // assert
      assert.deepEqual(response, data)
    })
  })

  describe('#handleSaveError', () => {
    it('should throw an error if err.error only', () => {
      // arrange
      let step = new Step({step: {}})

      let fn = () => {
        // act
        step.handleSaveError({error: 'Global error occured'})
      }

      // assert
      assert.throws(fn, 'Global error occured')
    })

    it('should throw an joined error if many err.errors', () => {
      // arrange
      let step = new Step({step: {}})

      // act
      let fn = () => {
        // act
        step.handleSaveError({
          errors: {
            number: 'Many',
            type: 'errors',
            action: 'occured'
          }
        })
      }

      // assert
      assert.throws(fn, 'Many\nerrors\noccured')
    })
  })

  describe('#handleServerError', () => {
    it('should throw an error with serverErrorMessage key', () => {
      // arrange
      let step = new Step({step: {}})
      step.serverErrorMessage = 'Custom server error message'

      // act
      let fn = () => {
        // act
        step.handleServerError({})
      }

      // assert
      assert.throws(fn, 'Custom server error message')
    })
  })
})
