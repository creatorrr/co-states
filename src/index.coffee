# Deps
co = require 'co'
Events = require 'co-events'

# Utils
_ =
  # Pick properties
  pick: (obj, props) ->
    result = {}
    result[k] = obj[k] for k in props when obj[k]?

    result

  pluck: (arr, prop) ->
    (obj[prop] for obj in arr)

  # Return array with unique elements
  uniq: (arr) ->
    seen = new Set

    for e in arr when not seen.has e
      seen.add e
      e

  # 1-level flatten
  flatten: (arr) ->
    a = []
    for e in arr
      if e.length then a = a.concat e else a.push e

    a

  # Extend objects
  extend: (dest, src) ->
    dest[k] = v for own k, v of src
    dest

# State Machine
class StateMachine extends Events
  # -- Private --
  _setState: (next) ->
    unless next?
      return @_throw "Invalid state '#{ next }'"

    current = @getState()
    @_state = next+''
    @trigger 'state:change', current, next

    next

  _throw: (error) ->
    error = new Error error
    @trigger 'error', error
    error

  _addStates: (states) ->
    # Add to blueprint
    for {state, events} in states
      @_blueprint[state] = events

    # Add events to machine
    for event in _.uniq _.flatten (_.pluck states, 'events').map Object.keys
      this[event] = do =>
        e = event

        return =>
          @_triggerEvent e
          this

  _triggerEvent: (event) ->
    # Get current state and find out if event allowed
    current = @getState()
    next = @_blueprint[current]?[event]

    # Set next state
    if next?
      @_setState next

    else
      @_throw "Invalid event '#{ event }' for current state '#{ current }'"
      false

  # -- Public --
  constructor: (states) ->
    # List of states and events to initialize machine
    # Ex: [
    #   {
    #     state: 'blah',
    #     events: {
    #       'someEvent': 'newState'
    #     }
    #   },
    #   { ... }
    # ]

    super

    # Add events for corresponding states
    @_blueprint = {}
    @_addStates states

    # Start
    @_setState states[0].state if states[0]

  # Get surrent state
  getState: -> @_state ? null

  # Override trigger to run machine events
  trigger: (event, args...) ->
    if handler = this[event]?
      handler.apply this, args

    else
      super event, args...

    this

# Exports
module.exports = StateMachine
