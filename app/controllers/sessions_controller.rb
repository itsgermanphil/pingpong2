
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
    begin
      player = Player.find_or_create_from_auth_hash(auth_hash)
    rescue Player::AuthorizationError
      redirect_to unauthorized_path
      return
    end

    session[:user_id] = player.id

    if player.last_round.nil?
      redirect_to onboarding_path
    else
      redirect_to root_path
    end
  end

  # GET /onboarding
  def onboarding

  end

  # POST /rounds/join
  def join
    current_round.add_player(current_user)
    redirect_to root_path
  end

  def unauthorized
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end

