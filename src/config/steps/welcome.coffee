module.exports = {
    name: 'welcome',
    view: 'steps/welcome',

    isDone: ({instance, contextToken}) ->
        return (@name in instance.attributes.onboardedSteps) or !!contextToken
}
