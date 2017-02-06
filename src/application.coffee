###
application

Main application that create a Mn.Application singleton and exposes it. Needs
router and app_layout view.
###
_        = require 'underscore'
{Application} = require 'backbone.marionette'

AppLayout = require './views/app_layout'

Onboarding = require './lib/onboarding'
StepModel = require './models/step'
ProgressionModel = require './models/progression'

class App extends Application

    # URL for the redirection when the onboarding is finished
    endingRedirection: '/'
    accountsStepName: 'accounts'
    agreementStepName: 'agreement'
    ###
    Sets application

    We instanciate root application components
    - router: we pass the app reference to it to easily get it without requiring
              application module later.
    - layout: the application layout view, rendered.
    ###
    initialize: ->
        AppStyles = require './styles/app.styl'

        @on 'start', (options)=>
            @initializeRouter registerToken: options.registerToken
            @layout = new AppLayout()
            @layout.render()

            # Use pushState because URIs do *not* rely on fragment (see
            # `server/controllers/routes.coffee` file)
            Backbone.history.start pushState: true if Backbone.history
            Object.freeze @ if typeof Object.freeze is 'function'


    # Initialize routes relative to onboarding step.
    # The idea is to configure the router externally as a "native"
    # Backbone Router
    initializeRouter: (options) =>
        @router = new Backbone.Router()

        @router.route \
            '',
            'default',
            => @handleDefaultRoute registerToken: options.registerToken

        # if onboarding, the pathname will be '/register*'
        @router.route \
            'register(/:step)',
            'register',
            @handleRegisterRoute

        @router.route \
            'login(?next=*path)',
            'login',
            @handleLogin
        @router.route \
            'login(/*path)',
            'login',
            @handleLogin
        @router.route \
            'password/reset/:key',
            'resetPassword',
            @handleResetPassword


    # Handle default route
    handleDefaultRoute: (options) =>
      @initializeOnboarding options
        .then (onboarding) =>
          onboarding.start()


    # Internal handler called when the onboarding's internal step has just
    # changed.
    # @param step Step instance
    handleStepChanged: (onboarding, step) ->
        @showStep onboarding, step


    # Internal handler called when the onboarding is finished
    handleTriggerDone: () ->
        window.location.replace @endingRedirection


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
            registerToken: options.registerToken,
            onStepChanged: (onboarding, step) => @handleStepChanged(onboarding, step),
            onStepFailed: (step, err) => @handleStepFailed(step, err),
            onDone: () => @handleTriggerDone()


    # Handler for register route, display onboarding's current step
    handleRegisterRoute: =>
        @onboarding ?= @initializeOnboarding()

        # Load onboarding stylesheet
        AppStyles = require './styles/app.styl'

        currentStep = @onboarding.getCurrentStep()
        @router.navigate currentStep.route
        @onboarding.goToStep(currentStep)


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
