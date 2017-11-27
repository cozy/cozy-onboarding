'use strict'

const webpack = require('webpack')

module.exports = {
  output: {
    filename: 'app.[hash].min.js'
  },
  devtool: '#cheap-module-source-map',
  plugins: [
    new webpack.optimize.DedupePlugin(),
    new webpack.optimize.OccurenceOrderPlugin(),
    new webpack.optimize.UglifyJsPlugin({
      mangle: true,
      compress: {
        warnings: false
      }
    }),
    new webpack.DefinePlugin({
      __SERVER__: false,
      __SENTRY_DSN__: JSON.stringify('https://f7318fd2c48f498895b5d2157ee53d1e@sentry.cozycloud.cc/4'),
      __SENTRY_SECRET__: JSON.stringify('f4d15259bd934a07991e3b32cbdc7387'),
      __SENTRY_USE_STACK_PROXY__: true,
      __DEVELOPMENT__: false,
      __DEVTOOLS__: false,
      __STACK_ASSETS__: true,
      __PIWIK_TRACKER_URL__: JSON.stringify('https://piwik.cozycloud.cc/piwik.php'),
      __PIWIK_SITEID__: 8,
      __PIWIK_DIMENSION_ID_APP__: 1
    })
  ]
}
