# Patch for bugs in the tumblr_client 0.8.5 gem
module Tumblr
  # Tumblr::Blog patch
  module Blog
    def blog_likes(blog_name, options = {})
      validate_options([:limit, :before, :after, :offset], options)
      url = blog_path(blog_name, 'likes')

      params = { api_key: @consumer_key }
      params.merge! options
      get(url, params)
    end
  end
  module User
    def dashboard(options = {})
      valid_opts = [:limit, :offset, :type, :since_id, :reblog_info, :notes_info, :max_id]
      validate_options(valid_opts, options)
      get('v2/user/dashboard', options)
    end

    def likes(options = {})
      validate_options([:limit, :offset, :before, :after], options)
      get('v2/user/likes', options)
    end

    def queue(blog_name, options = {})
      validate_options([:limit, :offset], options)
      get(blog_path(blog_name, 'posts/queue'), options)
    end

    def draft(blog_name, options = {})
      validate_options([:limit, :before_id], options)
      get(blog_path(blog_name, 'posts/draft'), options)
    end
  end
end
