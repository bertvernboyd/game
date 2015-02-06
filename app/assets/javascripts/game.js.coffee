class Game
  constructor: ->
    tile_canvas = $("#tile_canvas").get(0)
    entity_canvas = $("#entity_canvas").get(0)
    imagemap = AssetRepository.imagemap
    datamap = AssetRepository.datamap
    @tilemap = new Tilemap(0, 0, tile_canvas.width, tile_canvas.height, imagemap, datamap)
    @player = new Player(608, 0, 32, 48)
    @dirty_rects = []
    @dirty_rects[@dirty_rects.length] = @player.draw_rect   
 
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
    @dirty_rects[@dirty_rects.length] = @player.draw_rect
 
    console.log "loop" 


class Rectangle
  constructor: (@x, @y, @w, @h) ->
    

class Drawable
  constructor: (@x, @y, @w, @h) ->
    @canvas = document.createElement('canvas')
    @canvas.width = @w
    @canvas.height = @h
    @ctx = @canvas.getContext('2d')
    @draw_rect = new Rectangle(@x,@y,@w,@h)
    
  draw: (canvas) -> 
    canvas.getContext('2d').drawImage(@canvas, @x, @y)
 
  update: ->
    @draw_rect.x = @x
    @draw_rect.y = @y
    @draw_rect.w = @w
    @draw_rect.h = @h

class Entity extends Drawable
  constructor: (x, y, w, h) ->
    super
  update: ->
    super

class Player extends Entity
  constructor: (x, y, w, h) ->
    super
    @controller = new Controller()
    @tick = 0
  update: ->
    super
    # TODO reduce number of draw calls
    # TODO make better animation logic
    
    @controller.update()
    @tick++
    @tick %= 80
    if @tick < 0
      @tick+=80
    x_shift = Math.floor(@tick/8)*@w
    s = 4
    @ctx.clearRect(0,0,@w,@h)

    @x += s*@controller.x
    @y += s*@controller.y

    if @controller.x == 0 and @controller.y == 0
      @animation_state = "idle"
    else if @controller.x == 1
      @animation_state = "walk_right"
    else if @controller.x == -1
      @animation_state = "walk_left"
    else if @controller.y == 1
      @animation_state = "walk_down"
    else if @controller.y == -1
      @animation_state = "walk_up"

    switch @animation_state
      when "idle"
        @tick = 0
        @ctx.drawImage(AssetRepository.isaac_image,0,0,@w,2*@h/3,0,@h/3,@w,2*@h/3)
        @ctx.drawImage(AssetRepository.hero_image,0,0,@w,2*@h/3,0,0,@w,2*@h/3)
      when "walk_right"
        @ctx.drawImage(AssetRepository.isaac_image,x_shift,2*@h/3,@w,2*@h/3,0,@h/3,@w,2*@h/3) 
        @ctx.drawImage(AssetRepository.hero_image,0,0,@w,2*@h/3,0,0,@w,2*@h/3)
      when "walk_left"
        @ctx.save()
        @ctx.translate(@w, 0)
        @ctx.scale(-1,1)
        @ctx.drawImage(AssetRepository.isaac_image,x_shift,2*@h/3,@w,2*@h/3,0,@h/3,@w,2*@h/3) 
        @ctx.drawImage(AssetRepository.hero_image,0,0,@w,2*@h/3,0,0,@w,2*@h/3)
        @ctx.restore()
      when "walk_down"
        @ctx.drawImage(AssetRepository.isaac_image,x_shift,0,@w,2*@h/3,0,@h/3,@w,2*@h/3) 
        @ctx.drawImage(AssetRepository.hero_image,0,0,@w,2*@h/3,0,0,@w,2*@h/3)
      when "walk_up"
        x_shift = 9*@w-x_shift 
        @ctx.drawImage(AssetRepository.isaac_image,x_shift,0,@w,2*@h/3,0,@h/3,@w,2*@h/3) 
        @ctx.drawImage(AssetRepository.hero_image,0,0,@w,2*@h/3,0,0,@w,2*@h/3)
      else

class Controller
  constructor: ->
  update: ->
    @x = 0
    @y = 0
    @f_x = 0
    @f_y = 0 

    @y-- if KEY_STATUS.w
    @y++ if KEY_STATUS.s
    @x-- if KEY_STATUS.a
    @x++ if KEY_STATUS.d

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
    numAssets = 4
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

    @isaac_image = new Image()
    @isaac_image.onload = ->
      loaded()
    @isaac_image.src = "assets/isaac.png"

    @hero_image = new Image()
    @hero_image.onload = ->
      loaded()
    @hero_image.src = "assets/hero_32.png"

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
  65: "a"
  68: "d"
  83: "s"
  87: "w"

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

