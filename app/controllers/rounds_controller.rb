
class RoundsController < ApplicationController

  before_filter :require_user, except: %w(index show)

  def index
    @rounds = Round.order('id desc')
  end

  # GET /rounds/current
  # Show the current user the state of their current round, which is the last
  # round that they participated in/saw when logged in
  def current
    @round = current_user.try(:last_round) || Round.find_or_build_current_round
    show
    render 'show'
  end

  # GET /rounds/next
  # Move the current user to the next round, so that when they log in they'll
  # see scores from the that round
  def next
    round = Round.find_or_build_current_round
    current_user.last_round = round
    current_user.save!
    redirect_to '/rounds/current'
  end

  def show
    @round ||= Round.includes(:participants => :tier).find(params[:id])

    @tiers = @round.participants.includes(:player).group_by(&:tier_id).map do |tier_id, participants|
      [Tier.find(tier_id), participants]
    end

    @tiers.sort_by! { |tier,participants| tier.level }

    @tiers = Hash[@tiers]
  end

  # Re-create all the games from the current round
  def join
    @round = Round.find(params[:round_id])
    participant = @round.participants.where(player_id: current_user.id).first!

    @round.create_games_for(participant)

    redirect_to root_path, notice: 'You have joined the round in progress'
  end

  # Delete all the players games in the current round
  def withdraw
    @round = Round.find(params[:round_id])

    participant = @round.participants.includes(:player).where(player_id: current_user.id).first!

    participant.games.each do |game|
      game.destroy
    end

    redirect_to root_path, notice: 'You have withdrawn from the current round'
  end

end
