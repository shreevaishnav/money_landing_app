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
      # Store old values before update
      previous_amount = @loan.principal_amount
      previous_interest_rate = @loan.interest_rate

      # Update loan with new values
      @loan.update!(
        state: :waiting_for_adjustment_acceptance,
        principal_amount: params[:principal_amount],
        interest_rate: params[:interest_rate]
      )

      # Create adjustment record
      @loan.loan_adjustments.create!(
        previous_amount: previous_amount,
        adjusted_amount: params[:principal_amount],
        previous_interest_rate: previous_interest_rate,
        adjusted_interest_rate: params[:interest_rate],
        made_by: current_user.role,
        note: params[:note]
      )
    else
      @loan.update!(state: :approved, approved_at: Time.current)
    end
    redirect_to admin_loan_path(@loan)
  end

  def reject
    @loan.update!(state: :rejected)
    redirect_to admin_loan_path(@loan)
  end

  def adjust
    # Store old values before update
    previous_amount = @loan.principal_amount
    previous_interest_rate = @loan.interest_rate

    # Update loan
    @loan.update!(
      state: :waiting_for_adjustment_acceptance,
      principal_amount: params[:principal_amount],
      interest_rate: params[:interest_rate]
    )

    # Create new adjustment entry
    @loan.loan_adjustments.create!(
      previous_amount: previous_amount,
      adjusted_amount: params[:principal_amount],
      previous_interest_rate: previous_interest_rate,
      adjusted_interest_rate: params[:interest_rate],
      made_by: current_user.role,
      note: params[:note]
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
end
