module.exports = {
    name: 'firstsConnectors',
    view : 'steps/firstsConnectors'
    isActive: (instance) ->
        instance.attributes \
        && instance.attributes.context
}
