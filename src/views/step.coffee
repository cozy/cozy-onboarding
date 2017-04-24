{LayoutView} = require 'backbone.marionette'
Backbone = require 'backbone'

ProgressionView = require './steps/subviews/progression'


module.exports = class StepView extends LayoutView

    regions:
        progression: '.progression'

    ui:
        errors: '.errors'


    initialize: (options) ->
        super(options)

        @error = options.error

        @progressionView = new ProgressionView \
            model: options.progression


    onRender: () ->
        @showChildView 'progression', @progressionView

    # disable submit button and store state into @isSubmitDisabled.
    disableSubmit: () ->
        @isSubmitDisabled = true
        @$submit ?= @$ '.next'

        @$submit?.attr \
            'aria-disabled': true,
            'disabled': 'disabled'


    # enable submit button and store state into @isSubmitDisabled.
    enableSubmit: () ->
        @isSubmitDisabled = false
        @$submit ?= @$ '.next'

        @$submit
            .removeAttr 'aria-disabled'
            .removeAttr 'disabled'


    showError: (error) ->
        @ui.errors.html t if error and error.message then error.message else error
        @ui.errors.show()


    hideError: () ->
        @ui.errors.hide()
