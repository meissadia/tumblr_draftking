module DK
  class CLI < Thor
    desc 'comment <COMMENT>', 'Add a <COMMENT> to posts.'
    long_desc <<-LONGDESC
    `comment <COMMENT>` will add <COMMENT> to posts in your Drafts or Queue.

    Any posts already containing <COMMENT> will be ignored.
    To clear comments you've added, call `comment ' '`.

    Note:
    - Old tags are removed by default. Pass -k option to preserve them.
    - Previous comments are be removed by default. Pass -K option to preserve them.
    - New tags will be generated by from the comment contents. Use -t <tags> for additional tagging.
    LONGDESC
    option :limit,         type: :numeric, aliases: :l, desc: Options.op_strings[:limit]
    option :blog,          type: :string,  aliases: :b, desc: Options.op_strings[:blog]
    option :add_tags,      type: :string,  aliases: :t, desc: Options.op_strings[:add_tags]
    option :source,        type: :string,  aliases: :S, desc: Options.op_strings[:source]
    option :simulate,      type: :boolean, aliases: :s, desc: Options.op_strings[:simulate]
    option :mute,          type: :boolean, aliases: :m, desc: Options.op_strings[:mute]
    option :keep_tags,     type: :boolean, aliases: :k, desc: Options.op_strings[:keep_tags]
    option :keep_comments, type: :boolean, aliases: :K, desc: Options.op_strings[:keep_comments]
    option :credit,        type: :boolean, desc: Options.op_strings[:credit], default: true
    option :tags,          type: :boolean, desc: Options.op_strings[:tags],   default: true
    def comment(comm)
      configured?
      opts = process_options(options)
      opts[:comment] = comm
      dk = get_dk_instance(opts)
      dk.comment_posts(opts)
    end
  end
end
