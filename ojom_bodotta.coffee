class Vector
    constructor: (@x = 0, @y = 0, @z = 0) ->
    add: (v) -> new Vector @x+v.x, @y+v.y, @z+v.z
    sub: (v) -> new Vector @x-v.x, @y-v.y, @z-v.z
    dot: (v) -> @x*v.x+@y*v.y+@z*v.z
    cross: (v) -> new Vector @y*v.z-@z*v.y, -@x*v.z+@z*v.x, @x*v.y-@y*v.x
    len: -> Math.sqrt @x*@x+@y*@y+@z*@z
    lenSq: -> @x*@x+@y*@y+@z*@z
    mul: (a) -> new Vector @x*a, @y*a, @z*a
    div: (a) -> new Vector @x/a, @y/a, @z/a
    unit: -> this.div(@len())
    left: -> new Vector @y, -@x
    right: -> new Vector -@y, @x
    toString: -> '['+@x+','+@y+','+@z+']'

class Hermite
    constructor: (@p) ->
    init: ->
        @t = (@tFun i for i in [0..@p.length])
        @v = (@vFun i for i in [0..@p.length])
    draw: (c,time) ->
        time %= @t[@t.length-1]
        c.beginPath()
        for i in [0..@p.length-2]
            for j in [0..100]
                t = @t[i]+j/100*(@t[i+1]-@t[i])
                p = @get(t)
                c.lineTo(p.x, p.y)
        c.stroke()
        try
            c.beginPath()
            p = @get(time)
            v = @getV(time)
            c.moveTo(p.x, p.y)
            c.lineTo(p.x+v.x, p.y+v.y)
            c.stroke()
        catch ex

    coeff: (i, dt) ->
        return [
            @p[i]
            @v[i]
            @p[i+1].sub(@p[i]).mul(3).div(dt*dt).sub(@v[i+1].add(@v[i].mul(2)).div(dt))
            @p[i].sub(@p[i+1]).mul(2).div(dt*dt*dt).add(@v[i+1].add(@v[i]).div(dt*dt))
        ]
    seg: (t) ->
        i = 0
        for j in [i..@p.length]
            if t > @t[j]
                i = j
        i
    get: (t) ->
        i = @seg(t)
        dt = @t[i+1]-@t[i]
        tt = t - @t[i]
        a = @coeff(i, dt)
        a[0].add(a[1].mul(tt)).add(a[2].mul(tt*tt)).add(a[3].mul(tt*tt*tt))
    getV: (t) ->
        i = @seg(t)
        dt = @t[i+1]-@t[i]
        tt = t - @t[i]
        a = @coeff(i, dt)
        a[1].add(a[2].mul(tt*2)).add(a[3].mul(tt*tt*3))

window.onload = ->
    canvas = document.getElementById('myCanvas')
    ctx = canvas.getContext('2d')
    cri = new Hermite []
    cr = new Hermite []
    start = new Date().getTime()
    cri.tFun = cr.tFun = (i) -> i + Math.sin(i/5)*0.4
    cri.vFun = (i) ->
        if i > 0 && i < @p.length-1
            @p[i + 1].sub(@p[i - 1]).div(@t[i + 1] - @t[i - 1])
        else
            new Vector
    canvas.onclick = (e) ->
        cr.p.push new Vector(e.offsetX, e.offsetY)
        cri.p.push new Vector(e.offsetX, e.offsetY)
        #cr.init()
        cri.init()
        draw()
    draw = ->
        elapsed = (new Date().getTime()-start)/1000
        ctx.clearRect 0, 0, 600, 600
        cri.draw(ctx, elapsed)
        webkitRequestAnimationFrame draw
    draw()
