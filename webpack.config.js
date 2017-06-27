'use strict'

const merge = require('webpack-merge')
const { production } = require('./config/webpack.vars')

module.exports = merge(
  require('./config/webpack.base.config'),
  require('./config/webpack.disable-contexts.config'),
  require('./config/webpack.cozy-ui.config'),
  require('./config/webpack.pictures.config'),
  require('./config/webpack.copyfiles.config'),
  require(production ? './config/webpack.config.prod' : './config/webpack.config.dev'),
  { entry: ['url-polyfill', './src/initialize'] }
)
