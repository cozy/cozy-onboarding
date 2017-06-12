ServicesStepView = require './services'


module.exports = class FingView extends ServicesStepView

    title: 'step fing title'

    figure:
      id: 'fing-figure'
      svg: require '../../assets/sprites/fing.svg'

    services: ['maif', 'edf', 'orangemobile', 'orangelivebox']
