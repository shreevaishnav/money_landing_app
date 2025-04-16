class User::DashboardController < ApplicationController
  before_action :require_normal_user

  def index
    @user = current_user
    @active_loan = @user.loans.where(state: 'open').last
    @loans = current_user.loans.includes(:loan_adjustments)
  end
end
