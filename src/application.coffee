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


fetchApps = (domain) ->

    headers = new Headers()
    headers.append('Accept', 'application/vnd.api+json')

    return fetch "#{domain}/apps/",
      method: 'GET'
      headers: headers
    .then (response) ->
        if response.ok and response.status is 200
            return response.json().then (responseJson) ->
              return responseJson.data
        else
            throw Error('Cannot fetch apps')
    .catch (error) ->
        console.error error


class App extends Application

    # Application to redirect to when onboarding process is complete
    targetApplication: 'io.cozy.manifests/files'
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
        @showStep onboarding, step


    # Internal handler called when the onboarding is finished
    # Redirect to given app
    handleTriggerDone: () ->
        url = "#{window.location.protocol}//#{@domain}"
        fetchApps(url)
          .then (apps) =>
              app = apps.find (app) =>
                return app.id is @targetApplication

              if app and app.links and app.links.target
                  window.location.replace app.links.target
              else
                  console.error 'No target Application has been found'


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
