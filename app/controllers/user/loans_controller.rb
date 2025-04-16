class User::LoansController < ApplicationController
  before_action :authenticate_user!

  def index
    # @loans = current_user.loans.order(created_at: :desc)
      @loans = current_user.loans.includes(:loan_adjustments)
  end

  def new
    @loan = current_user.loans.new
  end

  def create
    @loan = current_user.loans.new(loan_params)
    @loan.state = 'requested'

    if @loan.save
      redirect_to user_loans_path, notice: 'Loan request submitted successfully.'
    else
      render :new, alert: 'Something went wrong.'
    end
  end

  def show
    @loan = current_user.loans.find(params[:id])
    @adjustments = @loan.loan_adjustments.order(created_at: :asc)
  end

  def accept_approval
    loan = current_user.loans.find(params[:id])
  
    if loan.state == 'approved' || loan.state == 'waiting_for_adjustment_acceptance'
      ActiveRecord::Base.transaction do
        loan.update!(state: 'open', opened_at: Time.current)
        current_user.increment!(:wallet_balance, loan.principal_amount)
        admin = User.find_by(role: 'admin')
        admin.decrement!(:wallet_balance, loan.principal_amount)
      end
  
      redirect_to user_loans_path, notice: 'Loan accepted and activated!'
    else
      redirect_to user_loans_path, alert: 'Invalid loan state for approval.'
    end
  end
  
  def reject_approval
    loan = current_user.loans.find(params[:id])
  
    if ['approved', 'waiting_for_adjustment_acceptance'].include?(loan.state)
      loan.update!(state: 'rejected')
      redirect_to user_loans_path, notice: 'You have rejected the loan.'
    else
      redirect_to user_loans_path, alert: 'Invalid action.'
    end
  end
  
  def request_readjustment
    loan = current_user.loans.find(params[:id])
  
    if loan.state == 'waiting_for_adjustment_acceptance'
      loan.update!(state: 'readjustment_requested')
      redirect_to user_loans_path, notice: 'Readjustment request sent to admin.'
    else
      redirect_to user_loans_path, alert: 'Invalid state for readjustment.'
    end
  end

  # def repay
  #   loan = current_user.loans.find(params[:id])
  #   total_due = loan.total_amount_due.round(2)
  #   user_wallet = current_user.wallet_balance
  #   admin = User.find_by(role: 'admin')
  
  #   ActiveRecord::Base.transaction do
  #     if user_wallet >= total_due
  #       current_user.decrement!(:wallet_balance, total_due)
  #       admin.increment!(:wallet_balance, total_due)
  #     else
  #       current_user.update!(wallet_balance: 0)
  #       admin.increment!(:wallet_balance, user_wallet)
  #     end
  
  #     loan.update!(state: 'closed', closed_at: Time.current, total_repaid_amount: user_wallet >= total_due ? total_due : user_wallet)
  #   end
  
  #   redirect_to user_loans_path, notice: "Loan repaid successfully!"
  # end

  # def repay
  #   @loan = current_user.loans.find(params[:id])
  #   total_due = @loan.principal_amount + @loan.accrued_interest
  #   user = current_user
  #   admin = User.find_by(role: "admin")
  
  #   repayment_amount = [user.wallet_balance, total_due].min
  
  #   ActiveRecord::Base.transaction do
  #     user.update!(wallet_balance: user.wallet_balance - repayment_amount)
  #     admin.update!(wallet_balance: admin.wallet_balance + repayment_amount)
  
  #     @loan.update!(
  #       total_repaid_amount: repayment_amount,
  #       state: "closed"
  #     )
  #   end
  
  #   flash[:notice] = "Loan repaid successfully. ₹#{repayment_amount} has been transferred to Admin."
  #   redirect_to user_loans_path
  # end

  def repay
    @loan = current_user.loans.find(params[:id])
    total_due = @loan.principal_amount + @loan.accrued_interest
  
    if current_user.wallet_balance >= total_due
      ActiveRecord::Base.transaction do
        current_user.update!(wallet_balance: current_user.wallet_balance - total_due)
  
        admin = User.find_by(role: "admin")
        admin.update!(wallet_balance: admin.wallet_balance + total_due)
  
        @loan.update!(state: "closed", closed_at: Time.current, total_repaid_amount: total_due)
      end
      redirect_to user_loans_path, notice: "Loan repaid successfully!"
    else
      # Partial repayment
      amount_paid = current_user.wallet_balance
      ActiveRecord::Base.transaction do
        current_user.update!(wallet_balance: 0)
  
        admin = User.find_by(role: "admin")
        admin.update!(wallet_balance: admin.wallet_balance + amount_paid)
  
        @loan.update!(state: "closed", closed_at: Time.current, total_repaid_amount: amount_paid)
      end
      redirect_to user_loans_path, alert: "Partial repayment done due to low wallet balance. Loan marked as closed."
    end
  end
  
  

  def respond_to_adjustment
    @loan = current_user.loans.find(params[:id])
  
    case params[:decision]
    when "accept"
      @loan.update!(state: "open")
      transfer_funds_to_user(@loan)
      flash[:notice] = "Loan adjustment accepted. Loan is now active."
    when "reject"
      @loan.update!(state: "rejected")
      flash[:alert] = "You rejected the adjusted loan."
    when "readjust"
      @loan.update!(state: "readjustment_requested")
      flash[:notice] = "You requested another adjustment. Admin will review it."
    end
  
    redirect_to user_loans_path
  end
  
  private
  
  def transfer_funds_to_user(loan)
    admin = User.find_by(role: "admin")
    if admin.wallet_balance >= loan.principal_amount
      admin.update!(wallet_balance: admin.wallet_balance - loan.principal_amount)
      loan.user.update!(wallet_balance: loan.user.wallet_balance + loan.principal_amount)
    else
      flash[:alert] = "Admin does not have enough balance."
    end
  end
  
  
  private

  def loan_params
    params.require(:loan).permit(:principal_amount, :interest_rate)
  end
end
