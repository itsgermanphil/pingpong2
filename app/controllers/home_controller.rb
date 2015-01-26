class HomeController < ApplicationController

  before_filter :require_user

  def index
    @round = current_user.last_round || Round.find_or_build_current_round

    unless @round.players.include?(current_user)
      redirect_to onboarding_path
      return
    end

    if current_user.last_round.nil?
      session[:onboarding] = true
      current_user.last_round = @round
      current_user.save!
    end

    @participant = @round.participants.find_by!(player_id: current_user.id)

    if @participant.nil?
      @participant = @round.add_player(current_user)
    end

    @tier = @participant.tier
    @finished_games = @participant.games.finished.order(:id).all
    @unfinished_games = @participant.games.unfinished.order(:id).all
  end

  def dismiss_onboarding
    session.delete(:onboarding)
    redirect_to root_path
  end

end
