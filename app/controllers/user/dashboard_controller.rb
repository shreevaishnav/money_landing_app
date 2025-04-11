class User::DashboardController < ApplicationController
  before_action :require_normal_user

  def index
    @user = current_user
    @loans = @user.loans
  end
end
