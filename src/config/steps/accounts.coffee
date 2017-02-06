module.exports = {
    name: 'accounts',
    view: 'steps/accounts',

    isActive: (instance) ->
        return instance.apps && 'konnectors' in instance.apps

    save: (data) ->
        data.onboardedSteps = [
            'welcome',
            'agreement',
            'password',
            'infos',
            'accounts'
        ]

        return @onboarding.updateInstance data
            .then @handleSaveSuccess, @handleServerErrorr
}
