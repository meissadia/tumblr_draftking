
module DK
  # Tumblr Client
  class Client
    include DK::TDrafts
    include DK::TQueue
    include DK::Posts
    attr_accessor :client, :user
    attr_accessor :blog,   :blog_url
    attr_accessor :q_size, :d_size, :q_space

    # Options
    attr_accessor :comment,  :blog_name, :offset,    :limit
    attr_accessor :shuffle,  :keep_tree, :test_data, :mute
    attr_accessor :simulate, :keep_tags, :before_id, :credit
    attr_accessor :message,  :source,    :auto_tag,  :state

    # Initialize instance of DraftKing for the specified blog
    # @param options[:blog_name] [String] Target blog name
    # @param options[:comment] [String] Default post comment
    def initialize(options = {})
      process_options(options)
      return unless configure_tumblr_client(options)
      @client = Tumblr::Client.new
      act_on_blog(name: @blog_name)
    end

    # Read Config
    def process_options(options)
      @blog_name = options[:blog_name] || @blog_name
      @credit    = options[:credit]    || @credit
      @key_text  = options[:key_text]  || @key_text
      @keep_tree = options[:keep_tree] || @keep_tree
      @keep_tags = options[:keep_tags] || @keep_tags
      @message   = options[:message]   || @message
      @mute      = options[:mute]      || @mute
      @shuffle   = options[:shuffle]   || @shuffle
      @simulate  = options[:simulate]  || @simulate
      @state     = options[:state]     || @state
      @test_data = options[:test_data] || @test_data
      @tags      = options[:add_tags]  || @tags
      @comment   = options[:comment]   || @comment.to_s
      @auto_tag  = options[:tags].nil? ? true : options[:tags]
      @source    = options[:source]    || :draft
      @before_id = options[:before_id] || 0
      @offset    = options[:offset]    || 0
      @limit     = options[:limit]
    end

    # Configure tumblr_client gem
    # @param options[:file] [String] JSON File with API Keys
    # @param options[:keys] [Hash] Hash with API Keys
    def configure_tumblr_client(options)
      keys = DK::Config.validate_keys(options[:keys])
      return DK::Config.configure_tumblr_gem(keys: keys) unless keys.nil?
      DK::Config.configure_tumblr_gem(file: options[:config_file])
    end

    # Collect/Refresh Account Info
    # @param name [String] Name of blog to target
    def act_on_blog(name: nil)
      @user = JSON.parse(@client.info['user'].to_json, object_class: OpenStruct)
      @blog_name = name ? name.gsub('.tumblr.com', '') : @user.blogs.first.name
      @blog_url  = tumblr_url(@blog_name)
      @user.blogs.each do |blog|
        next unless blog.name == @blog_name
        @blog    = blog
        @q_size  = blog.queue
        @d_size  = blog.drafts
        @q_space = 300 - @q_size
      end
    end
  end
end
