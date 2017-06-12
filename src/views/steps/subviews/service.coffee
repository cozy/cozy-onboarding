{ItemView} = require 'backbone.marionette'
_ = require 'underscore'

ModalView = require '../../modal'

module.exports = class ServiceView extends ItemView
    template: require '../../templates/service'

    className: 'service'

    ui:
        connect: '.connect'
        actions: '.service-actions'
        result: '.service-success .result'

    events:
      'click .connect': 'onConnect'


    initialize: (options) ->
        @slug = options.slug

        @onIntentStart = () =>
            if typeof options.onIntentStart is 'function'
                options.onIntentStart()

        @onIntentSuccess = (doc) =>
            if typeof options.onIntentSuccess is 'function'
                options.onIntentSuccess doc

        @onIntentError = (error) =>
            if typeof options.onIntentError is 'function'
                options.onIntentError error

        @onIntentEnd = () =>
            if typeof options.onIntentEnd is 'function'
                options.onIntentEnd()


    serializeData: () ->
        _.extend super,
            name: "step #{@slug} service",
            service: "service-logo--#{@slug}",
            figureid: require "../../../assets/sprites/#{@slug}.svg"


    onConnect: () ->
        @onIntentStart()
        @setBusy true

        modal = new ModalView \
            onHide: () =>
                @onIntentEnd()
                @setBusy false


        cozy.client.intents
            .create 'CREATE', 'io.cozy.accounts', slug: @slug
            .start modal.getContentWrapper()
            .then (account) =>
                modal.hide()
                if account
                  @showSuccess account
                  @onIntentSuccess account
                else
                  @onIntentEnd null
            .catch (error) =>
                modal.hide()
                @onIntentError error
            .then () =>
                @setBusy false


    setBusy: (busy) ->
        if busy
            @disableConnect()
            @ui.connect.attr 'aria-busy', true
        else
            @enableConnect()
            @ui.connect.removeAttr 'aria-busy'


    enableConnect: () ->
        @ui.connect.removeAttr 'disabled'
        @ui.connect.removeAttr 'aria-disabled'


    disableConnect: () ->
        @ui.connect.attr 'disabled', 'disabled'
        @ui.connect.attr 'aria-disabled', 'true'

    showSuccess: (account) ->
        @ui.actions.hide()
        @ui.result.text(if account.auth then account.auth.login else t('service connected'))
        @$el.addClass('done')
