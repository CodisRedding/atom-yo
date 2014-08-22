req = require 'request'

module.exports =
  clearTime: 5000
  configDefaults:
    yoApiKey: ""

  activate: ->
    atom.workspaceView.command "yo:yo", => @yo()
    atom.workspaceView.command "yo:count", => @count()
    atom.workspaceView.command "yo:yoall", => @yoall()
    atom.workspaceView.command "yo:yolink", => @yolink()

  yo: ->
    editor = atom.workspace.activePaneItem
    username = editor.getSelection().getText()
    self = this
    req.post "http://api.justyo.co/yo",
      form:
        api_token: atom.config.get('yo.yoApiKey')
        username: username
      optionalCallback = (err, httpResponse, body) ->
        if self.hasError err, body
          self.set 'error: ' + body, self.clearTime
          return
        self.set 'sent yo to ' + username, self.clearTime

  yolink: ->
    editor = atom.workspace.activePaneItem
    selection = editor.getSelection()
    parts = selection.getText().split(' ')
    username = parts[0]
    link = parts[1]
    self = this
    req.post "http://api.justyo.co/yo",
      form:
        api_token: atom.config.get('yo.yoApiKey')
        username: username
        link: link
      optionalCallback = (err, httpResponse, body) ->
        if self.hasError err, body
          self.set 'error: ' + body, self.clearTime
          return
        self.set 'sent yo with the link ' + link + ' to ' + username, self.clearTime

  yoall: ->
    self = this
    req.post "http://api.justyo.co/yoall",
      form:
        api_token: atom.config.get('yo.yoApiKey'),
      optionalCallback = (err, httpResponse, body) ->
        if self.hasError err, body
          self.set 'error: ' + body, self.clearTime
          return
        self.set 'sent yo to everyone', self.clearTime

  count: ->
    self = this
    req.get "http://api.justyo.co/subscribers_count?api_token=" + atom.config.get('yo.yoApiKey'),
      optionalCallback = (err, httpResponse, body) ->
        return console.error err if err
        self.set 'subscribers: ' + (JSON.parse(body)).result, self.clearTime

  set: (msg, to) ->
    atom.workspaceView.statusBar?.find('.status-class').remove()
    atom.workspaceView.statusBar?.appendLeft('<span class="status-class">' + msg + '</span>')
    setTimeout @clear, to

  clear: ->
    atom.workspaceView.statusBar?.find('.status-class').remove()

  hasError: (err, body) ->
    return err || body == null || body.contains('Rate limit exceeded') || body.contains('error')
