module.exports = {
    name: 'agreement',
    view : 'steps/agreement'

    isDone: ({contextToken}) ->
        return !!contextToken
}
