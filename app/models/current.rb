class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :cart
  delegate :user, to: :session, allow_nil: true
end
