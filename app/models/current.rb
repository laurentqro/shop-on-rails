class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :user
  attribute :cart
  delegate :user, to: :session, allow_nil: true
end
