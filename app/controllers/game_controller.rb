class GameController < ApplicationController
  skip_before_action :authorize, only: [:play]

  
  def play
    gon.products = ["1", "2", "3"]
    respond_to do |format|
      format.html
      format.js
    end
  end

  def intro
    respond_to do |format|
      format.html
      format.js
    end
  end
end
