require "test_helper"

class OrganizationTest < ActiveSupport::TestCase
  test "valid organization" do
    organization = Organization.new(
      name: "New Coffee Company",
      billing_email: "billing@newcoffee.com"
    )
    assert organization.valid?
  end

  test "requires name" do
    organization = Organization.new(billing_email: "test@example.com")
    assert_not organization.valid?
    assert_includes organization.errors[:name], "can't be blank"
  end

  test "requires billing_email" do
    organization = Organization.new(name: "Test Org")
    assert_not organization.valid?
    assert_includes organization.errors[:billing_email], "can't be blank"
  end

  test "validates email format" do
    organization = organizations(:acme)
    organization.billing_email = "invalid"
    assert_not organization.valid?
    assert_includes organization.errors[:billing_email], "is invalid"
  end

  test "requires unique billing_email" do
    duplicate = Organization.new(
      name: "Test Org",
      billing_email: organizations(:acme).billing_email
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:billing_email], "has already been taken"
  end
end
