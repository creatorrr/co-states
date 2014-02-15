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
      the machine by the same name as the blueprint event': (callback) ->

        trafficLights.on 'state:change', (current, next) ->
          callback assert.equal next, 'green'

          ### Reset machine. ###
          trafficLights = new CoStates blueprint

        ### Trigger state change. ###
        trafficLights.trigger 'go'

      'State machine will throw an error if an invalid event
      is triggered': (callback) ->

        ###
          An 'error' event is triggered when an invalid state
          event is attempted. An <Error> object is passed
          along with a helpful message.
        ###

        trafficLights.on 'error', (e) ->
          callback assert e instanceof Error

        ### Trigger invalid event 'stop' for state 'red'. ###
        trafficLights.stop()

      'Co-states extends co-events so callbacks for events can
      be anything that co supports': (callback) ->

        ### Generators FTW! ###
        trafficLights.on 'state:change', (__, next) ->*
          yield -> callback null

        trafficLights.go()
