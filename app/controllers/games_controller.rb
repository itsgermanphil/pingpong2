
class GamesController < ApplicationController

  def update
    @game = Game.find(params[:id])

    @game.update(game_params)

    redirect_to '/', flash: { notice: 'Game updated' }
  end

  protected

  def game_params
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
