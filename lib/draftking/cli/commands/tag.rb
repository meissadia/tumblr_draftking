module DK
  class CLI < Thor
    desc 'tag', 'Generate tags from post comments'
    option :limit,         type: :numeric, aliases: :l, desc: Options.op_strings[:limit]
    option :blog,          type: :string,  aliases: :b, desc: Options.op_strings[:blog]
    option :add_tags,      type: :string,  aliases: :t, desc: Options.op_strings[:add_tags]
    option :source,        type: :string,  aliases: :S, desc: Options.op_strings[:source]
    option :comment,       type: :string,  aliases: :c, desc: Options.op_strings[:comment]
    option :simulate,      type: :boolean, aliases: :s, desc: Options.op_strings[:simulate]
    option :mute,          type: :boolean, aliases: :m, desc: Options.op_strings[:mute]
    option :keep_tags,     type: :boolean, aliases: :k, desc: Options.op_strings[:keep_tags]
    option :keep_comments, type: :boolean, aliases: :K, desc: Options.op_strings[:keep_comments]
    option :credit,        type: :boolean, desc: Options.op_strings[:credit], default: true
    def tag
      opts = process_options(options)
      dk = get_dk_instance(opts)
      dk.tag_posts(opts)
    end
  end
end
