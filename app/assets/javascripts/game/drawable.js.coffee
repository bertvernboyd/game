class @Drawable
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
