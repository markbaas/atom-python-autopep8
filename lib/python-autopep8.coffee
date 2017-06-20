$ = require 'jquery'
process = require 'child_process'

module.exports =
class PythonAutopep8

  checkForPythonContext: ->
    editor = atom.workspace.getActiveTextEditor()
    if not editor?
      return false
    grammar = editor.getGrammar().name
    return grammar == 'Python' or grammar == 'MagicPython'

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

  format: ->
    if not @checkForPythonContext()
      return

    cmd = atom.config.get "python-autopep8.autopep8Path"
    maxLineLength = atom.config.get "python-autopep8.maxLineLength"
    cmdLineOptions = atom.config.get "python-autopep8.cmdLineOptions"
    params = cmdLineOptions.concat [
        "--max-line-length", maxLineLength, "-i", @getFilePath()
    ]

    returnCode = process.spawnSync(cmd, params).status
    if returnCode != 0
      @updateStatusbarText("x", true)
    else
      @updateStatusbarText("√", false)
      @reload
