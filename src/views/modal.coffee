{ItemView} = require 'backbone.marionette'
Backbone = require 'backbone'

key = {
  ESC: 27
}


module.exports = class ModalView extends ItemView
    template: require './templates/modal'

    ui:
        modalOverlay: '.modal-overlay'
        contentWrapper: '.modal'

    events:
        'click @ui.contentWrapper': 'preventClick'
        'keyup @ui.modalOverlay': 'onKeyUp'


    initialize: (options) ->
        @onHide = options.onHide
        this.render options.item


    getContentWrapper: ->
        return @ui.contentWrapper.get(0)


    onRender: (item) ->
        @document = @el.ownerDocument
        @document.body.appendChild @el

        @document.addEventListener 'keyup', @hide.bind(@)

        contentWrapperElement = @ui.contentWrapper.get(0)

        # Observe and wait content injection before showing the modal
        observer = new MutationObserver (event) =>
            $iframe = @$ 'iframe'
            if $iframe.length
                $iframe.on 'load', (event) =>
                    @show()
            else
                @show()
            observer.disconnect()

        @waiting = true
        observer.observe contentWrapperElement, childList: true


    preventClick: (event) ->
        event.stopPropagation()


    onKeyUp: (event) ->
        if event.keyCode is key.ESC
            hide()


    dispose: () ->
        if not @disposed
          @document.body.removeChild @el
          @disposed = true


    hide: () ->
        return @dispose() unless not @waiting

        @$el.one 'transitionend', () =>
            if typeof @onHide is 'function'
                @onHide()
            @dispose()

        @ui.modalOverlay.attr 'aria-hidden', 'true'

    show: () ->
        @waiting = false
        @ui.modalOverlay.attr 'aria-hidden', 'false'
        @ui.modalOverlay.on 'click', () => @hide()
