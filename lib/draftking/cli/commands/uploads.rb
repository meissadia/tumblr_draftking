module DK
  class CLI < Thor
    desc 'uploads, ups', 'Batch upload photos from url list.'
    long_desc <<-LONGDESC
    `uploads` will create Drafts from a list of photo urls.

    *** Input File Format ***

    Line type indicators:
      -   (Start of a new caption group)
      #   (Ignore this line during processing)

    Example File:

    -
    Group 1 post caption
    http://example.com/picture1.jpg
    http://example.com/picture2.jpg
    #this line is commented out
    #http://example.com/bad_url.png
    /path/to/file/group1/group1_pic.png
    -
    # this group has no caption
    http://example.com/picture3.jpg
    http://example.com/picture4.jpg
    /path/to/file/picture5.png


    LONGDESC
    option :file,     type: :string,  aliases: :f, desc: Options.op_strings[:file], required: true
    option :link,     type: :string,  aliases: :l, desc: Options.op_strings[:link]
    option :blog,     type: :string,  aliases: :b, desc: Options.op_strings[:blog]
    option :simulate, type: :boolean, aliases: :s, desc: Options.op_strings[:simulate]
    option :mute,     type: :boolean, aliases: :m, desc: Options.op_strings[:mute]
    option :add_tags, type: :string,  aliases: :t, desc: Options.op_strings[:add_tags]
    option :show_pi,  type: :boolean, desc: Options.op_strings[:show_pi], default: true
    option :config,   type: :string,  desc: Options.op_strings[:config]
    def uploads
      configured?
      opts   = process_options(options)
      dk     = get_dk_instance(opts)
      dfile  = opts[:file].chomp.strip

      File.open(dfile, 'r') do |data_file|
        mod = 0
        rows = []
        caption = ''
        row   = Struct.new(:count, :line, :file, :caption, :status)
        title = ups_title(dfile, dk)
        data_file.each_line.with_index do |line, idx|
          line = line.chomp.strip
          next if line.empty? || is_commented?(line)
          (caption = nil) || next if is_url_group?(line)
          (caption = line) && next if is_caption?(line, caption)
          ups_progress(mod, caption) unless dk.mute
          post_opts = ups_opts(line, caption, dk, opts)
          status    = ups_photo_draft(dk, post_opts)
          rows << row.new(mod += 1, idx + 1, File.basename(line), caption, status)
        end # each_line
        ups_report(title, dk, rows)
      end # of data_file
    end # of uploads

    map 'ups' => :uploads # command alias

    private

    def is_url_group?(line)
      line.start_with?('-')
    end

    def is_caption?(line, caption)
      caption.nil? && (!is_file?(line) || !is_url?(line))
    end

    def is_commented?(line)
      line.start_with? '#'
    end

    def is_file?(line)
      line.start_with?('/')
    end

    def is_url?(line)
      line.start_with?('http')
    end

    def ups_photo_draft(dk, post_opts)
      result = { 'id' => 'success' }
      result = dk.client.photo(dk.blog_name, post_opts) unless dk.simulate
      result['id'] ? '√' : result['errors'].first
    end

    def ups_opts(line, caption, dk, opts)
      post_opts = {
        caption: caption,
        state: dk.state,
        tags: comment_to_tags(caption)
      }
      is_url?(line) ? (post_opts[:source] = line) : (post_opts[:data] = [line])
      post_opts[:tags] += ",#{dk.tags}" unless dk.tags.nil?
      post_opts[:link]  = opts[:link]   unless opts[:link].nil?
      post_opts
    end

    def ups_report(title, dk, rows)
      r = DK::Reporter.new(
        title: title,
        fields: DK::UPLOAD_FIELDS,
        simulate: dk.simulate,
        objects: rows
      )
      print ' ' * 80 + "\r\n" # erase_line
      puts "\n#{r}\n" unless dk.mute
    end

    def ups_title(file, dk)
      "DK Batch Uploader\n" \
        "Input: #{file}\n" \
        "Target: #{dk.blog_name} [ #{dk.state.capitalize} ]\n" \
        "#{current_date_string}"
    end

    def ups_progress(mod, caption)
      msg = "Current group: #{caption} • "
      show_progress(current: mod, total: mod, message: msg)
    end

    def comment_to_tags(comment)
      comment += " | #{DK::CREDIT_TAG}"
      comment.slice!('bc / ')            # Remove prefix
      comment.gsub(%r{[\/\\|]}, ',')     # Convert Separators
             .gsub(' , ', ',')           # Clean up tags
    end
  end # of CLI
end # of DK
