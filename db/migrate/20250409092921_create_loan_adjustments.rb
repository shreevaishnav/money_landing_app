class CreateLoanAdjustments < ActiveRecord::Migration[7.1]
  create_table :loan_adjustments do |t|
    t.references :loan, foreign_key: true
    t.decimal :adjusted_amount, precision: 15, scale: 2
    t.decimal :adjusted_interest_rate, precision: 5, scale: 2
    t.string :made_by # 'admin' or 'user'
    t.text :note
  
    t.timestamps
  end
end


