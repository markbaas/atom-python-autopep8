PythonAutopep8 = require './python-autopep8'

module.exports =
  config:
    autopep8Path:
      type: 'string'
      default: 'autopep8'
    formatOnSave:
      type: 'boolean'
      default: false
    maxLineLength:
      type: 'integer'
      default: 100
    grammars:
      type: 'array'
      default: ["Python"]
    cmdLineOptions:
      type: 'array'
      default: []
      description:
          "Cmd line switches passed to autopep8 delimited by commas
          (e.g. '-a, -a, --experimental')"

  activate: ->
    pi = new PythonAutopep8()

    atom.commands.add 'atom-workspace', 'pane:active-item-changed', ->
      pi.removeStatusbarItem()

    atom.commands.add 'atom-workspace', 'python-autopep8:format', ->
      pi.format()

    atom.config.observe 'python-autopep8.formatOnSave', (value) ->
      atom.workspace.observeTextEditors (editor) ->
        if value == true
          editor._autopep8Format = editor.onDidSave -> pi.format()
        else
          editor._autopep8Format?.dispose()
