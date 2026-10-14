require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should not save user without username" do
    user = User.new(email: "test@example.com", password: "password123")
    assert_not user.save, "Saved the user without a username"
  end

  test "should not save user without email" do
    user = User.new(username: "testuser", password: "password123")
    assert_not user.save, "Saved the user without an email"
  end

  test "should not save user with duplicate username" do
    # Create the first user
    User.create!(username: "testuser", email: "test@example.com", password: "password123")

    # Try to create another user with the same username
    user2 = User.new(username: "testuser", email: "test2@example.com", password: "password123")
    assert_not user2.save, "Saved the user with a duplicate username"
  end

  test "admin? method should return true if role is admin" do
    user = User.new(username: "adminuser", email: "admin@example.com", password: "password", role: "admin")
    assert user.admin?, "admin? method returned false for an admin user"
  end

  test "admin? method should return false if role is not admin" do
    user = User.new(username: "normaluser", email: "normal@example.com", password: "password", role: "user")
    assert_not user.admin?, "admin? method returned true for a normal user"
  end
end
