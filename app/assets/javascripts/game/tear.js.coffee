class @Tear extends Entity
  constructor: (x, y, w, h, animator) ->
    @ttl = 0
    @vx = 0
    @vy = 0
    super
  update: ->
    super
    if @ttl > 0
      @ttl--
      @x += @vx
      @y += @vy
      @animator.animate("",@ctx)
  draw: (canvas) ->
    @draw_rect.x = @x%%canvas.width
    @draw_rect.y = @y%%canvas.height
    #TODO generalize this hack
    @ttl = 0 if (@vx > 0 && @draw_rect.x <= 32)                ||
                (@vx < 0 && @draw_rect.x >= canvas.width - 32) ||
                (@vy > 0 && @draw_rect.y <= 32)                ||
                (@vy < 0 && @draw_rect.y >= canvas.height - 32)
    super unless @ttl == 0
   
