{ World , Entity} = require 'fundams'

class Person extends Entity

    init: ->
        @type = 'person'

    round_announce: (world) =>
        coins = (x for x in world.stuff when x.type == 'coin')
        coin = coins[Math.floor(coins.length*Math.random())]
        action = type: 'take', who: this, what: coin
        @actions.push Object.create action, func: value: @take
        coin.actions.push action

    take: (action) =>
        if action.fail
            @output "#{@name or @type}: i couldn't take a #{action.what.type}"
        else
            @output "#{@name or @type}: i took a #{action.what.type}"


class Coin extends Entity

    init: ->
        @type = 'coin'

    round_counter: =>
        takes = []
        for action in @actions
            if action.type == 'take'
                takes.push action

        if takes.length > 1
            for take in takes
                take.fail = true
            @actions.push { takes, type: 'prevent take', func: @prevent_take }

    prevent_take: (action) =>
        @output "#{@name or @type}: *evil laughter* hahahar"

p1 = new Person
p2 = new Person
coin = new Coin name: 'coin 1'

p2.name = 'other person'

world = new World

console.log '\n# setting with one person and a coin'
world.stuff = [p1, coin]
world.play_round()

console.log '\n# setting with two persons and a coin'
world.stuff = [p1, p2, coin]
world.play_round()

console.log '\n# setting with two persons and two coins'
world.stuff = [p1, p2, coin, new Coin name: 'coin 2']
world.play_round()

console.log ''
