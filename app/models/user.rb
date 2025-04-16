class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :loans
  has_many :wallet_transactions


  enum role: { user: 'user', admin: 'admin' }

  before_create :set_default_role_and_wallet

  def set_default_role_and_wallet
    self.role ||= 'user'
    self.wallet_balance = (admin? ? 1000000.00 : 10000.00)
  end
end