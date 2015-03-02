class @Controller
  constructor: ->
  update: ->
    @x = 0
    @y = 0
    @f_x = 0
    @f_y = 0

    @y-- if KEY_STATUS.w
    @y++ if KEY_STATUS.s
    @x-- if KEY_STATUS.a
    @x++ if KEY_STATUS.d

KEY_CODES =
  37: "left"
  38: "up"
  39: "right"
  40: "down"
  65: "a"
  68: "d"
  83: "s"
  87: "w"

KEY_STATUS = keyDown: false
for code of KEY_CODES
  KEY_STATUS[KEY_CODES[code]] = false
$(window).keydown((e) ->
  KEY_STATUS.keyDown = true
  if KEY_CODES[e.keyCode]
    e.preventDefault()
    KEY_STATUS[KEY_CODES[e.keyCode]] = true
  return
).keyup (e) ->
  KEY_STATUS.keyDown = false
  if KEY_CODES[e.keyCode]
    e.preventDefault()
    KEY_STATUS[KEY_CODES[e.keyCode]] = false
  return
