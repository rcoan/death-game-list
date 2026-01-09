# Create admin user
admin = User.find_or_create_by(email: "admin@example.com") do |user|
  user.password = "password123"
  user.password_confirmation = "password123"
  user.admin = true
end

puts "Admin user created: #{admin.email} (password: password123)"
