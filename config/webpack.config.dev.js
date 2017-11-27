'use strict'

const webpack = require('webpack')

module.exports = {
  devtool: '#source-map',
  externals: ['cozy'],
  plugins: [
    new webpack.DefinePlugin({
      __SERVER__: JSON.stringify('http://app.cozy.tools'),
      __SENTRY_DSN__: JSON.stringify('https://a786b83e53ce40b9bf341a8e02cf92a4@sentry.cozycloud.cc/5'),
      __SENTRY_SECRET__: JSON.stringify('754a693428504bf0b6de850dcfe1990e'),
      __SENTRY_USE_STACK_PROXY__: true,
      __STACK_ASSETS__: false,
      __PIWIK_TRACKER_URL__: JSON.stringify('https://piwik.cozycloud.cc/piwik.php'),
      __PIWIK_SITEID__: 8,
      __PIWIK_DIMENSION_ID_APP__: 1
    }),
    new webpack.ProvidePlugin({
      'cozy.client': 'cozy-client-js/dist/cozy-client.js'
    })
  ]
}
