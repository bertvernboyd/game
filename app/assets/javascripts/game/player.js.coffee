class @Player extends Entity
  constructor: (x, y, w, h, animator) ->
    super
    @controller = new Controller()
    @collision_rect = new Rectangle(@x+@w/4,@y+@h/2,@w/2,@h/3)
    @cx = @collision_rect.x + @collision_rect.w/2
    @cy = @collision_rect.y + @collision_rect.h/2
    
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
      animation_state = "idle"
    else if @controller.x == 1
      animation_state = "walk_right"
    else if @controller.x == -1
      animation_state = "walk_left"
    else if @controller.y == 1
      animation_state = "walk_down"
    else if @controller.y == -1
      animation_state = "walk_up"

    @animator.animate(animation_state,@ctx)

  draw: (canvas) ->

    @draw_rect.x = @x%%canvas.width
    if @cx//canvas.width > @x//canvas.width
      @draw_rect.x -= canvas.width
     
    @draw_rect.y = @y%%canvas.height
    if @cy//canvas.height > @y//canvas.height 
      @draw_rect.y -= canvas.height
   
    super
