
class SessionsController < ApplicationController

  def login
    redirect_to '/auth/500px'
  end

  # GET /login
  def logout
    reset_session
    redirect_to root_url
  end

  # GET auth/500px/callback
  def create
    binding.pry
    player = Player.find_or_create_from_auth_hash(auth_hash)
    session[:user_id] = player.id
    redirect_to root_path
  end


  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end

