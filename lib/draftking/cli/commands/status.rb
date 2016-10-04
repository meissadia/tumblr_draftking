module DK
  class CLI < Thor
    desc 'status <BLOG>', 'Display queue/draft status for a blog.'
    option :config, type: :string, desc: Options.op_strings[:config]
    def status(blog = nil)
      configured?
      title  = 'Status Report'
      fields = %w(Blog Drafts Queued Q.Space)
      opts = process_options(options.dup.merge(blog: blog))
      dk   = get_dk_instance(opts)
      rows = dk.user.blogs.map do |b|
               next unless blog.nil? || b.name == blog
               [b.name, b.drafts, b.queue, 300 - b.queue.to_i]
             end.compact rescue []
      report = Reporter.new(title: title, rows: rows, headers: fields)
      report.show unless simulate
      report
    end
  end
end
