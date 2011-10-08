SDL = require 'sdl'
{ World, Entity } = require 'fundams'

p = (xs...) -> console.log xs...; xs[-1..][0]
pick = (list) -> list[Math.floor list.length*Math.random()]

NAMES = ['Alice', 'Bob', 'Claire', 'Dave', 'Elenor']

class Person extends Entity

    init: ->
        @name ?= pick NAMES
        @visible = true
        @color ?= 0x00A0A0FF
        @x ?= 0
        @y ?= 0

    play_round: (world) =>
        announces = []
        if Math.random() < 0.5
            x = pick [-1, 0, 1]
            y = if x == 0 then pick [-1, 0, 1] else 0
            if !world.map[(@x+x)+':'+(@y+y)]
                announces.push { type: 'move', x, y, who: this }
        else
            x = @x
            y = @y + 1
            if !world.map[@x+':'+(@y+1)]
                announces.push { type: 'move', x: 0, y: 1, who: this }
        announces

SDL.init SDL.INIT.VIDEO
SDL.events.on 'QUIT', (ev) -> process.exit 0
screen = SDL.setVideoMode 600, 400, 32,
    SDL.SURFACE.HWSURFACE | SDL.SURFACE.DOUBLEBUF | SDL.SURFACE.HWACCEL |
    SDL.SURFACE.SRCALPHA

pixelsize = 5

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

    draw: (stuff) =>
        s = pixelsize
        { x, y, color, blink } = stuff
        if stuff.blink-- > 0
            color = 0x00FF0000
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
                if @map[coord]
                    actions.push [ @move_fail, move ]
                else
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
        w = move.who
        delete @map[w.x+':'+w.y]
        w.x += move.x
        w.y += move.y
        @map[w.x+':'+w.y] = w

    move_fail: (move) =>
        move.who.blink = 1

do ->
    xs = [0..world.w]
    ys = [0..world.h]

    for [0..6000]
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

