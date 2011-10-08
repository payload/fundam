SDL = require 'sdl'
{ World, Entity } = require 'fundams'

pick = (list) -> list[Math.floor list.length*Math.random()]

class Person extends Entity

    init: ->
        @visible = true
        @color ?= 0x00A0A0FF
        @x ?= 0
        @y ?= 0

    play_round: (world) =>
        announces = []
        if Math.random() < 0.5
            x = pick [-1, 0, 1]
            y = if x == 0 then pick [-1, 0, 1] else 0
            announces.push { type: 'move', x, y, who: this }
        announces

SDL.init SDL.INIT.VIDEO
SDL.events.on 'QUIT', (ev) -> process.exit 0
screen = SDL.setVideoMode 600, 400, 32,
    SDL.SURFACE.HWSURFACE | SDL.SURFACE.DOUBLEBUF | SDL.SURFACE.HWACCEL |
    SDL.SURFACE.SRCALPHA

pixelsize = 20

world = new class extends World

    init: ->
        @w ?= 600 / pixelsize
        @h ?= 400 / pixelsize
        @map = {}
        @rules = { @move }

    play_round: =>
        SDL.fillRect screen, [0, 0, screen.w, screen.h], 0xFFFFFFFF
        super
        for _, x of @stuff
            @draw x if x.visible
        SDL.flip screen

    draw: ({ x, y, color }) =>
        s = pixelsize
        SDL.fillRect screen, [x * s, y * s, s, s], color

    in_field: (x, y) =>
        x >= 0 and y >= 0 and x < @w and y < @h

    prepare: (announcements) =>
        moves = []
        for a in announcements
            if a.type == 'move'
                moves.push a
        announcements.moves = moves

    move: ({ moves }) =>
        actions = []

        map = {}
        for move in moves
            x = move.x + move.who.x
            y = move.y + move.who.y
            if @in_field x, y
                coord = x+':'+y
                (map[coord] = map[coord] or []).push move
            else
                actions.push [ @move_fail, move ]

        for _, moves of map
            if moves.length > 1
                for move in moves
                    actions.push [ @move_fail, move ]
            else
                actions.push [ @move_win, moves[0] ]

        actions

    move_win: (move) =>
        move.who.x += move.x
        move.who.y += move.y

    move_fail: (move) =>

do ->
    xs = [0..world.w]
    ys = [0..world.h]

    for [0..30]
        person = new Person
        world.stuff[person.id] = person
        loop
            x = pick xs
            y = pick ys
            if !world.map[x+':'+y]
                world.map[x+':'+y] = person
                person.x = x
                person.y = y
                break

    setInterval world.play_round, 50

