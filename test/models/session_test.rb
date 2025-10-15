require "test_helper"

class SessionTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @session = sessions(:one)
    @valid_attributes = {
      user: @user,
      ip_address: "127.0.0.1",
      user_agent: "Mozilla/5.0 (Test Browser)"
    }
  end

  # Association tests
  test "belongs to user" do
    assert_respond_to @session, :user
    assert_kind_of User, @session.user
  end

  test "session requires a user" do
    session = Session.new(@valid_attributes.except(:user))
    assert_not session.valid?
    assert_includes session.errors[:user], "must exist"
  end

  # Field tests
  test "can create session with ip_address and user_agent" do
    session = Session.create!(@valid_attributes)
    assert_equal "127.0.0.1", session.ip_address
    assert_equal "Mozilla/5.0 (Test Browser)", session.user_agent
  end

  test "ip_address is optional" do
    session = Session.create!(@valid_attributes.merge(ip_address: nil))
    assert_nil session.ip_address
    assert session.persisted?
  end

  test "user_agent is optional" do
    session = Session.create!(@valid_attributes.merge(user_agent: nil))
    assert_nil session.user_agent
    assert session.persisted?
  end

  test "can create multiple sessions for same user" do
    session1 = Session.create!(@valid_attributes)
    session2 = Session.create!(@valid_attributes.merge(ip_address: "192.168.1.1"))

    assert_equal @user, session1.user
    assert_equal @user, session2.user
    assert_equal 2, @user.sessions.where(id: [session1.id, session2.id]).count
  end

  test "destroying user destroys sessions" do
    user = User.create!(
      email_address: "session_test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    session = user.sessions.create!(ip_address: "127.0.0.1", user_agent: "Test")

    assert_difference "Session.count", -1 do
      user.destroy
    end
  end

  test "session tracks ip_address" do
    session = Session.create!(@valid_attributes.merge(ip_address: "203.0.113.42"))
    assert_equal "203.0.113.42", session.ip_address
  end

  test "session tracks user_agent" do
    user_agent = "Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X)"
    session = Session.create!(@valid_attributes.merge(user_agent: user_agent))
    assert_equal user_agent, session.user_agent
  end

  test "session has timestamps" do
    session = Session.create!(@valid_attributes)
    assert_not_nil session.created_at
    assert_not_nil session.updated_at
  end

  test "fixtures are valid" do
    assert @session.valid?
    assert sessions(:two).valid?
  end
end
