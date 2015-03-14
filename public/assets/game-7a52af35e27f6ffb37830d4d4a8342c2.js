(function() {
  this.Animator = (function() {
    function Animator(images) {
      this.images = images;
      this.tick = 0;
    }

    Animator.prototype.animate = function(state, ctx) {
      throw Error("unimplemented method");
    };

    return Animator;

  })();

}).call(this);
(function() {
  this.Animators = (function() {
    function Animators() {}

    Animators.player = function() {
      var images;
      if (this.player_animator == null) {
        images = [];
        images[images.length] = AssetRepository.isaac_image;
        images[images.length] = AssetRepository.hero_image;
        this.player_animator = new PlayerAnimator(images);
      }
      return this.player_animator;
    };

    Animators.tear = function() {
      var images;
      if (this.tear_animator == null) {
        images = [];
        images[images.length] = AssetRepository.tear_image;
        this.tear_animator = new TearAnimator(images);
      }
      return this.tear_animator;
    };

    return Animators;

  })();

}).call(this);
(function() {
  this.AssetRepository = (function() {
    function AssetRepository() {}

    AssetRepository.load = function() {
      var loaded, numAssets, numLoaded;
      numAssets = 5;
      numLoaded = 0;
      loaded = function() {
        numLoaded++;
        if (numLoaded === numAssets) {
          return Game.init();
        }
      };
      $.getJSON("assets/512.json", (function(_this) {
        return function(json) {
          var pattern;
          _this.datamap = json;
          _this.imagemap = new Image();
          _this.imagemap.onload = function() {
            return loaded();
          };
          pattern = /\w+[.]\w+$/;
          return _this.imagemap.src = "assets/" + (_this.datamap.tilesets[0].image.match(pattern))[0];
        };
      })(this)).done(function() {
        return loaded();
      });
      this.isaac_image = new Image();
      this.isaac_image.onload = function() {
        return loaded();
      };
      this.isaac_image.src = "assets/isaac.png";
      this.hero_image = new Image();
      this.hero_image.onload = function() {
        return loaded();
      };
      this.hero_image.src = "assets/hero_32.png";
      this.tear_image = new Image();
      this.tear_image.onload = function() {
        return loaded();
      };
      return this.tear_image.src = "assets/tear_16.png";
    };

    return AssetRepository;

  })();

}).call(this);
(function() {
  var KEY_CODES, KEY_STATUS, code;

  this.Controller = (function() {
    function Controller() {}

    Controller.prototype.update = function() {
      this.x = 0;
      this.y = 0;
      this.f_x = 0;
      this.f_y = 0;
      if (KEY_STATUS.w) {
        this.y--;
      }
      if (KEY_STATUS.s) {
        this.y++;
      }
      if (KEY_STATUS.a) {
        this.x--;
      }
      if (KEY_STATUS.d) {
        this.x++;
      }
      if (KEY_STATUS.up) {
        this.f_y--;
      }
      if (KEY_STATUS.down) {
        this.f_y++;
      }
      if (KEY_STATUS.left) {
        this.f_x--;
      }
      if (KEY_STATUS.right) {
        return this.f_x++;
      }
    };

    return Controller;

  })();

  KEY_CODES = {
    37: "left",
    38: "up",
    39: "right",
    40: "down",
    65: "a",
    68: "d",
    83: "s",
    87: "w"
  };

  KEY_STATUS = {
    keyDown: false
  };

  for (code in KEY_CODES) {
    KEY_STATUS[KEY_CODES[code]] = false;
  }

  $(window).keydown(function(e) {
    KEY_STATUS.keyDown = true;
    if (KEY_CODES[e.keyCode]) {
      e.preventDefault();
      KEY_STATUS[KEY_CODES[e.keyCode]] = true;
    }
  }).keyup(function(e) {
    KEY_STATUS.keyDown = false;
    if (KEY_CODES[e.keyCode]) {
      e.preventDefault();
      KEY_STATUS[KEY_CODES[e.keyCode]] = false;
    }
  });

}).call(this);
(function() {
  this.Drawable = (function() {
    function Drawable(x, y, w, h) {
      this.x = x;
      this.y = y;
      this.w = w;
      this.h = h;
      this.canvas = document.createElement('canvas');
      this.canvas.width = this.w;
      this.canvas.height = this.h;
      this.ctx = this.canvas.getContext('2d');
      this.draw_rect = new Rectangle(this.x, this.y, this.w, this.h);
    }

    Drawable.prototype.draw = function(canvas) {
      return canvas.getContext('2d').drawImage(this.canvas, this.draw_rect.x, this.draw_rect.y);
    };

    Drawable.prototype.update = function() {
      this.draw_rect.x = this.x;
      this.draw_rect.y = this.y;
      this.draw_rect.w = this.w;
      return this.draw_rect.h = this.h;
    };

    return Drawable;

  })();

}).call(this);
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  this.Entity = (function(_super) {
    __extends(Entity, _super);

    function Entity(x, y, w, h, animator) {
      this.animator = animator;
      Entity.__super__.constructor.apply(this, arguments);
    }

    Entity.prototype.update = function() {
      return Entity.__super__.update.apply(this, arguments);
    };

    return Entity;

  })(Drawable);

}).call(this);
(function() {
  this.Frame = (function() {
    function Frame() {
      var datamap, entity_canvas, imagemap, tile_canvas;
      tile_canvas = $("#tile_canvas").get(0);
      entity_canvas = $("#entity_canvas").get(0);
      imagemap = AssetRepository.imagemap;
      datamap = AssetRepository.datamap;
      this.tilemap = new Tilemap(0, 0, tile_canvas.width, tile_canvas.height, imagemap, datamap);
      this.player = new Player(96, 64, 32, 48, Animators.player());
      this.dirty_rects = [];
      this.dirty_rects[this.dirty_rects.length] = this.player.draw_rect;
      this.map_x = -1;
      this.map_y = -1;
    }

    Frame.prototype.update = function() {
      var dirty_rect, tear, _i, _j, _len, _len1, _ref, _ref1, _results;
      _ref = this.dirty_rects;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        dirty_rect = _ref[_i];
        entity_canvas.getContext('2d').clearRect(Math.floor(dirty_rect.x), Math.floor(dirty_rect.y), dirty_rect.w + 1, dirty_rect.h + 1);
      }
      while (this.dirty_rects.length > 0) {
        this.dirty_rects.pop();
      }
      if (this.map_x !== Math.floor(this.player.cx / entity_canvas.width) || this.map_y !== Math.floor(this.player.cy / entity_canvas.height)) {
        this.map_x = Math.floor(this.player.cx / entity_canvas.width);
        this.map_y = Math.floor(this.player.cy / entity_canvas.height);
        this.tilemap.update(this.map_x, this.map_y);
        this.tilemap.draw(tile_canvas);
      }
      this.player.update(this.tilemap);
      this.player.draw(entity_canvas);
      this.dirty_rects[this.dirty_rects.length] = this.player.draw_rect;
      _ref1 = this.player.tear_pool.alive_tears;
      _results = [];
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        tear = _ref1[_j];
        _results.push(this.dirty_rects[this.dirty_rects.length] = tear.draw_rect);
      }
      return _results;
    };

    return Frame;

  })();

}).call(this);
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    __modulo = function(a, b) { return (+a % (b = +b) + b) % b; };

  this.Player = (function(_super) {
    __extends(Player, _super);

    function Player(x, y, w, h, animator) {
      Player.__super__.constructor.apply(this, arguments);
      this.controller = new Controller();
      this.collision_rect = new Rectangle(this.x + this.w / 4, this.y + this.h / 2, this.w / 2, this.h / 3);
      this.cx = this.collision_rect.x + this.collision_rect.w / 2;
      this.cy = this.collision_rect.y + this.collision_rect.h / 2;
      this.tear_pool = new TearPool();
      this.tts = 0;
      this.f_s = 10;
    }

    Player.prototype.update = function(tilemap) {
      var animation_state, s, tilemap_collisions;
      this.controller.update();
      s = 4;
      if (this.controller.x !== 0 && this.controller.y !== 0) {
        s = s / Math.sqrt(2);
      }
      this.del_x = s * this.controller.x;
      this.del_y = s * this.controller.y;
      this.x += this.del_x;
      this.y += this.del_y;
      this.collision_rect.x = this.x + this.w / 4;
      this.collision_rect.y = this.y + this.h / 2;
      this.collision_rect.w = this.w / 2;
      this.collision_rect.h = this.h / 3;
      tilemap_collisions = tilemap.collision(this.collision_rect);
      if (__indexOf.call(tilemap_collisions, "left") >= 0 && this.del_x < 0 || __indexOf.call(tilemap_collisions, "right") >= 0 && this.del_x > 0) {
        this.x -= this.del_x;
        this.collision_rect.x = this.x + this.w / 4;
        this.collision_rect.w = this.w / 2;
      }
      if (__indexOf.call(tilemap_collisions, "top") >= 0 && this.del_y < 0 || __indexOf.call(tilemap_collisions, "bot") >= 0 && this.del_y > 0) {
        this.y -= this.del_y;
        this.collision_rect.y = this.y + this.h / 2;
        this.collision_rect.h = this.h / 3;
      }
      this.cx = this.collision_rect.x + this.collision_rect.w / 2;
      this.cy = this.collision_rect.y + this.collision_rect.h / 2;
      if (this.tts !== 0) {
        this.tts--;
      }
      if (this.controller.f_x !== 0 && this.tts === 0) {
        this.tear_pool.create_tear(this.x + this.w / 4, this.y + this.h / 8, this.f_s * this.controller.f_x, 0, 60);
        this.tts = 20;
      }
      if (this.controller.f_y !== 0 && this.tts === 0) {
        this.tear_pool.create_tear(this.x + this.w / 4, this.y + this.h / 8, 0, this.f_s * this.controller.f_y, 60);
        this.tts = 20;
      }
      this.tear_pool.update();
      if (this.controller.x === 0 && this.controller.y === 0) {
        animation_state = "idle";
      } else if (this.controller.x === 1) {
        animation_state = "walk_right";
      } else if (this.controller.x === -1) {
        animation_state = "walk_left";
      } else if (this.controller.y === 1) {
        animation_state = "walk_down";
      } else if (this.controller.y === -1) {
        animation_state = "walk_up";
      }
      return this.animator.animate(animation_state, this.ctx);
    };

    Player.prototype.draw = function(canvas) {
      var tear, _i, _len, _ref;
      _ref = this.tear_pool.alive_tears;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        tear = _ref[_i];
        tear.draw(canvas);
      }
      this.draw_rect.x = __modulo(this.x, canvas.width);
      if (Math.floor(this.cx / canvas.width) > Math.floor(this.x / canvas.width)) {
        this.draw_rect.x -= canvas.width;
      }
      this.draw_rect.y = __modulo(this.y, canvas.height);
      if (Math.floor(this.cy / canvas.height) > Math.floor(this.y / canvas.height)) {
        this.draw_rect.y -= canvas.height;
      }
      return Player.__super__.draw.apply(this, arguments);
    };

    return Player;

  })(Entity);

}).call(this);
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  this.PlayerAnimator = (function(_super) {
    __extends(PlayerAnimator, _super);

    function PlayerAnimator() {
      return PlayerAnimator.__super__.constructor.apply(this, arguments);
    }

    PlayerAnimator.prototype.animate = function(state, ctx) {
      var h, w, x_shift;
      w = ctx.canvas.width;
      h = ctx.canvas.height;
      ctx.clearRect(0, 0, w, h);
      this.tick++;
      this.tick %= 80;
      if (this.tick < 0) {
        this.tick += 80;
      }
      x_shift = Math.floor(this.tick / 8) * w;
      switch (state) {
        case "idle":
          this.tick = 0;
          ctx.drawImage(this.images[0], 0, 0, w, 2 * h / 3, 0, h / 3, w, 2 * h / 3);
          return ctx.drawImage(this.images[1], 0, 0, w, 2 * h / 3, 0, 0, w, 2 * h / 3);
        case "walk_right":
          ctx.drawImage(this.images[0], x_shift, 2 * h / 3, w, 2 * h / 3, 0, h / 3, w, 2 * h / 3);
          return ctx.drawImage(this.images[1], 0, 0, w, 2 * h / 3, 0, 0, w, 2 * h / 3);
        case "walk_left":
          ctx.save();
          ctx.translate(w, 0);
          ctx.scale(-1, 1);
          ctx.drawImage(this.images[0], x_shift, 2 * h / 3, w, 2 * h / 3, 0, h / 3, w, 2 * h / 3);
          ctx.drawImage(this.images[1], 0, 0, w, 2 * h / 3, 0, 0, w, 2 * h / 3);
          return ctx.restore();
        case "walk_down":
          ctx.drawImage(this.images[0], x_shift, 0, w, 2 * h / 3, 0, h / 3, w, 2 * h / 3);
          return ctx.drawImage(this.images[1], 0, 0, w, 2 * h / 3, 0, 0, w, 2 * h / 3);
        case "walk_up":
          x_shift = 9 * w - x_shift;
          ctx.drawImage(this.images[0], x_shift, 0, w, 2 * h / 3, 0, h / 3, w, 2 * h / 3);
          return ctx.drawImage(this.images[1], 0, 0, w, 2 * h / 3, 0, 0, w, 2 * h / 3);
      }
    };

    return PlayerAnimator;

  })(Animator);

}).call(this);
(function() {
  this.Rectangle = (function() {
    function Rectangle(x, y, w, h) {
      this.x = x;
      this.y = y;
      this.w = w;
      this.h = h;
    }

    return Rectangle;

  })();

}).call(this);
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __modulo = function(a, b) { return (+a % (b = +b) + b) % b; };

  this.Tear = (function(_super) {
    __extends(Tear, _super);

    function Tear(x, y, w, h, animator) {
      this.ttl = 0;
      this.vx = 0;
      this.vy = 0;
      Tear.__super__.constructor.apply(this, arguments);
    }

    Tear.prototype.update = function() {
      Tear.__super__.update.apply(this, arguments);
      if (this.ttl > 0) {
        this.ttl--;
        this.x += this.vx;
        this.y += this.vy;
        return this.animator.animate("", this.ctx);
      }
    };

    Tear.prototype.draw = function(canvas) {
      this.draw_rect.x = __modulo(this.x, canvas.width);
      this.draw_rect.y = __modulo(this.y, canvas.height);
      if ((this.vx > 0 && this.draw_rect.x <= 32) || (this.vx < 0 && this.draw_rect.x >= canvas.width - 32) || (this.vy > 0 && this.draw_rect.y <= 32) || (this.vy < 0 && this.draw_rect.y >= canvas.height - 32)) {
        this.ttl = 0;
      }
      if (this.ttl !== 0) {
        return Tear.__super__.draw.apply(this, arguments);
      }
    };

    return Tear;

  })(Entity);

}).call(this);
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  this.TearAnimator = (function(_super) {
    __extends(TearAnimator, _super);

    function TearAnimator() {
      return TearAnimator.__super__.constructor.apply(this, arguments);
    }

    TearAnimator.prototype.animate = function(state, ctx) {
      var h, w;
      w = ctx.canvas.width;
      h = ctx.canvas.height;
      ctx.clearRect(0, 0, w, h);
      return ctx.drawImage(this.images[0], 0, 0, w, h, 0, 0, w, h);
    };

    return TearAnimator;

  })(Animator);

}).call(this);
(function() {
  this.TearPool = (function() {
    function TearPool() {
      var i, nTears;
      nTears = 10;
      this.dead_tears = (function() {
        var _i, _results;
        _results = [];
        for (i = _i = 0; 0 <= nTears ? _i < nTears : _i > nTears; i = 0 <= nTears ? ++_i : --_i) {
          _results.push(new Tear(0, 0, 16, 16, Animators.tear()));
        }
        return _results;
      })();
      this.alive_tears = [];
    }

    TearPool.prototype.create_tear = function(x, y, vx, vy, ttl) {
      var tear;
      if (this.dead_tears.length > 0) {
        tear = this.dead_tears.shift();
        tear.x = x;
        tear.y = y;
        tear.vx = vx;
        tear.vy = vy;
        tear.ttl = ttl;
        return this.alive_tears[this.alive_tears.length] = tear;
      }
    };

    TearPool.prototype.update = function() {
      var all, tear, _i, _j, _len, _len1, _ref, _results;
      _ref = this.alive_tears;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        tear = _ref[_i];
        tear.update();
      }
      all = this.dead_tears.concat(this.alive_tears);
      this.dead_tears = [];
      this.alive_tears = [];
      _results = [];
      for (_j = 0, _len1 = all.length; _j < _len1; _j++) {
        tear = all[_j];
        _results.push((tear.ttl === 0 ? this.dead_tears : this.alive_tears).push(tear));
      }
      return _results;
    };

    return TearPool;

  })();

}).call(this);
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  this.Tilemap = (function(_super) {
    __extends(Tilemap, _super);

    function Tilemap(x, y, w, h, imagemap, datamap) {
      var c, l, r, _i, _j, _k, _len, _ref, _ref1, _ref2;
      this.imagemap = imagemap;
      this.datamap = datamap;
      this.collisions = [];
      this.collisions.length = this.datamap.width * this.datamap.height;
      _ref = this.datamap.layers;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        l = _ref[_i];
        if (l.name === "collision") {
          for (c = _j = 0, _ref1 = this.datamap.width; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; c = 0 <= _ref1 ? ++_j : --_j) {
            for (r = _k = 0, _ref2 = this.datamap.height; 0 <= _ref2 ? _k < _ref2 : _k > _ref2; r = 0 <= _ref2 ? ++_k : --_k) {
              this.collisions[r * this.datamap.width + c] = l.data[r * this.datamap.width + c] !== 0;
            }
          }
        }
      }
      Tilemap.__super__.constructor.apply(this, arguments);
    }

    Tilemap.prototype.update = function(map_x, map_y) {
      var angle, c, l, ntx, nty, r, rotation, tile, tilecol, tilerow, _i, _len, _ref, _results;
      ntx = this.w / this.datamap.tilewidth;
      nty = this.h / this.datamap.tileheight;
      _ref = this.datamap.layers;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        l = _ref[_i];
        if (l.name !== "collision") {
          _results.push((function() {
            var _j, _results1;
            _results1 = [];
            for (c = _j = 0; 0 <= ntx ? _j < ntx : _j > ntx; c = 0 <= ntx ? ++_j : --_j) {
              _results1.push((function() {
                var _k, _results2;
                _results2 = [];
                for (r = _k = 0; 0 <= nty ? _k < nty : _k > nty; r = 0 <= nty ? ++_k : --_k) {
                  tile = (l.data[(r + map_y * nty) * this.datamap.width + c + map_x * ntx] - 1) & 0x0FFFFFFF;
                  rotation = (l.data[(r + map_y * nty) * this.datamap.width + c] - 1) & 0xF0000000;
                  angle = 0;
                  if ((rotation ^ 0xA0000000) === 0) {
                    angle = Math.PI / 2;
                  }
                  if ((rotation ^ 0xC0000000) === 0) {
                    angle = Math.PI;
                  }
                  if ((rotation ^ 0x60000000) === 0) {
                    angle = 3 * Math.PI / 2;
                  }
                  tilerow = Math.floor(tile / (this.imagemap.width / this.datamap.tilewidth));
                  tilecol = Math.floor(tile % (this.imagemap.width / this.datamap.tilewidth));
                  this.ctx.save();
                  this.ctx.translate(c * this.datamap.tilewidth, r * this.datamap.tileheight);
                  this.ctx.rotate(angle);
                  this.ctx.drawImage(this.imagemap, tilecol * this.datamap.tilewidth, tilerow * this.datamap.tileheight, this.datamap.tilewidth, this.datamap.tileheight, 0, 0, this.datamap.tilewidth, this.datamap.tileheight);
                  _results2.push(this.ctx.restore());
                }
                return _results2;
              }).call(this));
            }
            return _results1;
          }).call(this));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Tilemap.prototype.collision = function(rect) {
      var cmax, cmin, collisions, rmax, rmin;
      cmin = Math.floor(rect.x / this.datamap.tilewidth);
      cmax = Math.ceil((rect.x + rect.w) / this.datamap.tilewidth);
      rmin = Math.floor(rect.y / this.datamap.tileheight);
      rmax = Math.ceil((rect.y + rect.h) / this.datamap.tileheight);
      collisions = [];
      if (this.collisions[rmin * this.datamap.width + cmin] && this.collisions[rmin * this.datamap.width + cmax]) {
        collisions[collisions.length] = "top";
      }
      if (this.collisions[(rmax - 1) * this.datamap.width + cmin] && this.collisions[(rmax - 1) * this.datamap.width + cmax]) {
        collisions[collisions.length] = "bot";
      }
      if (this.collisions[rmin * this.datamap.width + cmin] && this.collisions[rmax * this.datamap.width + cmin]) {
        collisions[collisions.length] = "left";
      }
      if (this.collisions[rmin * this.datamap.width + cmax - 1] && this.collisions[rmax * this.datamap.width + cmax - 1]) {
        collisions[collisions.length] = "right";
      }
      return collisions;
    };

    return Tilemap;

  })(Drawable);

}).call(this);
(function() {
  this.Game = (function() {
    var animate, requestAnimFrame;

    function Game() {}

    Game.init = function() {
      this.frame = new Frame();
      return animate();
    };

    animate = function() {
      requestAnimFrame(animate);
      return Game.frame.update();
    };

    requestAnimFrame = (function() {
      return window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame || function(callback, element) {
        window.setTimeout(callback, 1000 / 60);
      };
    })();

    return Game;

  })();

  $(function() {
    return AssetRepository.load();
  });

}).call(this);
