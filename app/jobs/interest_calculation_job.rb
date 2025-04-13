class InterestCalculationJob < ApplicationJob
  queue_as :default

  def perform
    Loan.where(state: 'open').find_each do |loan|
      # No DB update here, just log or calculate to be shown live
      # If you store interest in DB, update that field here
      puts "Loan ##{loan.id} - Interest: #{loan.interest_amount.round(2)}"
    end
  end
end

