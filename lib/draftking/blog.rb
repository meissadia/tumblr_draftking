# Patch for a bug in the tumblr_client 0.8.5 gem
module Tumblr
  module Blog
    def draft(blog_name, options = {})
      validate_options([:limit, :before_id], options)
      get(blog_path(blog_name, 'posts/draft'), options)
    end
  end
end
