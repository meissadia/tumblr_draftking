module Tumblr
  # Tumblr::Blog patch
  module Blog
    # Patch for a bug in the tumblr_client 0.8.5 gem
    def draft(blog_name, options = {})
      validate_options([:limit, :before_id], options)
      get(blog_path(blog_name, 'posts/draft'), options)
    end
  end
end
