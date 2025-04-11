class User::LoansController < ApplicationController
  before_action :require_normal_user
  before_action :set_loan, only: [:accept, :reject, :repay]

  def new
    @loan = current_user.loans.build
  end

  def create
    @loan = current_user.loans.build(loan_params)
    if @loan.save
      redirect_to user_dashboard_path, notice: 'Loan requested.'
    else
      render :new
    end
  end

  def accept
    if @loan.waiting_for_adjustment_acceptance? || @loan.approved?
      @loan.update(state: :open)
      current_user.update(wallet_balance: current_user.wallet_balance + @loan.principal_amount)
      User.admin.first.update(wallet_balance: User.admin.first.wallet_balance - @loan.principal_amount)
    end
    redirect_to user_dashboard_path
  end

  def reject
    @loan.update(state: :rejected)
    redirect_to user_dashboard_path
  end

  def repay
    repayment_amount = @loan.total_amount_to_be_paid
    user_wallet = current_user.wallet_balance

    if user_wallet >= repayment_amount
      current_user.update(wallet_balance: user_wallet - repayment_amount)
      User.admin.first.update(wallet_balance: User.admin.first.wallet_balance + repayment_amount)
    else
      User.admin.first.update(wallet_balance: User.admin.first.wallet_balance + user_wallet)
      current_user.update(wallet_balance: 0)
    end

    @loan.update(state: :closed)
    redirect_to user_dashboard_path, notice: "Loan repaid."
  end

  private

  def loan_params
    params.require(:loan).permit(:principal_amount, :interest_rate)
  end

  def set_loan
    @loan = Loan.find(params[:id])
  end
end
