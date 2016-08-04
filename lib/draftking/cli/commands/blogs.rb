module DK
  class CLI < Thor
    desc 'blogs', 'Display a list of blogs under the current account.'
    option :simulate,      type: :boolean, aliases: :s, desc: Options.op_strings[:simulate]
    def blogs
      configured?
      self.class.blogs_print_list(get_dk_instance(options))
    end

    private

    # Print blog list
    # @param dk [DK::Client] Instance of tumblr_draftking
    def self.blogs_print_list(dk)
      result = "\n#-------- Blogs --------#"
      dk.user.blogs.each_with_index do |blog, idx|
        result += "\n#{idx + 1}. #{blog.name}"
      end
      puts result += "\n\n" unless dk.simulate
      result
    end
  end
end
