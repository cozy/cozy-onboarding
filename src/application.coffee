###
application

Main application that create a Mn.Application singleton and exposes it. Needs
router and app_layout view.
###
_ = require 'underscore'
{Application} = require 'backbone.marionette'

AppLayout = require './views/app_layout'

Onboarding = require './lib/onboarding'
StepModel = require './models/step'
ProgressionModel = require './models/progression'


class App extends Application

    accountsStepName: 'accounts'
    agreementStepName: 'agreement'
    ###
    Sets application

    We instanciate root application components
    - layout: the application layout view, rendered.
    ###
    initialize: ->
        AppStyles = require './styles/app.styl'

        applicationElement = document.querySelector '[role=application]'

        @contextToken = applicationElement.dataset.token
        @domain = applicationElement.dataset.cozyStack

        if (@contextToken)
          cozy.client.init \
            cozyURL: "//#{@domain}",
            token: @contextToken

        try
            @tracker = Piwik.getTracker(__PIWIK_TRACKER_URL__, __PIWIK_SITEID__)
            @tracker.enableHeartBeatTimer()
            userId = @domain
            indexOfPort = userId.indexOf(':')
            if indexOfPort >= 0 then userId = userId.substring(0, indexOfPort)
            @tracker.setUserId(userId)
            @tracker.setCustomDimension(__PIWIK_DIMENSION_ID_APP__, applicationElement.dataset.cozyAppName)
        catch error
          console.warn and console.warn 'Unable to initialize Piwik.'


        @on 'start', (options)=>
            @layout = new AppLayout()
            @layout.render()

            # Use pushState because URIs do *not* rely on fragment (see
            # `server/controllers/routes.coffee` file)
            Backbone.history.start pushState: false if Backbone.history
            Object.freeze @ if typeof Object.freeze is 'function'

            @handleDefaultRoute registerToken: options.registerToken


    # Handle default route
    handleDefaultRoute: (options) =>
      @initializeOnboarding options
        .then (onboarding) =>
          onboarding.start()


    # Internal handler called when the onboarding's internal step has just
    # changed.
    # @param step Step instance
    handleStepChanged: (onboarding, step) ->
        if (@tracker)
            @tracker.setCustomUrl step.name
            @tracker.trackPageView()

        @showStep onboarding, step


    # Internal handler called when the onboarding is finished
    # Redirect to given app
    handleTriggerDone: () =>
        # default app redirection is handled by the stack
        window.location.replace "//#{@domain}/settings/onboarded"


    # Update view with error message
    # only if view is still displayed
    # otherwhise dispatch the error in console
    handleStepFailed: (step, err) ->
        if @onboarding.currentStep isnt step
            console.error err.stack
        else
            @showStep step, err.message


    # Initialize the onboarding component
    initializeOnboarding: (options)->
        steps = require './config/steps/all'

        onboarding = new Onboarding()

        return onboarding.initialize \
            steps: steps,
            domain: @domain,
            contextToken: @contextToken,
            registerToken: options.registerToken,
            onStepChanged: (onboarding, step) => @handleStepChanged(onboarding, step),
            onStepFailed: (step, err) => @handleStepFailed(step, err),
            onDone: () => @handleTriggerDone()


    # Load the view for the given step
    showStep: (onboarding, step, err=null) =>
        StepView = require "./views/#{step.view}"
        nextStep = onboarding.getNextStep step
        next = nextStep?.route or @endingRedirection

        stepView = new StepView
            model: new StepModel step: step, next: next
            error: err
            progression: new ProgressionModel \
                onboarding.getProgression step

        if step.name is @accountsStepName
            stepView.on 'browse:myaccounts', @handleBrowseMyAccounts

        # Make this code better, maybe internalize into stepModel a way of
        # retrieving data related to the step.
        if step.name is @agreementStepName and onboarding.isStatsAgreementHidden()
            stepView.disableStatsAgreement()

        @layout.showChildView 'content', stepView


    # Handler when browse action is submited from the Accounts step view.
    # This handler show a dedicated view that encapsulate an iframe loading
    # MyAccounts application.
    handleBrowseMyAccounts: (stepModel) =>
        MyAccountsView = require './views/onboarding/my_accounts'
        view = new MyAccountsView
            model: stepModel
            myAccountsUrl: ENV.myAccountsUrl
        @layout.showChildView 'content', view


# Exports Application singleton instance
module.exports = new App()
