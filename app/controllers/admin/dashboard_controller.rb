class Admin::DashboardController < ApplicationController
  before_action :require_admin

  def index
    @user_count = User.where(role: "user").count
    @total_loans = Loan.all.count
    @approved_count = Loan.where(state: "approved").count
    @rejected_count = Loan.where(state: "rejected").count
    @pending_loans = Loan.requested.or(Loan.readjustment_requested)
  end

  def users
    @users = User.where(role: "user")
  end
end