// WebdriverIO configuration filen
// See http://webdriver.io/guide/testrunner/configurationfile.html
var path = require('path')

var browserstack = require('browserstack-local');

function getScreenshotName (basePath) {
  return function (context) {
    var type = context.type
    var testName = context.test.title
    var width = context.meta.width
    var browserVersion = parseInt(context.browser.version, 10)
    var browserName = context.browser.name
    return path.join(basePath, `${testName}_${type}_${browserName}_v${browserVersion}_w${width}.png`)
  }
}

exports.config = {
  path: '/wd/hub',
  specs: [
    './**/*.js'
  ],
  exclude: [
    './wdio.conf.js'
  ],
  maxInstances: 10,
  // See https://www.browserstack.com/automate/webdriverio
  capabilities: [{
    'os': 'Windows',
    'os_version': '10',
    'browser': 'Chrome',
    'browser_version': '42.0',
    'resolution': '1024x768',
    'browserstack.local' : 'true'
  }, {
    'os': 'OS X',
    'os_version': 'Sierra',
    'browser': 'Safari',
    'browser_version': '10.0',
    'resolution': '1024x768',
    'browserstack.local' : 'true'
  }],
  sync: true,
  logLevel: 'verbose',
  coloredLogs: true,
  bail: 0,
  screenshotPath: './__screenshots__/errorShots',
  baseUrl: 'http://cozy.local',
  waitforTimeout: 30000,
  connectionRetryTimeout: 90000,
  connectionRetryCount: 3,
  services: [
    'browserstack'
  ],

  // Code to start browserstack local before start of test
  onPrepare: function (config, capabilities) {
    console.log('Connecting local')
    return new Promise(function (resolve, reject) {
      exports.bs_local = new browserstack.Local()
      exports.bs_local.start({ 'key': exports.config.key }, function (error) {
        if (error) return reject(error)
        resolve()
      })
    })
  },

  // Code to stop browserstack local after end of test
  onComplete: function (capabilties, specs) {
    exports.bs_local.stop(function () {})
  },
  user: 'browserstack_login',
  key: 'browserstack_password',
  framework: 'mocha',
  mochaOpts: {
    ui: 'bdd',
    compilers: ['js:babel-register'],
    require: ['babel-polyfill'],
    timeout: 60000
  }
}
