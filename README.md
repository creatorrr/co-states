# TOC
   - [Co-states](#co-states)
     - [Usage](#co-states-usage)
<a name=""></a>
 
<a name="co-states"></a>
# Co-states
<a name="co-states-usage"></a>
## Usage
A state machine can be initialized by passing a blueprint of possible states and the corresponding events for the states.

```js
/* A simple traffic light as a state machine implementation. */
          blueprint = [
            {
              state: 'red',
              events: {
                go: 'green'
              }
            }, {
              state: 'yellow',
              events: {
                stop: 'red'
              }
            }, {
              state: 'green',
              events: {
                warn: 'yellow'
              }
            }
          ];
          trafficLights = new CoStates(blueprint);
          return assert(trafficLights instanceof CoStates);
```

New instances are automatically initialized with the first state in the blueprint.

```js
var defaultState;
defaultState = blueprint[0].state;
return assert.equal(defaultState, trafficLights.getState());
```

Functions of the same name as the events in the blueprint are added to the instance.

```js
/* Get event list from blueprint. */
          var eventList, events;
          events = [];
          eventList = _.pluck(blueprint, 'events');
          eventList.forEach(function(set) {
            return events = events.concat(Object.keys(set));
          });
          /* Check that functions are present. */
          return events.forEach(function(event) {
            return assert(_.isFunction(trafficLights[event]));
          });
```

These functions change the machine state according to the blueprint.

```js
/*
            A 'state:change' event is triggered on the state
            machine when state is changed. The current state
            and the next state are passed as extra parameters.
           */
          trafficLights.on('state:change', function(current, next) {
            callback(assert.equal(next, 'green'));
            /* Reset machine. */
            return trafficLights = new CoStates(blueprint);
          });
          /* Trigger state change. */
          return trafficLights.go();
```

State can also be changed by triggering an event on the machine by the same name as the blueprint event.

```js
trafficLights.on('state:change', function(current, next) {
  callback(assert.equal(next, 'green'));
  /* Reset machine. */
  return trafficLights = new CoStates(blueprint);
});
/* Trigger state change. */
return trafficLights.trigger('go');
```

State machine will throw an error if an invalid event is triggered.

```js
/*
            An 'error' event is triggered when an invalid state
            event is attempted. An <Error> object is passed
            along with a helpful message.
           */
          trafficLights.on('error', function(e) {
            return callback(assert(e instanceof Error));
          });
          /* Trigger invalid event 'stop' for state 'red'. */
          return trafficLights.stop();
```

Co-states extends co-events so callbacks for events can be anything that co supports.

```js
/* Generators FTW! */
          trafficLights.on('state:change', function*(__, next) {
            return yield function() {
              return callback(null);
            };
          });
          return trafficLights.go();
```

