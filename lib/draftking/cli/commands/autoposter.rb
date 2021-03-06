module DK
  class CLI < Thor
    desc 'autoposter, ap', 'Publish up to 200 posts per 24 hours.'
    long_desc <<-LONGDESC
    `ap` will publish up to 200 posts per 24 hours from your Drafts or Queue.

    Any posts already containing <COMMENT> will be ignored.
    To clear comments you've added, call `comment ' '`.

    Note:
    - Old tags are removed by default. Pass -k option to preserve them.
    - Previous comments are be removed by default. Pass -K option to preserve them.
    - New tags will be generated by from the comment contents. Use -t <tags> for additional tagging.
    LONGDESC
    option :comment,       type: :string,  aliases: :c, desc: Options.op_strings[:comment]
    option :blog,          type: :string,  aliases: :b, desc: Options.op_strings[:blog]
    option :add_tags,      type: :string,  aliases: :t, desc: Options.op_strings[:add_tags]
    option :source,        type: :string,  aliases: :S, desc: Options.op_strings[:source]
    option :simulate,      type: :boolean, aliases: :s, desc: Options.op_strings[:simulate]
    option :keep_tags,     type: :boolean, aliases: :k, desc: Options.op_strings[:keep_tags]
    option :keep_comments, type: :boolean, aliases: :K, desc: Options.op_strings[:keep_comments]
    option :credit,        type: :boolean, desc: Options.op_strings[:credit],  default: true
    option :tags,          type: :boolean, desc: Options.op_strings[:tags],    default: true
    option :show_pi,       type: :boolean, desc: Options.op_strings[:show_pi], default: true
    option :config,        type: :string,  desc: Options.op_strings[:config]
    def autoposter
      configured?
      opts = process_options(options)
      dk = get_dk_instance(opts)
      dk.auto_poster(opts)
    end
    map 'ap' => :autoposter
  end
end
