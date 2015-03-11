#= require game/animator.js.coffee
#= require game/animators.js.coffee
#= require game/asset_repository.js.coffee
#= require game/controller.js.coffee
#= require game/drawable.js.coffee
#= require game/entity.js.coffee
#= require game/frame.js.coffee
#= require game/player.js.coffee
#= require game/player_animator.js.coffee
#= require game/rectangle.js.coffee
#= require game/tilemap.js.coffee

class @Game
  @init = ->
    @frame = new Frame()
    animate()
  animate = =>
    requestAnimFrame(animate)    
    @frame.update()
  requestAnimFrame = (->
    window.requestAnimationFrame or window.webkitRequestAnimationFrame or window.mozRequestAnimationFrame or window.oRequestAnimationFrame or window.msRequestAnimationFrame or (callback, element) ->
      window.setTimeout callback, 1000 / 60
      return
  )()

$ ->
  AssetRepository.load()
  # Will call Game.init once all assets are loaded

