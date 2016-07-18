require_relative 'draftking/requires'

module DK
  class Client
    require_relative 'draftking/client_includes'
    attr_accessor :client, :caption, :simulate
    attr_accessor :blog_url, :blog_list, :blog_name
    attr_accessor :q_size, :d_size

    # Initialize instance of DraftKing for the specified blog
    # @param blogName [String] blog name
    # @param options[:caption] [String] Default post caption
    def initialize(options = {})
      process_options(options)
      DK::DkConfig.configure_tumblr_gem
      account_info(Tumblr::Client.new)
    end

    # Read Config
    def process_options(options)
      @blog_name = options[:blog_name]
      @caption   = options[:caption]
      @simulate  = options[:simulate]
    end

    # Collect Account Info
    def account_info(client)
      @client      = client
      account      = JSON.parse(@client.info.to_json, object_class: OpenStruct)
      @blog_name ||= account.user.blogs.first.name
      @blog_url    = @blog_name + '.tumblr.com'
      list         = []
      account.user.blogs.each do |blog|
        list << blog.name
        next unless blog.name == @blog_name
        @q_size = blog.queue
        @d_size = blog.drafts
      end
      @blog_list = list
    end

    # Print blog status
    def status
      res  = " #------ #{@blog_name} ------#"
      res += "\nDraft size : #{@d_size}"
      res += "\nQueue size : #{queue_size}"
      res += "\nQueue space: #{queue_space}"
      puts res unless @simulate
      res
    end

    # Print blog list
    def list_blogs
      result = "\n#-------- Blogs --------#"
      @blog_list.each_with_index do |blog, idx|
        result += "\n#{idx + 1}. #{blog}"
      end
      puts result += "\n" unless @simulate
      result if @simulate
    end

    # Version
    def self.version
      "tumblr_draftking #{DK::VERSION}"
    end
  end
end
