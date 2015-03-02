class @Tilemap extends Drawable
  constructor: (x, y, w, h, @imagemap, @datamap) ->
    # do something with @x and @y
    @collisions = []
    @collisions.length = @datamap.width * @datamap.height
    for l in @datamap.layers
      if l.name == "collision"
        for c in [0...@datamap.width]
          for r in [0...@datamap.height]
            @collisions[r * @datamap.width + c] = l.data[r * @datamap.width + c] != 0
    super
  update: (map_x, map_y) ->
    ntx = @w/@datamap.tilewidth
    nty = @h/@datamap.tileheight
    for l in @datamap.layers
      if l.name != "collision"
        for c in [0...ntx]
          for r in [0...nty]
            tile = (l.data[(r+map_y*nty) * @datamap.width + c+map_x*ntx] - 1) & 0x0FFFFFFF
            rotation = (l.data[(r+map_y*nty) * @datamap.width + c] - 1) & 0xF0000000
            angle = 0
            angle = Math.PI / 2   if (rotation ^ 0xA0000000)==0
            angle = Math.PI       if (rotation ^ 0xC0000000)==0
            angle = 3*Math.PI / 2 if (rotation ^ 0x60000000)==0
            tilerow = Math.floor(tile / (@imagemap.width / @datamap.tilewidth))
            tilecol = Math.floor(tile % (@imagemap.width / @datamap.tilewidth))
            @ctx.save()
            @ctx.translate(c*@datamap.tilewidth, r*@datamap.tileheight)
            @ctx.rotate(angle)
            @ctx.drawImage(@imagemap,
                           tilecol * @datamap.tilewidth,
                           tilerow * @datamap.tileheight,
                           @datamap.tilewidth,
                           @datamap.tileheight,
                           0,
                           0,
                           @datamap.tilewidth,
                           @datamap.tileheight)
            @ctx.restore()
  collision: (rect) ->
    cmin = rect.x//@datamap.tilewidth
    cmax = Math.ceil((rect.x + rect.w)/@datamap.tilewidth)
    rmin = rect.y//@datamap.tileheight
    rmax = Math.ceil((rect.y + rect.h)/@datamap.tileheight)
    
    collisions = []
    collisions[collisions.length] = "top" if @collisions[rmin * @datamap.width + cmin] and
                                             @collisions[rmin * @datamap.width + cmax]
    collisions[collisions.length] = "bot" if @collisions[(rmax-1) * @datamap.width + cmin] and
                                             @collisions[(rmax-1) * @datamap.width + cmax]
    collisions[collisions.length] = "left" if @collisions[rmin * @datamap.width + cmin] and
                                              @collisions[rmax * @datamap.width + cmin]
    collisions[collisions.length] = "right" if @collisions[rmin * @datamap.width + cmax-1] and
                                               @collisions[rmax * @datamap.width + cmax-1]
    collisions

