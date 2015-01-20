var game = new Game();

function init() {
  if(game.init())
    game.start();
}

var tiled;
$.getJSON("assets/data.json", function(json) {
   tiled = json;
});

var assetRepository = new function() {
  this.tileset = new Image();
  var numAssets = 2;
  var numAssetsLoaded = 0;

  function imageLoaded(){
    numAssetsLoaded++;
    if(numAssetsLoaded === numAssets) {
      window.init();
      init();
    }
  }

  this.tileset.onload = function(){
    imageLoaded();
  }
  this.tileset.src = "assets/lost_garden_tileset.png";

  // WHY NO WORK??
  var tilemap;
  getJson = $.getJSON("assets/data.json", function(json) {
    tilemap = json;
  });

  getJson.success(function(response){
      numAssetsLoaded++;
      if(numAssetsLoaded === numAssets) {
        window.init();
      }
  });

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

  var tileSize = 128;     // The size of a tile (128x128)
  var rowTileCount = 6;   // The number of tiles in a row of our background
  var colTileCount = 8;   // The number of tiles in a column of our background
  var imageNumTiles = 25;  // The number of tiles per row in the tileset image
  
  this.draw = function(){
    for (var l = 0; l < tiled["layers"].length; l++){
      for (var r = 0; r < rowTileCount; r++){
        for (var c = 0; c < colTileCount; c++){
          var tile = (tiled["layers"][l]["data"][r * colTileCount + c]-1) & 0x0FFFFFFF;
          var rotation = (tiled["layers"][l]["data"][r * colTileCount + c]-1) & 0xF0000000;
          var angle = 0;

          if((rotation ^ 0xA0000000)==0)
            angle = 90;
          
          if((rotation ^ 0xC0000000)==0)
            angle = 180;

          if((rotation ^ 0x60000000)==0)
            angle = 270;
          
          var tileRow = Math.floor(tile / imageNumTiles);
          var tileCol = Math.floor(tile % imageNumTiles);

          this.context.save(); 
          this.context.translate(c*tileSize, r*tileSize);
          this.context.rotate(angle * Math.PI / 180);
          this.context.drawImage(assetRepository.tileset, 
                                 tileCol * tileSize, tileRow * tileSize, tileSize, tileSize,
                                 -tileSize / 2, -tileSize / 2, tileSize, tileSize);
          this.context.restore();

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

