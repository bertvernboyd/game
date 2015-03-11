class @PlayerAnimator extends Animator

  animate: (state, ctx) ->    
    w = ctx.canvas.width
    h = ctx.canvas.height
    ctx.clearRect(0,0,w,h)
   
    @tick++
    @tick %= 80
    if @tick < 0
      @tick+=80
    x_shift = Math.floor(@tick/8)*w # getting animation frame

    switch state
      when "idle"
        @tick = 0        
        ctx.drawImage(@images[0],0,0,w,2*h/3,0,h/3,w,2*h/3)
        ctx.drawImage(@images[1],0,0,w,2*h/3,0,0,w,2*h/3)
      when "walk_right"
        ctx.drawImage(@images[0],x_shift,2*h/3,w,2*h/3,0,h/3,w,2*h/3)
        ctx.drawImage(@images[1],0,0,w,2*h/3,0,0,w,2*h/3)
      when "walk_left"
        ctx.save()
        ctx.translate(w, 0)
        ctx.scale(-1,1)
        ctx.drawImage(@images[0],x_shift,2*h/3,w,2*h/3,0,h/3,w,2*h/3)
        ctx.drawImage(@images[1],0,0,w,2*h/3,0,0,w,2*h/3)
        ctx.restore()
      when "walk_down"
        ctx.drawImage(@images[0],x_shift,0,w,2*h/3,0,h/3,w,2*h/3)
        ctx.drawImage(@images[1],0,0,w,2*h/3,0,0,w,2*h/3)
      when "walk_up"
        x_shift = 9*w-x_shift 
        ctx.drawImage(@images[0],x_shift,0,w,2*h/3,0,h/3,w,2*h/3)
        ctx.drawImage(@images[1],0,0,w,2*h/3,0,0,w,2*h/3)
      else
