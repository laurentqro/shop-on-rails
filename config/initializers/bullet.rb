# Bullet configuration for N+1 query detection
# Enabled in development and test environments

if defined?(Bullet)
  if Rails.env.development?
    Bullet.enable = true

    # Alert in the browser console
    Bullet.alert = false

    # Show notifications in browser
    Bullet.bullet_logger = true

    # Log to Rails logger
    Bullet.rails_logger = true

    # Add footer to each page with warnings
    Bullet.add_footer = true

    # Detect N+1 queries
    Bullet.n_plus_one_query_enable = true

    # Detect eager-loaded associations which are not used
    Bullet.unused_eager_loading_enable = true

    # Detect counter cache that should be used
    Bullet.counter_cache_enable = true

    # Don't raise in development (can be annoying during development)
    Bullet.raise = false
  end

  if Rails.env.test?
    Bullet.enable = true

    # RAISE errors in test environment to prevent N+1 queries from reaching production
    Bullet.raise = true

    # Detect N+1 queries
    Bullet.n_plus_one_query_enable = true

    # Detect unused eager loading
    Bullet.unused_eager_loading_enable = true

    # Detect missing counter cache
    Bullet.counter_cache_enable = true
  end
end
