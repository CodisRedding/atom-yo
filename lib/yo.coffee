req = require 'request'
yoview = require './yo-view'
view = new yoview()

module.exports =
  configDefaults:
    yoApiKey: ""

  activate: ->
    atom.workspaceView.command "yo:yo", => @yo()
    atom.workspaceView.command "yo:count", => @count()
    atom.workspaceView.command "yo:yoall", => @yoall()
    atom.workspaceView.command "yo:yolink", => @yolink()

  yo: ->
    editor = atom.workspace.activePaneItem
    selection = editor.getSelection()

    req.post "http://api.justyo.co/yo",
      form:
        api_token: atom.config.get('yo.yoApiKey')
        username: selection.getText()

    @set 'sent yo! [' + selection.getText() + ']', 2000

  yolink: ->
    editor = atom.workspace.activePaneItem
    selection = editor.getSelection()
    parts = selection.getText().split(' ')
    self = this
    req.post "http://api.justyo.co/yo",
      form:
        api_token: atom.config.get('yo.yoApiKey')
        username: parts[0]
        link: parts[1],
      optionalCallback = (err, httpResponse, body) ->
        if err || body == null || body.contains('Rate limit exceeded') || body.contains('error')
          self.set 'error: ' + body, 2000
          return
        console.log 'body: ' + body
        self.set 'sent yo w/' + parts[1] + ' to ' + parts[0], 2000

  yoall: ->
    self = this
    req.post "http://api.justyo.co/yoall",
      form:
        api_token: atom.config.get('yo.yoApiKey'),
      optionalCallback = (err, httpResponse, body) ->
        if err || body == null || body.contains('Rate limit exceeded') || body.contains('error')
          self.set 'error: ' + body, 2000
          return
        self.set 'sent yo to all!', 2000

  count: ->
    self = this
    req.get "http://api.justyo.co/subscribers_count?api_token=" + atom.config.get('yo.yoApiKey'),
      optionalCallback = (err, httpResponse, body) ->
        return console.error err if err
        console.log (JSON.parse(body)).result
        self.set 'subscribers: ' + (JSON.parse(body)).result, 2000

  set: (msg, to) ->
    atom.workspaceView.statusBar?.appendLeft('<span class="status-class">' + msg + '</span>')
    setTimeout @clear, to

  clear: ->
    atom.workspaceView.statusBar?.find('.status-class').remove()
