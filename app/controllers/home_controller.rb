class HomeController < ApplicationController

  before_filter :require_user

  def index
    @round = Round.find_or_build_current_round

    @participant = @round.participants.includes(:tier).where(player_id: current_user.id).first

    if @participant.nil?
      @participant = @round.add_player(current_user)
    end

    @tier = @participant.tier
    @games = @participant.games
  end

end
