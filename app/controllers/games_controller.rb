
class GamesController < ApplicationController

  before_filter :require_user

  def new
  end

  def new2
    @player2 = Player.find(params[:player2_id])
    @game = Game.new
  end

  def create

    player2 = Player.find(params[:game][:player2_id])

    game = Game.new

    game.score1 = params[:game][:score1]
    game.score2 = params[:game][:score2]

    Round.transaction do
      r = Round.free_play_round
      t = Tier.where(round_id: r.id).first

      game.round = r

      p1 = Participant.new
      p2 = Participant.new

      p1.player = current_user
      p2.player = player2

      p1.round = p2.round = r
      p1.tier = p2.tier =t

      game.participant1 = p1
      game.participant2 = p2

      game.save!
      p1.save!
      p2.save!
    end

    redirect_to game
  end

  def show
    @game = Game.find(params[:id])
  end

  def update
    @game = Game.find(params[:id])

    raise ActiveRecord::RecordNotFound unless @game.participant1.player == current_user || @game.participant2.player == current_user

    @game.update(game_params)
    redirect_to root_path, notice: 'Game updated'
  end

  protected

  def game_params
    # Game params come in in the form
    # score_[participant_id1]: value
    # score_[participant_id2]: value
    p = {}
    params[:game].each do |key,value|
      key = key.gsub(/score_/, '').to_i
      if @game.participant1_id == key
        p[:score1] = value
      elsif @game.participant2_id == key
        p[:score2] = value
      else
        raise "Invalid argument, #{key}"
      end
    end
    p
  end

end
