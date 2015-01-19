class HomeController < ApplicationController

  before_filter :require_user

  def index
    @games = current_user.games(Round.active)
  end

end
