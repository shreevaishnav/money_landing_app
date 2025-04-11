class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  def require_admin
    redirect_to root_path, alert: "Access denied!" unless current_user&.admin?
  end

  def require_normal_user
    redirect_to root_path, alert: "Admins can't access user panel!" if current_user&.admin?
  end
  



  def after_sign_in_path_for(resource)
    current_user.admin? ? admin_dashboard_path : user_dashboard_path
  end
  
end
