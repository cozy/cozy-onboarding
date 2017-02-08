# Local class Step
class Step

    # Default error message when a server error occurs
    serverErrorMessage: 'step server error'

    # Retrieves properties from config Step plain object
    # @param step : config step, i.e. plain object containing custom properties
    #   and methods.
    constructor: (options={}) ->
        { step,
          onboarding,
          onCompleted,
          onFailed
        } = options

        [
          'name',
          'route',
          'view',
          'isActive',
          'fetchInstance',
          'fetchData',
          'getData',
          'needReloadAfterComplete',
          'validate',
          'save',
          'error'
        ].forEach (property) =>
            if step[property]?
                @[property] = step[property]

        @onboarding = onboarding

        onCompleted and @onCompleted onCompleted
        onFailed and @onFailed onFailed


    # Returns data related to step.
    # This is a default method that may be overriden
    getData: () ->
        return public_name: @publicName


    getName: () ->
        return @name


    getError: () ->
        return @error


    fetchData: (instance) ->
        return Promise.resolve(@)


    # Record handlers for 'completed' internal pseudo-event
    onCompleted: (callback) ->
        throw new Error 'Callback parameter should be a function' \
            unless typeof callback is 'function'
        @completedHandlers = @completedHandlers or []
        @completedHandlers.push callback


    onFailed: (callback) ->
        throw new Error 'Callback parameter should be a function' \
            unless typeof callback is 'function'
        @failedHandlers = @failedHandlers or []
        @failedHandlers.push callback


    # Trigger 'completed' pseudo-event
    # returnValue is from configStep.submit
    triggerCompleted: (data) ->
        if @needReloadAfterComplete
            if window \
                and window.location \
                    and typeof window.location.reload is 'function'
                        window.location.reload()
            else
                throw new Error 'Cannot reload window'

            return

        if @completedHandlers
            @completedHandlers.forEach (handler) =>
                handler(@, data)


    triggerFailed: (error) ->
        if @failedHandlers
            @failedHandlers.forEach (handler) =>
                handler(@, error)


    # Returns true if the step has to be submitted by the instance
    # This method returns true by default, but can be overriden
    # by config steps
    # @param instance : plain JS object. Not used in this abstract default method
    #  but should be in overriding ones.
    isActive: (instance) ->
        return true


    # Validate data related to step
    # This method may be overriden by step options
    # @param data: Data to validate
    # @return a validation object like following :
    #   {
    #       success: Boolean
    #       error: single error message
    #       errors: Array containg key value, typically used to validate
    #                multiple fields in a form.
    #   }
    validate: (data) ->
        return success: true, error: null, errors: []


    # Submit the step
    # This method should be overriden by step given as parameter to add
    # for example a validation step.
    # Maybe it should return a Promise or a call a callback couple
    # in the near future
    submit: (data={}) ->
        validation = @validate data

        if not validation.success
            return Promise.reject \
                message: validation.error,
                errors: validation.errors

        return @save data
            .then @handleSubmitSuccess


    # Handler for error occuring during a submit()
    handleSubmitError: (error) =>
        @triggerFailed error

    # Handler for submit success
    handleSubmitSuccess: (data) =>
      @triggerCompleted data


    # Save data
    # By default this method returns a resolved promise, but it can overriden
    # by specifying another save method in constructor parameters
    # @param data : JS object containing data to save
    save: (data={}) ->
        return Promise.resolve(data)

    # Success handler for save() call
    handleSaveSuccess: (response) =>
        # Success ? Hell no we still have to check the status !
        if not response.ok
            return @handleServerError response unless response.status is 400

            # Validation error
            return response.json().then (json) =>
                throw message: 'validation error', errors: json.errors

        return response.data


    _joinValues: (objectData, separator) =>
        result = ''
        for key,value of objectData
            result += ('' + value + separator)
        return result

    # Error handler for save() call
    handleSaveError: (err) =>
        if err.errors and Object.keys(err.errors)
            throw new Error @_joinValues(err.errors, '\n')
        else
            throw new Error err.error


    handleServerError: (response) =>
        throw new Error @serverErrorMessage


