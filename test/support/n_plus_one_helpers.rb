# Test helpers for N+1 query detection
module NPlusOneHelpers
  # Assert that a block of code does not trigger N+1 queries
  #
  # Example:
  #   assert_no_n_plus_one_queries do
  #     products = Product.includes(:category).all
  #     products.each { |p| p.category.name }
  #   end
  def assert_no_n_plus_one_queries(&block)
    if defined?(Bullet)
      Bullet.enable = true
      Bullet.start_request

      yield

      Bullet.perform_out_of_channel_notifications if Bullet.notification?

      if Bullet.warnings.present?
        error_message = "N+1 queries detected:\n"
        Bullet.warnings.each do |warning_type, warnings|
          warnings.each do |warning|
            error_message += "  - #{warning_type}: #{warning}\n"
          end
        end
        flunk(error_message)
      end
    else
      yield
    end
  ensure
    Bullet.end_request if defined?(Bullet)
  end

  # Assert that a specific number of queries are executed
  #
  # Example:
  #   assert_queries(2) do
  #     Product.first
  #     Category.first
  #   end
  def assert_queries(expected_count, &block)
    query_count = 0

    counter = ->(*, **) { query_count += 1 }
    ActiveSupport::Notifications.subscribed(counter, "sql.active_record") do
      yield
    end

    assert_equal expected_count, query_count,
      "Expected #{expected_count} queries, but #{query_count} were executed"
  end
end
