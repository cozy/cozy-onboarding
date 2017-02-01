module.exports = {
    name: 'accounts',
    route: 'register/accounts',
    view: 'steps/accounts',

    isActive: (instance) ->
        return instance.apps && 'konnectors' in instance.apps

    save: (data) ->
        onboardedSteps = [
            'welcome',
            'agreement',
            'password',
            'infos',
            'accounts'
        ]
        return fetch '/register',
            method: 'PUT',
            # Authentify
            credentials: 'include',
            body: JSON.stringify {onboardedSteps: onboardedSteps}
        .then @handleSaveSuccess, @handleServerError
}
