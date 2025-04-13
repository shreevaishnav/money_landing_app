# Clear old data
User.destroy_all
Loan.destroy_all

# Create users
admin = User.create!(
  email: "admin@example.com",
  password: "admin123",
  name: "Admin User",
  role: "admin",
  wallet_balance: 1000000.0
)

user1 = User.create!(
  email: "user1@example.com",
  name: "User One",
  password: "user123",
  role: "user",
  wallet_balance: 10000.0
)

user2 = User.create!(
  email: "user2@example.com",
  name: "User Two",
  password: "user123",
  role: "user",
  wallet_balance: 10000.0
)

# Create loans for users
Loan.create!(
  user: user1,
  principal_amount: 1000.0,
  interest_rate: 10.0,
  state: "approved",
  approved_at: Time.current,
  opened_at: Time.current,
  total_repaid_amount: 0.0
)

Loan.create!(
  user: user2,
  principal_amount: 2000.0,
  interest_rate: 12.0,
  state: "requested",
  total_repaid_amount: 0.0
)

puts "Seeded: 1 admin, 2 users, 2 loans"
