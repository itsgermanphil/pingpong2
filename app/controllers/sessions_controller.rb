
class SessionsController < ApplicationController

  def login
  end

  # GET /login
  def logout
    reset_session
    redirect_to root_url
  end

  # GET auth/500px/callback
  def create
    player = Player.find_or_create_from_auth_hash(auth_hash)

    current_round.add_player(player)

    session[:user_id] = player.id
    redirect_to root_path
  end


  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end

