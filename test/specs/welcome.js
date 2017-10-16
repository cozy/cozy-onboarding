/* global describe, it, browser */
const assert = require('chai').assert
const fetch = require('node-fetch')

browser.timeouts('script', 120000)

const filterInstance = (instances, domain) => {
  return instances.find(instance => {
    return instance.doc && instance.doc.domain === domain
  }) || instances[0]
}

const fetchRegisterToken = () => fetch(
      'http://localhost:5984/global%2Finstances/_all_docs?include_docs=true'
    )
    .then(response => response.json())
    .then(json => filterInstance(json.rows, 'cozy.tools:8080'))
    .then(instance => fetch(
      `http://localhost:5984/global%2Finstances/${instance.id}`
    ))
    .then(response => response.json())
    .then(json => json['register_token'])
    .then(registerTokenBase64 => Buffer.from(registerTokenBase64, 'base64').toString('hex'))

describe('BrowserStack Local Testing', function () {
  it('can check tunnel working', function (done) {
    console.log('can check tunnel working')
    let token = null
    fetchRegisterToken()
      .then(registerToken => token = registerToken)

    // Wait until the fetchRegisterToken Promise is resolved, then set token
    console.log(`accessing http://onboarding.cozy.tools:8080/?registerToken=${token}`)
    browser
      .waitUntil(() => token !== null)
    browser
      .url(`http://onboarding.cozy.tools:8080/?registerToken=${token}`)
      .pause(5000)

    assert.equal(browser.getText('h1'), 'Choose your password')
  })
})
