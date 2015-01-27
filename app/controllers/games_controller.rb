
class GamesController < ApplicationController

  before_filter :require_user

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
