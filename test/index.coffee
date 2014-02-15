# Imports
CoStates = require '..'
assert = require 'assert'

# Globals for holding state machine instance and blueprint
trafficLights = null
blueprint = null

# Utils
_ =
  isFunction: (obj) -> typeof obj is 'function'
  pluck: (arr, prop) -> (obj[prop] for obj in arr)

module.exports =
  'Co-states':
    'Usage':
      'A state machine can be initialized by passing a blueprint of
      possible states and the corresponding events for the states': ->
        ### A simple traffic light as a state machine implementation. ###

        blueprint = [
          {
            state: 'red'
            events: {
              go: 'green'
            }
          }
          {
            state: 'yellow'
            events: {
              stop: 'red'
            }
          }
          {
            state: 'green'
            events: {
              warn: 'yellow'
            }
          }
        ]

        trafficLights = new CoStates blueprint
        assert trafficLights instanceof CoStates

      'New instances are automatically initialized with
      the first state in the blueprint': ->

        defaultState = blueprint[0].state  # RED
        assert.equal defaultState, trafficLights.getState()

      'Functions of the same name as the events in the blueprint
      are added to the instance': ->

        ### Get event list from blueprint. ###
        events = []
        eventList = _.pluck blueprint, 'events'

        eventList.forEach (set) ->
          events = events.concat Object.keys set

        ### Check that functions are present. ###
        events.forEach (event) ->
          assert _.isFunction trafficLights[event]

      'These functions change the machine state according to
      the blueprint': (callback) ->

        ###
        A 'state:change' event is triggered on the state
        machine when state is changed. The current state
        and the next state are passed as extra parameters.
        ###

        trafficLights.on 'state:change', (current, next) ->
          callback assert.equal next, 'green'

          ### Reset machine. ###
          trafficLights = new CoStates blueprint

        ### Trigger state change. ###
        trafficLights.go()

      'State can also be changed by triggering an event on
      the machine by the same name as the blueprint event.': (callback) ->

        trafficLights.on 'state:change', (current, next) ->
          callback assert.equal next, 'green'

          ### Reset machine. ###
          trafficLights = new CoStates blueprint

        ### Trigger state change. ###
        trafficLights.trigger 'go'
