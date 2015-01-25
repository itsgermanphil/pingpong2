
class ProfilesController < ApplicationController

  def show
    @player = Player.find(params[:id])
  end

  def edit
    @player = current_user
  end

  def update
    @player = current_user
    @player.update_attributes(player_params)

    if current_user.save
      redirect_to root_path, notice: 'Profile updated'
    else
      render 'edit'
    end
  end

  protected

  def player_params
    params.require(:player).permit(:name)
  end

end
