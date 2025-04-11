class Loan < ApplicationRecord
  belongs_to :user
  has_many :loan_adjustments, dependent: :destroy
  has_many :interest_logs, dependent: :destroy

  enum state: {
    requested: 'requested',
    approved: 'approved',
    open: 'open',
    closed: 'closed',
    rejected: 'rejected',
    waiting_for_adjustment_acceptance: 'waiting_for_adjustment_acceptance',
    readjustment_requested: 'readjustment_requested'
  }

  validates :principal_amount, :interest_rate, presence: true
end