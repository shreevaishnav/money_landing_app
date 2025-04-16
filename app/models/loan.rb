class Loan < ApplicationRecord
  belongs_to :user
  has_many :loan_adjustments, dependent: :destroy
  
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

  def interest_amount
    return 0 unless opened_at.present? && open?
    minutes = ((Time.current - opened_at) / 60).to_i
    intervals = minutes / 5
    interest_per_interval = (principal_amount * interest_rate * (5.0 / 525600)) / 100
    interest_per_interval * intervals
  end

  def accrued_interest
    return 0 unless opened_at
    minutes = ((Time.current - opened_at) / 60).to_i
    interest = (principal_amount * (interest_rate / 100.0)) * (minutes / 5.0)
    interest.round(2)
  end
  
  
  def total_amount_due
    principal_amount + interest_amount
  end
  
  def open?
    state == 'open'
  end
end