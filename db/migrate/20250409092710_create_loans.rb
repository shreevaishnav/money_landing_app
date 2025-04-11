class CreateLoans < ActiveRecord::Migration[7.1]
  create_table :loans do |t|
    t.references :user, foreign_key: true
    t.decimal :principal_amount, precision: 15, scale: 2
    t.decimal :interest_rate, precision: 5, scale: 2 # as a percentage
    t.string :state, default: 'requested' # AASM states
    t.datetime :approved_at
    t.datetime :opened_at
    t.datetime :closed_at
    t.decimal :total_repaid_amount, precision: 15, scale: 2, default: 0.0
  
    t.timestamps
  end
end


