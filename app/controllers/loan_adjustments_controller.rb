class LoanAdjustmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_loan

  def new
    @adjustment = @loan.loan_adjustments.build
  end

  def create
    @adjustment = @loan.loan_adjustments.build(adjustment_params)
    @adjustment.made_by = current_user.role

    if @adjustment.save
      @loan.update(state: 'waiting_for_adjustment_acceptance')
      redirect_to dashboard_path, notice: "Adjustment proposed."
    else
      render :new
    end
  end

  private

  def set_loan
    @loan = Loan.find(params[:loan_id])
  end

  def adjustment_params
    params.require(:loan_adjustment).permit(:adjusted_amount, :adjusted_interest_rate, :note)
  end
end
