class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user

  def require_user
    redirect_to login_path unless current_user
  end

  def current_user
    if session[:user_id]
      begin
        Player.find(session[:user_id])
      rescue ActiveRecord::RecordNotFound => e
        return nil
      end
    end
  end

  def current_round
    Round.find_or_build_current_round
  end

end
