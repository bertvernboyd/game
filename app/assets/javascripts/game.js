var game = new Game();

function init() {
  if(game.init())
    game.start();
}

var imageRepository = new function() {
  this.tileset = new Image();
  var numImages = 1;
  var numLoaded = 0;
  function imageLoaded(){
    numLoaded++;
    if(numLoaded === numImages) {
      window.init();
    }
  }
  this.tileset.onload = function(){
    imageLoaded();
  }
  this.tileset.src = "assets/lost_garden_tileset.png";

}

function Drawable(){
  this.init = function(canvas){
    this.context = canvas.getContext('2d');
    this.canvasWidth = canvas.width;
    this.canvasHeight = canvas.height
  }
  this.draw = function(){
  };
}

function Tileset() {
  var layers = [];
  layers[layers.length] = [
   [0,0,0,0,0,0,0,0],
   [0,0,0,0,0,0,0,0],
   [0,0,9,9,9,0,0,0],
   [0,0,9,9,9,0,0,0],
   [0,0,9,9,9,0,0,0],
   [0,0,0,0,0,0,0,0],
  ];
  var tileSize = 128;     // The size of a tile (128x128)
  var rowTileCount = 6;   // The number of tiles in a row of our background
  var colTileCount = 8;   // The number of tiles in a column of our background
  var imageNumTiles = 25;  // The number of tiles per row in the tileset image
  this.draw = function(){
    for (var l = 0; l < layers.length; l++){
      for (var r = 0; r < rowTileCount; r++){
        for (var c = 0; c < colTileCount; c++){
          var tile = layers[ l ][ r ][ c ] & 0x0FFFFFFF;
          var tileRow = Math.floor(tile / imageNumTiles);
          var tileCol = Math.floor(tile % imageNumTiles);
          this.context.drawImage(imageRepository.tileset, 
                                (tileCol * tileSize), (tileRow * tileSize), tileSize, tileSize, 
                                (c * tileSize), (r * tileSize), tileSize, tileSize);
        }
      }
    }

  };
}
Tileset.prototype = new Drawable();

function Game(){
  this.init = function(){
    var canvas = document.getElementById('main');
    if(canvas.getContext){
      this.tileset = new Tileset();
      this.tileset.init(canvas);
      return true;
    }
    else{
      return false;
    }
  };

  this.start = function() {
    animate();
  };
}

function animate(){
  requestAnimFrame(animate);
  game.tileset.draw();
}

window.requestAnimFrame = (function(){
  return  window.requestAnimationFrame   ||
          window.webkitRequestAnimationFrame ||
          window.mozRequestAnimationFrame    ||
          window.oRequestAnimationFrame      ||
          window.msRequestAnimationFrame     ||
          function(/* function */ callback, /* DOMElement */ element){
            window.setTimeout(callback, 1000 / 60);
          };
})();

