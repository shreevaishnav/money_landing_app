# class Admin::LoansController < ApplicationController
#   before_action :require_admin
#   before_action :set_loan, only: [:show]

#   def index
#     @loans = Loan.all
#   end

#   def show
#   end

#   def approve
#     if params[:adjusted].present?
#       # If adjustment is being made
#       @loan.update(state: :waiting_for_adjustment_acceptance)
#     else
#       @loan.update(state: :approved)
#     end
#     redirect_to admin_dashboard_path
#   end

#   def reject
#     @loan.update(state: :rejected)
#     redirect_to admin_dashboard_path
#   end

#   private

#   def set_loan
#     @loan = Loan.find(params[:id])
#   end
# end


class Admin::LoansController < ApplicationController
  before_action :require_admin
  before_action :set_loan, only: [:show, :approve, :reject, :adjust, :respond_readjustment]

  def index
    @admin = current_user
    @loans = Loan.includes(:user).order(created_at: :desc)
    @wallet_balance = @admin.wallet_balance
  end

  def show
    @adjustments = @loan.loan_adjustments.order(created_at: :asc)
  end

  def approve
    if params[:adjusted].present?
      @loan.update!(
        state: :waiting_for_adjustment_acceptance,
        principal_amount: params[:principal_amount],
        interest_rate: params[:interest_rate]
      )
      @loan.loan_adjustments.create!(
        previous_amount: @loan.amount_was,
        new_amount: params[:amount],
        previous_interest_rate: @loan.interest_rate_was,
        new_interest_rate: params[:interest_rate],
        adjusted_by_admin: true
      )
    else
      @loan.update!(state: :approved)
    end
    redirect_to admin_loan_path(@loan)
  end

  def reject
    @loan.update!(state: :rejected)
    redirect_to admin_loan_path(@loan)
  end

  def adjust
    # another adjustment after readjustment_requested
    @loan.update!(
      state: :waiting_for_adjustment_acceptance,
      amount: params[:amount],
      interest_rate: params[:interest_rate]
    )
    @loan.loan_adjustments.create!(
      previous_amount: @loan.amount_was,
      new_amount: params[:amount],
      previous_interest_rate: @loan.interest_rate_was,
      new_interest_rate: params[:interest_rate],
      adjusted_by_admin: true
    )
    redirect_to admin_loan_path(@loan)
  end

  def respond_readjustment
    if params[:action_type] == "reject"
      @loan.update!(state: :rejected)
    else
      adjust
    end
    redirect_to admin_loan_path(@loan)
  end

  private

  def set_loan
    @loan = Loan.find(params[:id])
  end

  # def current_admin
  #   Admin.find(session[:admin_id]) if session[:admin_id]
  # end

  # def require_admin
  #   redirect_to admin_login_path unless current_admin
  # end
end