# Main class
# Onboarding is the component in charge of managing steps
module.exports = class Onboarding


    initialize: (options={}) ->
        { steps,
          domain,
          registerToken,
          contextToken,
          onStepChanged,
          onStepFailed,
          onDone } = options

        throw new Error 'Missing mandatory `steps` parameter' unless steps
        throw new Error '`steps` parameter is empty' unless steps.length

        @domain = domain
        @contextToken = contextToken
        @registerToken = registerToken

        onStepChanged and @onStepChanged onStepChanged
        onStepFailed and @onStepFailed onStepFailed
        onDone and @onDone onDone

        @steps = steps.map (step) =>
            return new Step \
                step: step,
                onboarding: @,
                onCompleted: @handleStepCompleted,
                onFailed: @handleStepError

        return @fetchInstance()
            .then @handleFetchInstanceSuccess, @handleFetchInstanceError


    # Fetch instance data from cozy-stack
    # @return a Promise
    fetchInstance: ->
        url = new URL "#{window.location.protocol}//#{@domain}/settings/instance"

        if not(@contextToken) and @registerToken
          url.searchParams.append 'registerToken', @registerToken if @registerToken

        headers = new Headers()
        headers.append 'Accept', 'application/vnd.api+json'

        if @contextToken
            headers.append 'Authorization', "Bearer #{@contextToken}"

        return fetch url, { headers: headers, credentials: 'include' }


    handleFetchInstanceSuccess: (response) =>
        if not response.ok
            e = new Error 'onboarding fetch instance error'
            e.name = response.statusText
            throw e

        return response.json().then (jsonResponse) =>
            instance = jsonResponse.data
            @instance = instance
            @activeSteps = @steps.filter (step) ->
                return step.isActive instance
            return @


    handleFetchInstanceError: (error) ->
        # TODO: Handle error properly
        console.error error


    updateInstance: (data) ->
        Object.assign @instance.attributes, data

        headers = new Headers()
        headers.append 'Host', 'alice.example.com'
        headers.append 'Accept', 'application/vnd.api+json'
        headers.append 'Content-type', 'application/vnd.api+json'
        # headers.append 'Cookie', 'sessionid=xxxxx'
        headers.append 'Authorization', 'Bearer settings-token'

        return fetch "#{window.location.protocol}//#{@domain}/settings/instance",
            method: 'PUT',
            headers: headers,
            # Authentify
            credentials: 'include',
            body: JSON.stringify data: @instance


    savePassphrase: (passphrase) ->
        headers = new Headers()
        headers.append 'Content-type', 'application/json'
        return fetch "#{window.location.protocol}//#{@domain}/settings/passphrase",
            headers: headers,
            method: 'POST',
            credentials: 'include',
            body: JSON.stringify \
                  passphrase: passphrase,
                  register_token: @registerToken


    # Star the onboarding, determines to current step and goes to it.
    start: ->
        @instance.attributes.onboardedSteps ?= []
        @currentStep = @activeSteps?.find (step) =>
            return not (step.name in @instance.attributes.onboardedSteps)

        @currentStep ?= @activeSteps[0]

        @goToStep @currentStep


    # Records handler for 'stepChanged' pseudo-event, triggered when
    # the internal current step in onboarding has changed.
    onStepChanged: (callback) ->
        throw new Error 'Callback parameter should be a function' \
            unless typeof callback is 'function'
        @stepChangedHandlers = (@stepChangedHandlers or []).concat callback


    onStepFailed: (callback) ->
        throw new Error 'Callback parameter should be a function' \
            unless typeof callback is 'function'
        @stepFailedHandlers = (@stepFailedHandlers or []).concat callback


    onDone: (callback) ->
        throw new Error 'Callback parameter should be a function' \
            unless typeof callback is 'function'
        @onDoneHandler = (@onDoneHandler or []).concat callback


    # Handler for 'stepSubmitted' pseudo-event, triggered by a step
    # when it has been successfully submitted
    # Maybe validation should be called here
    # Maybe we will return a Promise or call some callbacks in the future.
    handleStepCompleted: (step, data) =>
        @instance = Object.assign {}, @instance, data
        @goToNext()


    # Go to the next step in the list.
    goToNext: () ->
        currentIndex = @activeSteps.indexOf(@currentStep)

        if @currentStep? and currentIndex is -1
            throw Error 'Current step cannot be found in steps list'

        # handle magically the case not @currentStep and currentIndex is -1.
        nextIndex = currentIndex+1

        if @activeSteps[nextIndex]
            @goToStep @activeSteps[nextIndex]
        else
            @triggerDone()


    # Go directly to a given step.
    goToStep: (step) ->
        @currentStep = step
        step.fetchData(@instance)
            .then @triggerStepChanged, @triggerStepErrors


    # Trigger a 'StepChanged' pseudo-event.
    triggerStepChanged: (step) =>
        if @stepChangedHandlers
            @stepChangedHandlers.forEach (handler) =>
                handler @, step


    handleStepError: (step, err) =>
        @currentStep = step
        @currentError = err
        @triggerStepErrors step, err


    # Trigger a 'StapFailed' pseudo-event
    triggerStepErrors: (step, err) =>
        if @stepFailedHandlers
            @stepFailedHandlers.forEach (handler) ->
                handler step, err


    # Trigger a 'done' pseudo-event, corresponding to onboarding end.
    triggerDone: (err)->
        if @onDoneHandler
            @onDoneHandler.forEach (handler) ->
                handler err


    # Returns an internal step by its name.
    getStepByName: (stepName) ->
        return @activeSteps.find (step) ->
            return step.name is stepName


    # Returns progression associated to the given step object
    # @param step Step which we want to know the related progression
    # returns the current index of the step, from 1 to length. 0 if the step
    # does not exist in the onboarding.
    getProgression: (step) ->
        return \
            current: @activeSteps.indexOf(step)+1,
            total: @activeSteps.length,
            labels: @activeSteps.map (step) -> step.name


    # Returns next step for the given step. Useful for knowing wich route to
    # use in a link-to-next.
    getNextStep: (step) ->
        if not step
            throw new Error 'Mandatory parameter step is missing'

        stepIndex = @activeSteps.indexOf step

        if stepIndex is -1
            throw new Error 'Given step missing in onboarding step list'

        nextStepIndex = stepIndex+1

        if nextStepIndex is @activeSteps.length
            return null

        return @activeSteps[nextStepIndex]


    getCurrentStep: () =>
        return @currentStep


    isStatsAgreementHidden: -> false


# Step is exposed for test purposes only
module.exports.Step = Step
