class Game
  constructor: ->
    tile_canvas = $("#tile_canvas").get(0)
    entity_canvas = $("#entity_canvas").get(0)
    imagemap = AssetRepository.imagemap
    datamap = AssetRepository.datamap
    @tilemap = new Tilemap(0, 0, tile_canvas.width, tile_canvas.height, imagemap, datamap)
    @player = new Player(0, 0, 32, 32)
    @dirty_rects = []
    @dirty_rects[@dirty_rects.length] = @player.clone_bounds()   
 
    #------------PAINT------------------
    @tilemap.draw(tile_canvas)

  update: ->
    for dirty_rect in @dirty_rects
      entity_canvas.getContext('2d').clearRect(dirty_rect.x, 
                                               dirty_rect.y,
                                               dirty_rect.w,
                                               dirty_rect.h)
    
    
    @dirty_rects.pop() while @dirty_rects.length > 0   
 

    @player.update()

    @player.draw(entity_canvas)
    @dirty_rects[@dirty_rects.length] = @player.clone_bounds()
    
    console.log "speed test"


class Rectangle
  constructor: (@x, @y, @w, @h) ->
  clone_bounds: ->
    new Rectangle(@x, @y, @w, @h)
    

class Drawable extends Rectangle
  constructor: (x, y, w, h) ->
    super
    @canvas = document.createElement('canvas')
    @canvas.width = @w
    @canvas.height = @h
    @ctx = @canvas.getContext('2d')
    
  draw: (canvas) -> 
    canvas.getContext('2d').drawImage(@canvas, @x, @y)

class Entity extends Drawable
  constructor: (x, y, w, h) ->
    super
  update: ->

class Player extends Entity
  constructor: (x, y, w, h) ->
    super
    @ctx.drawImage(AssetRepository.heroes_image,2*@w,0,32,32,0,0,32,32)
    @tick = 0
  update: ->
    # TODO reduce number of draw calls
    # TODO make better animation logic
    @tick++
    @tick %= 32
    x_shift = if (@tick < 16) then 0 else @w 
    s = 4
    if KEY_STATUS.right
      @ctx.clearRect(0,0,@w,@h)
      @ctx.drawImage(AssetRepository.heroes_image,6*@w+x_shift,0,@w,@h,0,0,@w,@h) 
      @x+=s
    else if KEY_STATUS.left
      @ctx.clearRect(0,0,@w,@h)
      @ctx.drawImage(AssetRepository.heroes_image,4*@w+x_shift,0,@w,@h,0,0,@w,@h) 
      @x-=s
    else if KEY_STATUS.down
      @ctx.clearRect(0,0,@w,@h)
      @ctx.drawImage(AssetRepository.heroes_image,2*@w+x_shift,0,@w,@h,0,0,@w,@h) 
      @y+=s
    else if KEY_STATUS.up
      @ctx.clearRect(0,0,@w,@h)
      @ctx.drawImage(AssetRepository.heroes_image,0*@w+x_shift,0,@w,@h,0,0,@w,@h) 
      @y-=s

class Tilemap extends Drawable
  constructor: (x, y, w, h, @imagemap, @datamap) ->
    # do something with @x and @y
    super
    for l in @datamap.layers
      for r in [0...@datamap.height]
        for c in [0...@datamap.width]
          tile = (l.data[r * @datamap.width + c] - 1) & 0x0FFFFFFF
          rotation = (l.data[r * @datamap.width + c] - 1) & 0xF0000000
          angle = 0
          angle = Math.PI / 2   if (rotation ^ 0xA0000000)==0
          angle = Math.PI       if (rotation ^ 0xC0000000)==0
          angle = 3*Math.PI / 2 if (rotation ^ 0x60000000)==0
          tilerow = Math.floor(tile / (@imagemap.width / @datamap.tilewidth))
          tilecol = Math.floor(tile % (@imagemap.width / @datamap.tilewidth))
          @ctx.save()
          @ctx.translate(c*@datamap.tilewidth, r*@datamap.tileheight)
          @ctx.rotate(angle)
          @ctx.drawImage(@imagemap, 
                         tilecol * @datamap.tilewidth, 
                         tilerow * @datamap.tileheight, 
                         @datamap.tilewidth, 
                         @datamap.tileheight,
                         0,
                         0, 
                         @datamap.tilewidth, 
                         @datamap.tileheight)
          @ctx.restore()


class AssetRepository
  @load: ->
    numAssets = 3
    numLoaded = 0    

    loaded = ->
      numLoaded++
      if numLoaded == numAssets
        init()

    $.getJSON("assets/512.json", (json) =>
      @datamap = json
      @imagemap = new Image()
      @imagemap.onload = ->
        loaded()
      
      pattern = ///\w+[.]\w+$///

      console.log (@datamap.tilesets[0].image.match pattern)[0]
      
      @imagemap.src = "assets/#{(@datamap.tilesets[0].image.match pattern)[0]}"
    ).done(->
      loaded()
    )

    @heroes_image = new Image()
    @heroes_image.onload = ->
      loaded()
    @heroes_image.src = "assets/heroes.png"

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

