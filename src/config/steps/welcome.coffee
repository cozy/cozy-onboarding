module.exports = {
    name: 'welcome',
    view: 'steps/welcome',

    isDone: ({contextToken}) ->
        return !!contextToken
}
