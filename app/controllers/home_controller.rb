class HomeController < ApplicationController
  def index
    @games = Player.find_by_name("Michael").games(Round.active)
  end
end
