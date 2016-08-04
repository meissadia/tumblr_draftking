
module DK
  # tumblr Client
  class Client
    include DK::TDrafts
    include DK::TQueue
    include DK::Posts
    attr_accessor :client, :simulate
    attr_accessor :blog_url, :blog_name, :blog
    attr_accessor :q_size, :d_size
    attr_accessor :comment
    attr_accessor :user

    # Initialize instance of DraftKing for the specified blog
    # @param options[:blog_name] [String] Target blog name
    # @param options[:comment] [String] Default post comment
    def initialize(options = {})
      process_options(options)
      return unless configure_tumblr_client(options)
      @client = Tumblr::Client.new
      act_on_blog(name: options[:blog_name])
    end

    # Read Config
    def process_options(options)
      @comment   = options[:comment].to_s
      @simulate  = options[:simulate]
    end

    # Configure tumblr_client gem
    # @param :file [String] JSON File with API Keys
    # @param :keys [Hash] Hash with API Keys
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
      @blog_url  = @blog_name + '.tumblr.com'
      @user.blogs.each do |blog|
        next unless blog.name == @blog_name
        @blog   = blog
        @q_size = blog.queue
        @d_size = blog.drafts
      end
    end
  end
end
