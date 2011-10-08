class World

    constructor: ->
        @stuff = []

    play_round: =>
        for x in @stuff
            x.round_announce? this
        for x in @stuff
            x.round_counter?()
        next_stuff  = []
        for x in @stuff
            if !x.round_complete?()
                next_stuff.push x
        @stuff = next_stuff

class Entity

    constructor: (attrs) ->
        @type = 'something'
        @actions = []
        @output = console.log
        for attr, v of attrs
            this[attr] = v
        @init?()

    round_complete: =>
        remove = false
        while action = @actions.pop()
            action.func? action
            remove = true if action.remove == true
        remove

module.exports = { World, Entity }

