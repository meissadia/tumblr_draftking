module DK
  # Helpers for Command Line Interface
  module CliHelpers
    VALID_OPTS = [:simulate, :limit, :blog, :key_text, :comment, :add_tags,
                  :mute, :publish, :keep_tags, :keep_comments, :source,
                  :config].freeze

    private

    def get_dk_instance(opts)
      DK::Config.setup unless DK::Config.configured?
      DK::Client.new(opts)
    end

    def configured?
      DK::Config.setup unless DK::Config.configured?
    end

    def process_source(src)
      src = src.to_s
      return :queue if src.include?('q')
      :draft
    end

    def process_options(options)
      opts = options.each_with_object({}) { |(k, v), memo| memo[k.to_sym] = v; memo }
      opts[:blog_name] = options[:blog] if options[:blog]
      opts[:keep_tree] = options[:keep_comments] if options[:keep_comments]
      opts[:source]    = process_source(options[:source])
      opts[:state]     = DK::PUBLISH if options[:publish]
      opts[:state]   ||= DK::QUEUE   if opts[:source] == :queue
      opts[:state]   ||= DK::DRAFT
      process_config(opts)
      opts
    end

    def process_config(opts)
      return unless input = opts[:config]
      input = DK::Config.available_configs[input.to_i].split('.')[1] if is_num_s?(input)
      filename = DK::Config.home_path_file('.' + input + '.dkconfig')
      opts[:keys]   = DK::Config.new(file: filename).config.api_keys
      opts[:config] = filename
    end

    # Numeric String?
    def is_num_s?(input)
      /^[\d_]+$/.match(input)
    end

    def config_to_num(input)
      return nil if input.nil? || DK::Config.available_configs.empty?
      case input
      when /^\d+$/.match(input) # Numeric String
        return input
      when String
        DK::Config.available_configs.each_with_index do |file, idx|
          current = DK::Config.new(file: DK::Config.home_path_file(file))
          return idx.to_s if current.filename == input
        end
      end
    end

    def current_date_string
      Time.now.strftime('%b %d, %H:%M:%S')
    end
  end
end
