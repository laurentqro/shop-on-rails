# Bullet configuration for N+1 query detection
# Only enabled in development environment

if defined?(Bullet) && Rails.env.development?
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

  # Raise error in development to force fixes (optional - can be annoying)
  # Bullet.raise = true
end
