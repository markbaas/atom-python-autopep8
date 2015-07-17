fs = require 'fs'
$ = require 'jquery'
process = require 'child_process'
{BufferedProcess} = require 'atom'

module.exports =
class PythonAutopep8

  checkForPythonContext: ->
    editor = atom.workspace.getActiveTextEditor()
    if not editor?
      return false
    return editor.getGrammar().name == 'Python'

  removeStatusbarItem: =>
    @statusBarTile?.destroy()
    @statusBarTile = null

  updateStatusbarText: (message, isError) =>
    if not @statusBarTile
      statusBar = document.querySelector("status-bar")
      return unless statusBar?
      @statusBarTile = statusBar
        .addLeftTile(
          item: $('<div id="status-bar-python-autopep8" class="inline-block">
                    <span style="font-weight: bold">Autopep8: </span>
                    <span id="python-autopep8-status-message"></span>
                  </div>'), priority: 100)

    statusBarElement = @statusBarTile.getItem()
      .find('#python-autopep8-status-message')

    if isError == true
      statusBarElement.addClass("text-error")
    else
      statusBarElement.removeClass("text-error")

    statusBarElement.text(message)

  getFilePath: ->
    editor = atom.workspace.getActiveTextEditor()
    return editor.getPath()

  runCommand: ->
    filePath = @getFilePath()
    maxLineLength = atom.config.get "python-autopep8.maxLineLength"
    new Promise (resolve, reject) ->
      data = null
      process = new BufferedProcess
        command: atom.config.get "python-autopep8.autopep8Path"
        args: ["--max-line-length", maxLineLength, "-i", filePath]
        stdout: (out) -> data = out
        exit: =>
          resolve data

      process.onWillThrowError ({handle}) ->
        handle()
        resolve()

  format: ->
    if not @checkForPythonContext()
      return

    editor = atom.workspace.getActiveTextEditor()
    curpos = editor.getCursorBufferPosition()
    self = this
    @runCommand().then (data) ->
      self.updateStatusbarText("√", false)
      self.reload
      editor.setCursorBufferPosition(curpos)
