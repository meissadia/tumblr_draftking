module DK
  class CLI < Thor
    desc 'blogs', 'Display a list of blogs under the current account.'
    option :simulate, type: :boolean, aliases: :s, desc: Options.op_strings[:simulate]
    option :config,   type: :string,  desc: Options.op_strings[:config]
    def blogs
      configured?
      self.class.blogs_print_list(get_dk_instance(process_options(options)))
    end

    private

    # Print blog list
    # @param dk [DK::Client] Instance of tumblr_draftking
    def self.blogs_print_list(dk)
      title  = 'Blogs'
      fields = %w(# blog_name)
      rows   = []
      dk.user.blogs.each_with_index { |blog, idx| rows << [idx + 1, blog.name] }
      report = Reporter.new(title: title, rows: rows, headers: fields)

      report.show unless dk.simulate
      report
    end
  end
end
