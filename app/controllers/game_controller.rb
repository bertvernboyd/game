class GameController < ApplicationController
  def play
    gon.products = ["1", "2", "3"]
    respond_to do |format|
      format.html
      format.js
    end
  end
end
