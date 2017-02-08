passwordHelper = require '../../lib/password_helper'

module.exports = {
    name: 'password',
    view : 'steps/password'

    isDone: ({instance, contextToken}) ->
        return (@name in instance.attributes.onboardedSteps) or !!contextToken

    # Return validation object
    # @see Onboarding.validate
    validate: (data={}) ->
        validation =
            success: false,
            errors: []
        if not data or not data.password
            validation.errors['password'] = 'step password empty'
        else if data.password
            passwordStrength = passwordHelper.getStrength data.password
            if passwordStrength?.label is 'weak'
                validation.errors['password'] = 'step password too weak'

        validation.success = Object.keys(validation.errors).length is 0
        return validation

    save: (data) ->
        return @onboarding.updateInstance(@name)
            .then () =>
                return @onboarding.savePassphrase data.password
            .then @handleSaveSuccess, @handleServerError

    needReloadAfterComplete: true
}
