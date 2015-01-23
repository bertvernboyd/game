class Game
  constructor: ->
    canvas = $("#tile_canvas").get(0)
    imagemap = AssetRepository.imagemap
    datamap = AssetRepository.datamap
    @tilemap = new Tilemap(1024, 768, imagemap, datamap)
    @tilemap.draw(canvas)

  update: -> 
    console.log "speed"

class Drawable
  constructor: (w, h) ->
    @canvas = document.createElement('canvas')
    @canvas.width = w
    @canvas.height = h
    
  draw: (canvas) -> 
    canvas.getContext('2d').drawImage(@canvas, 0, 0)

class Tilemap extends Drawable
  constructor: (w, h, @imagemap, @datamap) ->
    super
    ctx = @canvas.getContext('2d');
    for l in @datamap.layers
      for r in [0...@datamap.height]
        for c in [0...@datamap.width]
          tile = (l["data"][r * @datamap.width + c] - 1) & 0x0FFFFFFF
          rotation = (l["data"][r * @datamap.width + c] - 1) & 0xF0000000
          angle = 0
          angle = Math.PI / 2   if (rotation ^ 0xA0000000)==0
          angle = Math.PI       if (rotation ^ 0xC0000000)==0
          angle = 3*Math.PI / 2 if (rotation ^ 0x60000000)==0
          tilerow = Math.floor(tile / (@imagemap.width / @datamap.tilewidth))
          tilecol = Math.floor(tile % (@imagemap.width / @datamap.tilewidth))
          ctx.save()
          ctx.translate(c*@datamap.tilewidth, r*@datamap.tileheight)
          ctx.rotate(angle)
          ctx.drawImage(@imagemap, 
                        tilecol * @datamap.tilewidth, 
                        tilerow * @datamap.tileheight, 
                        @datamap.tilewidth, 
                        @datamap.tileheight, 
                        -@datamap.tilewidth / 2, 
                        -@datamap.tileheight / 2, 
                        @datamap.tilewidth, 
                        @datamap.tileheight)
          ctx.restore()

class AssetRepository
  @load: ->
    numAssets = 2
    numLoaded = 0    

    loaded = ->
      numLoaded++
      if numLoaded == numAssets
        init()
    
    @imagemap = new Image()
    @imagemap.onload = ->
      loaded()
    @imagemap.src = "assets/lost_garden_tileset.png"

    $.getJSON("assets/data.json", (json) =>
      @datamap = json
    ).done(->
      loaded()
    )

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
