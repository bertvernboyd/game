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
