{View} = require 'atom'

module.exports =
class YoView extends View
  @content: ->
    @div class: 'yo overlay from-top', =>
      @div '> ', class: "message"

  initialize: (serializeState) ->
    atom.workspaceView.command "yo:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
