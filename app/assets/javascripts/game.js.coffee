class Game
  constructor: ->
    tile_canvas = $("#tile_canvas").get(0)
    entity_canvas = $("#entity_canvas").get(0)
    imagemap = AssetRepository.imagemap
    datamap = AssetRepository.datamap
    @tilemap = new Tilemap(tile_canvas.width, tile_canvas.height, imagemap, datamap)
    @player = new Player(32, 32, 0, 0)
    @dirty_rects = []
    @dirty_rects[@dirty_rects.length] = new Rect(@player.x, @player.y, @player.w, @player.h)   
    console.log @dirty_rects[@dirty_rects.length-1]
 
    #------------PAINT------------------
    @tilemap.draw(tile_canvas, 0, 0)
    @player.draw(entity_canvas, @player.x, @player.y)

  update: ->
    for dirty_rect in @dirty_rects
      entity_canvas.getContext('2d').clearRect(dirty_rect.x, 
                                               dirty_rect.y,
                                               dirty_rect.width,
                                               dirty_rect.height)
    
    
    @dirty_rects.pop() while @dirty_rects.length > 0   
 
    s = 10
    @player.x+=s if KEY_STATUS.right
    @player.x-=s if KEY_STATUS.left
    @player.y+=s if KEY_STATUS.down
    @player.y-=10 if KEY_STATUS.up

    @player.draw(entity_canvas, @player.x, @player.y)
    @dirty_rects[@dirty_rects.length] = new Rect(@player.x, @player.y, @player.w, @player.h)
    
    console.log "speed test"


class Drawable
  constructor: (w, h) ->
    @canvas = document.createElement('canvas')
    @canvas.width = w
    @canvas.height = h
    
  draw: (canvas, x, y) -> 
    canvas.getContext('2d').drawImage(@canvas, x, y)

class Entity extends Drawable
  constructor: (@w, @h, @x, @y) ->
    super
  update: ->

class Player extends Entity
  constructor: (w, h, x, y) ->
    super
    ctx = @canvas.getContext('2d')
    ctx.rect(0, 0, w, h)
    ctx.fillStyle="red"
    ctx.fill()
  update: ->
    


class Tilemap extends Drawable
  constructor: (w, h, @imagemap, @datamap) ->
    super
    ctx = @canvas.getContext('2d')
    for l in @datamap.layers
      for r in [0...@datamap.height]
        for c in [0...@datamap.width]
          tile = (l["data"][r * @datamap.width + c] - 1) & 0x0FFFFFFF
          rotation = (l["data"][r * @datamap.width + c] - 1) & 0xF0000000
          angle = 0
          angle = Math.PI / 2   if (rotation ^ 0xA0000000)==0
          angle = Math.PI       if (rotation ^ 0xC0000000)==0
          angle = 3*Math.PI / 2 if (rotation ^ 0x60000000)==0
          tilerow = Math.floor(tile / (@imagemap.width / @datamap.tilewidth))
          tilecol = Math.floor(tile % (@imagemap.width / @datamap.tilewidth))
          ctx.save()
          ctx.translate(c*@datamap.tilewidth, r*@datamap.tileheight)
          ctx.rotate(angle)
          ctx.drawImage(@imagemap, 
                        tilecol * @datamap.tilewidth, 
                        tilerow * @datamap.tileheight, 
                        @datamap.tilewidth, 
                        @datamap.tileheight,
                        0,
                        0, 
                        @datamap.tilewidth, 
                        @datamap.tileheight)
          ctx.restore()

class Rect
  constructor: (@x, @y, @width, @height) ->

class AssetRepository
  @load: ->
    numAssets = 2
    numLoaded = 0    

    loaded = ->
      numLoaded++
      if numLoaded == numAssets
        init()
    
    @imagemap = new Image()
    @imagemap.onload = ->
      loaded()
    @imagemap.src = "assets/terrain_tileset.png"

    $.getJSON("assets/512.json", (json) =>
      @datamap = json
    ).done(->
      loaded()
    )

$ ->
  load()

load = ->
  AssetRepository.load()

init = ->
  @game = new Game()
  animate()
animate = ->
  requestAnimFrame(animate)
  @game.update()

window.requestAnimFrame = (->
  window.requestAnimationFrame or window.webkitRequestAnimationFrame or window.mozRequestAnimationFrame or window.oRequestAnimationFrame or window.msRequestAnimationFrame or (callback, element) ->
    window.setTimeout callback, 1000 / 60
    return
)()

KEY_CODES =
  37: "left"
  38: "up"
  39: "right"
  40: "down"

KEY_STATUS = keyDown: false
for code of KEY_CODES
  KEY_STATUS[KEY_CODES[code]] = false
$(window).keydown((e) ->
  KEY_STATUS.keyDown = true
  if KEY_CODES[e.keyCode]
    e.preventDefault()
    KEY_STATUS[KEY_CODES[e.keyCode]] = true
  return
).keyup (e) ->
  KEY_STATUS.keyDown = false
  if KEY_CODES[e.keyCode]
    e.preventDefault()
    KEY_STATUS[KEY_CODES[e.keyCode]] = false
  return

