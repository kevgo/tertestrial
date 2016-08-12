require! {
  'chalk' : {bold, cyan, red}
  'child_process' : {spawn}
  './helpers/error-message' : {error}
  './helpers/file-type'
  './helpers/fill-template'
  './helpers/reset-terminal'
  'prelude-ls' : {filter, find, sort-by}
  'util'
}


# Runs commands sent from the editor
class CommandRunner

  (@config) ->

    # the currently activated action set
    @current-action-set = @config.actions[0]

    # the last test command that was sent from the editor
    @current-command = ''


  run-command: (command) ~>
    reset-terminal!

    if command.action-set
      @set-actionset command.action-set
      return

    if command.operation is 'repeatLastTest'
      if @current-command?.length is 0 then return error "No previous test run"
      unless template = @_get-template(@current-command) then return error "cannot find a template for '#{command}'"
      @_run-test fill-template(template, @current-command)
      return

    unless template = @_get-template(command) then return error "no matching action found for #{JSON.stringify command}"
    @current-command = command
    @_run-test fill-template(template, command)


  # Returns the actions in the current action set
  _current-actions: ->
    for key, value of @current-action-set
      return value



  # Returns the string template for the given command
  _get-template: (command) ~>
    if (matching-actions = @_get-matching-actions command).length is 0
      return null
    matching-actions[*-1].command


  # Returns all actions that match the given command
  _get-matching-actions: (command) ->
    @_current-actions!
      |> filter @_is-match(_, command)
      |> sort-by (.length)


  _action-has-empty-match: (action) ->
    !action.match


  # Returns whether the given action is a match for the given command
  _is-match: (action, command) ->

    # Make sure non-empty commands don't match generic actions
    if @_is-non-empty-command(command) and @_action-has-empty-match(action) then return false

    for key, value of action.match
      if !action.match[key]?.exec command[key] then return false
    true


  _is-non-empty-command: (command) ->
    Object.keys(command).length > 0


  _run-test: (command) ->
    console.log bold "#{command}\n"
    spawn 'sh' ['-c', command], stdio: 'inherit'


  set-actionset: (action-set-id) ->
    switch type = typeof! action-set-id

      case 'Number'
        unless new-actionset = @config.actions[action-set-id - 1]
          return error "action set #{cyan action-set-id} does not exist"
        console.log "Activating action set #{cyan Object.keys(new-actionset)[0]}"
        @current-action-set = new-actionset

      case 'String'
        console.log @config.actions
        console.log find
        new-actionset = @config.actions |> find (action-set) -> Object.keys(action-set)[0] is action-set-id
        unless new-actionset
          return error "action set #{cyan action-set-id} does not exist"
        console.log "Activating action set #{cyan action-set-id}"
        @current-action-set = new-actionset

      default
        error "unsupported action-set id type: #{type}"



module.exports = CommandRunner
