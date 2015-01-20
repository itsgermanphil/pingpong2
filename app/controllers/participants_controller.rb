
class ParticipantsController < ApplicationController
  def show
    @round = Round.find(params[:round_id])
    @participant = @round.participants.includes(:tier).find(params[:id])
    @games = @participant.games
  end
end

