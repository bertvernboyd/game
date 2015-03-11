class @Frame
  constructor: ->
    tile_canvas = $("#tile_canvas").get(0)
    entity_canvas = $("#entity_canvas").get(0)
    imagemap = AssetRepository.imagemap
    datamap = AssetRepository.datamap
    @tilemap = new Tilemap(0, 0, tile_canvas.width, tile_canvas.height, imagemap, datamap)

    @player = new Player(96, 64, 32, 48, Animators.player())

    @dirty_rects = []
    @dirty_rects[@dirty_rects.length] = @player.draw_rect
    @map_x = -1
    @map_y = -1

  update: ->
    for dirty_rect in @dirty_rects
      entity_canvas.getContext('2d').clearRect(Math.floor(dirty_rect.x),
                                               Math.floor(dirty_rect.y),
                                               dirty_rect.w+1,
                                               dirty_rect.h+1)

    @dirty_rects.pop() while @dirty_rects.length > 0

    # Screen transition
    if @map_x != @player.cx // entity_canvas.width or @map_y != @player.cy // entity_canvas.height
      @map_x = @player.cx // entity_canvas.width
      @map_y = @player.cy // entity_canvas.height
      @tilemap.update(@map_x, @map_y)
      @tilemap.draw(tile_canvas)

    @player.update(@tilemap)

    @player.draw(entity_canvas)
    
    @dirty_rects[@dirty_rects.length] = @player.draw_rect
    @dirty_rects[@dirty_rects.length] = tear.draw_rect for tear in @player.tear_pool.alive_tears


