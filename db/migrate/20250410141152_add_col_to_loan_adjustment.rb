class AddColToLoanAdjustment < ActiveRecord::Migration[7.1]
  def change
    add_column :loan_adjustments, :previous_amount, :decimal, precision: 15, scale: 2
    add_column :loan_adjustments, :previous_interest_rate, :decimal, precision: 5, scale: 2
  end
end
