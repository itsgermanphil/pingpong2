
class RoundsController < ApplicationController

  before_filter :require_user, only: %w(next)

  def index
    @rounds = Round.order('id desc')
  end

  def current
    @round = current_user.try(:last_round) || Round.find_or_build_current_round
    show
    render 'show'
  end

  def next
    round = Round.find_or_build_current_round
    current_user.last_round = round
    current_user.save!
    redirect_to '/rounds/current'
  end

  def show
    @round ||= Round.includes(:participants => [:game, :tier]).find(params[:id])

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
