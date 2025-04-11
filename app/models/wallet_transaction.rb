class WalletTransaction < ApplicationRecord
  belongs_to :user
  belongs_to :loan, optional: true

  enum transaction_type: { credit: 'credit', debit: 'debit' }

end
