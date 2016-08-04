module DK
  class CLI < Thor
    desc 'strip', 'Strip old comments from posts.'
    long_desc <<-LONGDESC
    `strip` will delete other user's previous comments in your Drafts or Queue.
    LONGDESC
    option :limit,     type: :numeric, aliases: :l, desc: Options.op_strings[:limit]
    option :blog,      type: :string,  aliases: :b, desc: Options.op_strings[:blog]
    option :source,    type: :string,  aliases: :S, desc: Options.op_strings[:source]
    option :simulate,  type: :boolean, aliases: :s, desc: Options.op_strings[:simulate]
    def strip
      configured?
      opts = process_options(options)
      dk = get_dk_instance(opts)
      dk.strip_old_comments(opts)
    end
  end
end
