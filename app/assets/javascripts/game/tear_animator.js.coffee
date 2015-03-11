class @TearAnimator extends Animator
  animate: (state, ctx) ->
    w = ctx.canvas.width
    h = ctx.canvas.height
    ctx.clearRect(0,0,w,h)
    ctx.drawImage(@images[0],0,0,w,h,0,0,w,h)
