{ World , Entity} = require 'fundams'

output = console.log

class Person extends Entity

    init: ->
        @type = 'person'

    play_round: (world) =>
        coins = (x for x in world.stuff when x.type == 'coin')
        coin = coins[Math.floor(coins.length*Math.random())]
        [ { type: 'take', what: coin, who: this } ]

    take_fail: (take) =>
        output "#{@name or @type}: i couldn't take a #{take.what.type}"

    take_win: (take) =>
        output "#{@name or @type}: i took a #{take.what.type}"


class Coin extends Entity

    init: ->
        @type = 'coin'

    take_fail: (take) =>
        output "#{@name or @type}: *evil laughter* hahahar"

p1 = new Person
p2 = new Person
coin = new Coin name: 'coin 1'

p2.name = 'other person'

world = new class extends World

    init: ->
        @rules = { @take }

    prepare: (announcements) =>
        takes = []
        for a in announcements
            if a.type == 'take'
                takes.push a
        announcements.takes = takes

    take: ({ takes }) =>
        actions = []
        taken = {}
        for take in takes
            (taken[take.what.id] = taken[take.what.id] or []).push take
        for _, takes of taken
            if takes.length > 1
                actions.push [ @take_fail, takes... ]
            else
                actions.push [ @take_win, takes[0] ]
        actions

    take_fail: (takes...) =>
        for take in takes
            take.who.take_fail take
        takes[0].what.take_fail take

    take_win: (take) =>
        take.who.take_win take

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

