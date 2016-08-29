module DK
  class CLI < Thor
    desc 'status <BLOG>', 'Display queue/draft status for a blog.'
    def status(blog = nil)
      configured?
      opts = process_options(options.dup.merge(blog: blog))
      dk = get_dk_instance(opts)
      dk.user.blogs.map do |b|
        next unless blog.nil? || b.name == blog
        self.class.status_print(b, dk.simulate)
      end
    end

    # Print blog status
    def self.status_print(blog, simulate = false)
      res  = "\n#------ #{blog.name} ------#"
      res += "\nDrafts      : #{blog.drafts}"
      res += "\nQueued      : #{blog.queue}"
      res += "\nQueue space : #{300 - blog.queue.to_i}\n\n"
      puts res unless simulate
      res
    end
  end
end
