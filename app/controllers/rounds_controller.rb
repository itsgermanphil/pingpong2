
class RoundsController < ApplicationController

  def index
    @rounds = Round.all
  end

  def show
    @round = Round.find(params[:id])

    @tiers = @round.participants.includes(:player).group_by(&:tier_id).map do |tier_id, participants|
      [Tier.find(tier_id), participants]
    end

    @tiers = Hash[@tiers]
  end

  def withdraw
    @round = Round.find(params[:round_id])

    participant = @round.participants.includes(:player).where(player_id: current_user.id).first

    participant.games.unfinished.each do |game|
      game.forfeit!(participant)
    end

    redirect_to root_path, notice: 'You have withdrawn from the current round'
  end

end
