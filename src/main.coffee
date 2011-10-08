p = (xs...) -> console.log xs...; xs[-1..]

class World

    constructor: ->
        @stuff = []

    play_round: =>
        for x in @stuff
            x.play_round @stuff
        next_stuff = []
        all_actions = []
        for x in @stuff
            { remove, actions } = x.end_round() or {}
            if actions
                all_actions.push actions...
            if !remove
                next_stuff.push x
        for action in all_actions
            action[0] action[1..]...
        @stuff = next_stuff

    filter: (func) =>
        x for x in @stuff when func x

class Entity

    constructor: ->
        @type = 'something'
        @actions = []
        @init?()

class Person extends Entity

    init: ->
        @type = 'person'

    play_round: (world) =>
        coins = world.filter (x) -> x.type == 'coin'
        for coin in coins
            action = type: 'take', who: this, what: coin
            @actions.push action
            coin.actions.push action

    end_round: =>
        actions = []
        while action = @actions.pop()
            if action.type == 'take'
                actions.push [ @take, action ]
        { actions }

    take: (action) =>
        if action.fail
            console.log "#{@name or @type}: i couldn't take a #{action.what.type}"
        else
            console.log "#{@name or @type}: i took a #{action.what.type}"


class Coin extends Entity

    init: ->
        @type = 'coin'

    play_round: (world) =>

    end_round: =>
        actions = []
        takes = []
        while action = @actions.pop()
            if action.type == 'take'
                takes.push action

        if takes.length > 1
            for take in takes
                take.fail = true
            action = { takes, type: 'prevent take' }
            actions.push [ @prevent_take, action ]
        { actions }

    prevent_take: (action) =>
        console.log "#{@name or @type}: *evil laughter* hahahar"

p1 = new Person
p2 = new Person
coin = new Coin

p2.name = 'other person'

world = new World

console.log 'setting with one person and a coin'
world.stuff.push p1, coin
world.play_round()

console.log ''

console.log 'setting with two persons and a coin'
world.stuff.push p2
world.play_round()

