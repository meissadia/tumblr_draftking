require_relative 'draftking/requires'

module DK
  class Client
    require_relative 'draftking/client_includes'
    attr_accessor :client, :simulate
    attr_accessor :blog_url, :blog_name, :blog_list
    attr_accessor :q_size, :d_size
    attr_accessor :comment
    attr_accessor :user

    # Initialize instance of DraftKing for the specified blog
    # @param options[:blog_name] [String] Target blog name
    # @param options[:comment] [String] Default post comment
    def initialize(options = {})
      process_options(options)
      return unless configure_tumblr(options)
      @client = Tumblr::Client.new
      act_on_blog(name: options[:blog_name])
    end

    # Read Config
    def process_options(options)
      @comment   = options[:comment]
      @simulate  = options[:simulate]
    end

    # Configure tumblr_client gem
    def configure_tumblr(options)
      keys = DK::Config.validate_keys(options[:keys])
      return DK::Config.configure_tumblr_gem(keys: keys) unless keys.nil?
      DK::Config.configure_tumblr_gem(file: options[:config_file])
    end

    # Collect Account Info
    def act_on_blog(name: nil)
      @user      = JSON.parse(@client.info['user'].to_json, object_class: OpenStruct)
      @blog_name = name.nil? ? @user.blogs.first.name : name.gsub('.tumblr.com', '')
      @blog_url  = @blog_name + '.tumblr.com'
      @user.blogs.each do |blog|
        next unless blog.name == @blog_name
        @q_size = blog.queue
        @d_size = blog.drafts
      end
    end

    # Print blog status
    def status
      res  = "#------ #{@blog_name} ------#"
      res += "\nDraft size : #{@d_size}"
      res += "\nQueue size : #{queue_size}"
      res += "\nQueue space: #{queue_space}"
      puts res unless @simulate
      res
    end
  end
end
