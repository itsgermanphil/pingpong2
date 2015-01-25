
class PlayersController < ApplicationController

  before_filter :require_admin

  before_filter :find_player, only: %i(show edit update destroy)

  def index
    @players = Player.order(:id).all
  end

  def show
  end

  def edit
  end

  def update
  end

  def destroy
    @player.destroy
    redirect_to players_path, notice: 'Player destroyed'
  end

  protected

  def find_player
    @player = Player.find(params[:id])
  end
end
