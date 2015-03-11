class @TearPool
  constructor: ->
    nTears = 10
    @dead_tears = (new Tear(0,0,16,16,Animators.tear()) for i in [0...nTears])
    @alive_tears = []
  create_tear: (x, y, vx, vy, ttl) ->
    if @dead_tears.length > 0
      tear = @dead_tears.shift()
      tear.x = x
      tear.y = y
      tear.vx = vx
      tear.vy = vy
      tear.ttl = ttl
      @alive_tears[@alive_tears.length] = tear
      
  update: ->
    tear.update() for tear in @alive_tears
    all = @dead_tears.concat @alive_tears
    @dead_tears = []
    @alive_tears = []
    (if tear.ttl == 0 then @dead_tears else @alive_tears).push tear for tear in all
    

