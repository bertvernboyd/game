class @Animator
  constructor: (@images, @ctx) ->
    @tick = 0
    @w = @ctx.canvas.width
    @h = @ctx.canvas.height
  animate: (state) -> 
    throw Error "unimplemented method"

  


    

