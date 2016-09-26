module DK
  # Helpers for Command Line Interface
  module CliHelpers
    VALID_OPTS = [:simulate, :limit, :blog, :key_text, :comment, :add_tags, :mute, :publish, :keep_tags, :keep_comments, :source].freeze

    private

    def get_dk_instance(opts)
      DK::Config.setup unless DK::Config.configured?
      DK::Client.new(opts)
    end

    def configured?
      DK::Config.setup unless DK::Config.configured?
    end

    def process_source(source)
      source = source.to_s
      return :queue if source.include?('q')
      :draft
    end

    def process_options(options)
      opts = options.inject({}) { |memo, (k, v)| memo[k.to_sym] = v; memo }
      opts[:blog_name] = options[:blog] if options[:blog]
      opts[:keep_tree] = options[:keep_comments] if options[:keep_comments]
      opts[:source]    = process_source(options[:source])
      opts[:state]     = DK::PUBLISH if options[:publish]
      opts[:state]   ||= DK::QUEUE   if opts[:source] == :queue
      opts[:state]   ||= DK::DRAFT
      opts
    end
  end
end
