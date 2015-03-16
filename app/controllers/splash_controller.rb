class SplashController < ApplicationController
skip_before_action :authorize
  def intro
    respond_to do |format|
      format.html
      format.js
    end
  end

end
