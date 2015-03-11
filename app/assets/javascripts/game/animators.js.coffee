class @Animators
  @player: ->
    unless @player_animator?
      images = []
      images[images.length] = AssetRepository.isaac_image
      images[images.length] = AssetRepository.hero_image
      @player_animator = new PlayerAnimator(images)
    @player_animator
  @tear: ->
    unless @tear_animator?
      images = []
      images[images.length] = AssetRepository.tear_image
      @tear_animator = new TearAnimator(images)
    @tear_animator
