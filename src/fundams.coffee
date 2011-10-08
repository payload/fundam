ID = 0

class Entity

    constructor: (attrs) ->
        @id = ID++
        @type = 'something'
        for attr, v of attrs
            this[attr] = v
        @init?()

class World

    constructor: ->
        @stuff = {}
        @rules = {}
        @init?()

    play_round: =>
        announcements = []
        for _, x of @stuff
            a = x.play_round? this
            announcements.push a... if a?.length
        actions = []
        @prepare? announcements
        for _, rule of @rules
            a = rule announcements
            actions.push a... if a?.length
        for action in actions
            action[0] action[1..]...


module.exports = { World, Entity }

