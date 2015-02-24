class Game
  constructor: ->
    tile_canvas = $("#tile_canvas").get(0)
    entity_canvas = $("#entity_canvas").get(0)
    imagemap = AssetRepository.imagemap
    datamap = AssetRepository.datamap
    @tilemap = new Tilemap(0, 0, tile_canvas.width, tile_canvas.height, imagemap, datamap)
    @player = new Player(96, 64, 32, 48)
    @dirty_rects = []
    @dirty_rects[@dirty_rects.length] = @player.draw_rect
    @map_x = -1
    @map_y = -1

  update: ->
    for dirty_rect in @dirty_rects
      entity_canvas.getContext('2d').clearRect(Math.floor(dirty_rect.x),
                                               Math.floor(dirty_rect.y),
                                               dirty_rect.w+1,
                                               dirty_rect.h+1)

    @dirty_rects.pop() while @dirty_rects.length > 0

    if @map_x != @player.cx // entity_canvas.width or @map_y != @player.cy // entity_canvas.height
      @map_x = @player.cx // entity_canvas.width
      @map_y = @player.cy // entity_canvas.height
      @tilemap.update(@map_x, @map_y)
      @tilemap.draw(tile_canvas)

    @player.update(@tilemap)

    @player.draw(entity_canvas)
    @dirty_rects[@dirty_rects.length] = @player.draw_rect

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
    canvas.getContext('2d').drawImage(@canvas, @draw_rect.x, @draw_rect.y)
 
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
    @collision_rect = new Rectangle(@x+@w/4,@y+@h/2,@w/2,@h/3)
    @cx = @collision_rect.x + @collision_rect.w/2
    @cy = @collision_rect.y + @collision_rect.h/2
    @tick = 0
  update: (tilemap) ->
    # TODO reduce number of draw calls
    # TODO make better animation logic
    
    @controller.update()
    
    @tick++
    @tick %= 80
    if @tick < 0
      @tick+=80
    x_shift = Math.floor(@tick/8)*@w # getting animation frame
    
    @ctx.clearRect(0,0,@w,@h)

    s = 4
    if @controller.x != 0 and @controller.y != 0
      s = s / Math.sqrt(2)

    @del_x = s*@controller.x
    @del_y = s*@controller.y

    @x += @del_x
    @y += @del_y

    @collision_rect.x = @x+@w/4
    @collision_rect.y = @y+@h/2
    @collision_rect.w = @w/2
    @collision_rect.h = @h/3
 
    tilemap_collisions = tilemap.collision(@collision_rect)
    console.log tilemap_collisions
    if "left" in tilemap_collisions && @del_x < 0 || "right" in tilemap_collisions && @del_x > 0
      @x -= @del_x
      @collision_rect.x = @x+@w/4
      @collision_rect.w = @w/2
    if "top" in tilemap_collisions && @del_y < 0 || "bot" in tilemap_collisions && @del_y > 0
      @y -= @del_y
      @collision_rect.y = @y+@h/2
      @collision_rect.h = @h/3
    
    @cx = @collision_rect.x + @collision_rect.w/2
    @cy = @collision_rect.y + @collision_rect.h/2

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
  draw: (canvas) ->

    @draw_rect.x = @x%%canvas.width
    if @cx//canvas.width > @x//canvas.width
      @draw_rect.x -= canvas.width
     
    @draw_rect.y = @y%%canvas.height
    if @cy//canvas.height > @y//canvas.height 
      @draw_rect.y -= canvas.height
   
    super

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
    @collisions = []
    @collisions.length = @datamap.width * @datamap.height
    for l in @datamap.layers
      if l.name == "collision"
        for c in [0...@datamap.width]
          for r in [0...@datamap.height]
            @collisions[r * @datamap.width + c] = l.data[r * @datamap.width + c] != 0
    super
  update: (map_x, map_y) ->
    ntx = @w/@datamap.tilewidth
    nty = @h/@datamap.tileheight
    for l in @datamap.layers
      if l.name != "collision"
        for c in [0...ntx]
          for r in [0...nty]
            tile = (l.data[(r+map_y*nty) * @datamap.width + c+map_x*ntx] - 1) & 0x0FFFFFFF
            rotation = (l.data[(r+map_y*nty) * @datamap.width + c] - 1) & 0xF0000000
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
  collision: (rect) ->
    cmin = rect.x//@datamap.tilewidth
    cmax = Math.ceil((rect.x + rect.w)/@datamap.tilewidth)
    rmin = rect.y//@datamap.tileheight
    rmax = Math.ceil((rect.y + rect.h)/@datamap.tileheight)
    
    collisions = []
    collisions[collisions.length] = "top" if @collisions[rmin * @datamap.width + cmin] and
                                             @collisions[rmin * @datamap.width + cmax]
    collisions[collisions.length] = "bot" if @collisions[(rmax-1) * @datamap.width + cmin] and
                                             @collisions[(rmax-1) * @datamap.width + cmax]
    collisions[collisions.length] = "left" if @collisions[rmin * @datamap.width + cmin] and
                                              @collisions[rmax * @datamap.width + cmin]
    collisions[collisions.length] = "right" if @collisions[rmin * @datamap.width + cmax-1] and
                                               @collisions[rmax * @datamap.width + cmax-1]
    collisions

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

