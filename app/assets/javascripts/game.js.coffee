#= require game/rectangle.js.coffee
#= require game/drawable.js.coffee
#= require game/entity.js.coffee
#= require game/controller.js.coffee
#= require game/tilemap.js.coffee
#= require game/animator.js.coffee
#= require game/player_animator.js.coffee

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

class Player extends Entity
  constructor: (x, y, w, h) ->
    super
    @controller = new Controller()
    @collision_rect = new Rectangle(@x+@w/4,@y+@h/2,@w/2,@h/3)
    @cx = @collision_rect.x + @collision_rect.w/2
    @cy = @collision_rect.y + @collision_rect.h/2
    @tick = 0
    images = []
    images[images.length] = AssetRepository.isaac_image
    images[images.length] = AssetRepository.hero_image
    @animator = new PlayerAnimator(images, @ctx)
    
  update: (tilemap) ->
    # TODO reduce number of draw calls
    
    @controller.update()
    
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
    #console.log tilemap_collisions
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

    @animator.animate(@animation_state)

  draw: (canvas) ->

    @draw_rect.x = @x%%canvas.width
    if @cx//canvas.width > @x//canvas.width
      @draw_rect.x -= canvas.width
     
    @draw_rect.y = @y%%canvas.height
    if @cy//canvas.height > @y//canvas.height 
      @draw_rect.y -= canvas.height
   
    super

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



