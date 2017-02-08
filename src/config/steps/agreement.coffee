module.exports = {
    name: 'agreement',
    view : 'steps/agreement'

    isDone: ({instance, contextToken}) ->
        return (@name in instance.attributes.onboardedSteps) or !!contextToken
}
