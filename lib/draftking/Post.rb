module DK
  class Post
    attr_accessor :id, :state, :tags, :comment, :summary, :reblog_key
    def initialize(hash, keep_tree: nil)
      return if hash.nil?
      @id      = hash['id']
      @state   = hash['state'] || DK::DRAFT
      @tags    = hash['tags']
      @comment = hash['reblog']['comment']
      @summary = hash['summary']
      @blog_url   = tumblr_url(hash['blog_name'])
      @reblog_key = hash['reblog_key']
      @keep_tree  = keep_tree.nil? ? false : keep_tree
    end

    def to_s
      "id = #{@id}\n" +
      "state = #{@state}\n" +
      "tags = #{@tags}\n" +
      "comment = #{@comment}\n" +
      "summary = #{@summary}\n" +
      "blog_url = #{@blog_url}\n" +
      "reblog_key = #{@reblog_key}\n" +
      "keep_tree = #{@keep_tree}\n"
    end

    # Change the state of a post
    def change_state(state:)
      return false unless VALID_STATE.include?(state)
      return false if @state == state
      @state = state
      true
    end

    # Add a comment to a post
    def replace_comment(comment:)
      return false if comment.nil? || @comment.include?(comment)
      @comment = comment || @comment
      true
    end

    # Check if a post needs to be modified
    def passes_filter?(filter:)
      return true if filter.nil?
      @comment.include?(filter)
    end

    # Delete a Post
    def delete(client:, simulate: nil)
      return 1 if simulate
      res = client.delete @blog_url, @id
      res['id'] ? 1 : 0
    end

    # Reblog a Post
    def reblog(client:, simulate: nil)
      return 1 if simulate
      client.reblog @blog_url, id: @id, reblog_key: @reblog_key, comment: @comment
    end

    # Save a post
    def save(client:, simulate: nil)
      return 1 if simulate
      res = client.edit @blog_url,
      {
        id:                 @id,
        reblog_key:         @reblog_key,
        state:              @state,
        attach_reblog_tree: @keep_tree,
        tags:               @tags,
        caption:            @comment
      }
      res['id'] ? 1 : 0
    end

    # Generate post tags from post comment
    def generate_tags(keep_tags: nil, add_tags: nil, exclude: nil)
      tags  = @comment.gsub(%r{<(/)?p>}, '').gsub(%r{[\/\\|]}, ',').gsub(' , ', ',').gsub(@comment, '')
      tags += ',' + add_tags unless add_tags.nil?
      tags += ',' + @tags.join(',') if keep_tags
      tags.gsub!(exclude.to_s, '')
      tags.gsub!(%r{^\s*(,)*}, '')
      unless @tags.join(',') == tags
        @tags = tags
        return @tags
      end
      false
    end
  end
end
