# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_04_10_141152) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "loan_adjustments", force: :cascade do |t|
    t.bigint "loan_id"
    t.decimal "adjusted_amount", precision: 15, scale: 2
    t.decimal "adjusted_interest_rate", precision: 5, scale: 2
    t.string "made_by"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "previous_amount", precision: 15, scale: 2
    t.decimal "previous_interest_rate", precision: 5, scale: 2
    t.index ["loan_id"], name: "index_loan_adjustments_on_loan_id"
  end

  create_table "loans", force: :cascade do |t|
    t.bigint "user_id"
    t.decimal "principal_amount", precision: 15, scale: 2
    t.decimal "interest_rate", precision: 5, scale: 2
    t.string "state", default: "requested"
    t.datetime "approved_at"
    t.datetime "opened_at"
    t.datetime "closed_at"
    t.decimal "total_repaid_amount", precision: 15, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_loans_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.string "role", default: "user"
    t.decimal "wallet_balance", precision: 15, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wallet_transactions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.decimal "amount", precision: 15, scale: 2
    t.string "transaction_type"
    t.string "reason"
    t.bigint "loan_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["loan_id"], name: "index_wallet_transactions_on_loan_id"
    t.index ["user_id"], name: "index_wallet_transactions_on_user_id"
  end

  add_foreign_key "loan_adjustments", "loans"
  add_foreign_key "loans", "users"
  add_foreign_key "wallet_transactions", "loans"
  add_foreign_key "wallet_transactions", "users"
end
