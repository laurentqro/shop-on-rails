# frozen_string_literal: true

namespace :sentry do
  desc "Test Sentry error reporting"
  task test: :environment do
    puts "Testing Sentry integration..."
    puts "Environment: #{Rails.env}"
    puts "DSN configured: #{Rails.application.credentials.dig(:sentry, :dsn).present?}"

    begin
      # Trigger a test exception
      raise StandardError, "This is a test error from Sentry rake task - #{Time.current}"
    rescue StandardError => e
      # Capture the exception in Sentry
      Sentry.capture_exception(e)
      puts "\n✓ Test exception captured and sent to Sentry!"
      puts "  Check your Sentry dashboard at: https://o4510354394841088.ingest.de.sentry.io/"
      puts "\n  Exception: #{e.message}"
    end
  end

  desc "Send a test message to Sentry"
  task message: :environment do
    puts "Sending test message to Sentry..."
    Sentry.capture_message("Test message from Rails - #{Time.current}", level: :info)
    puts "✓ Message sent to Sentry!"
    puts "  Check your Sentry dashboard"
  end
end
