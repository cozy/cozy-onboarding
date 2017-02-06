timezones = require '../../lib/timezones'
emailHelper = require '../../lib/email_helper'


# local function to validate email
isValidEmail = (email) ->
    return emailHelper.validate email


# Local function to validate timezone
isValidTimezone = (timezone) ->
    return timezone in timezones


module.exports = {
    name: 'infos',
    view : 'steps/infos',
    isActive: (instance) ->
        validation = @validate instance.attributes
        return not validation.success


    getData: () ->
        return \
            public_name: @publicName,
            email: @email,
            timezone: @timezone


    fetchData: (instance) ->
        return Promise.resolve @ unless instance.attributes

        @publicName = instance.attributes.public_name
        @email = instance.attributes.email
        @timezone = instance.attributes.timezone

        return Promise.resolve @


    # @see Onboarding.validate
    validate: (data) ->
        validation = success: false, errors: []

        ['public_name', 'email', 'timezone'].forEach (field) ->
            if typeof data[field] is 'undefined' \
                    or data[field].trim().length is 0
                validation.errors[field] = "missing #{field}"

        if data.email and not isValidEmail(data.email)
            validation.errors['email'] = 'invalid email format'

        if data.timezone and not isValidTimezone(data.timezone)
            validation.errors['timezone'] = 'invalid timezone'

        validation.success = Object.keys(validation.errors).length is 0

        return validation


    save: (data) ->
        data.onboardedSteps = [
            'welcome',
            'agreement',
            'password',
            'infos'
        ]

        return @onboarding.updateInstance data
            .then @handleSaveSuccess, @handleServerError
}
