class RankingsController < ApplicationController
  def index
    @round = Round.active
    @games = @round.games
  end
end
