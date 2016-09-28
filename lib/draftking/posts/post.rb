require_relative 'posts_helpers'
include DK::Posts

module DK
  # Tumblr Post
  class Post
    attr_accessor :id, :state, :tags, :comment, :summary, :reblog_key
    attr_accessor :keep_tree, :changed, :saved, :blog_url

    # @param hash [Hash] Post Data
    # @param keep_tree [Bool] Attach Reblog Tree?
    def initialize(hash, keep_tree: nil)
      return if hash.nil?
      @id         = hash['id']
      @state      = process_state(hash['state'])
      @tags       = hash['tags']
      @comment    = hash['reblog']['comment']
      @summary    = hash['summary']
      @blog_url   = tumblr_url(hash['blog_name'])
      @reblog_key = hash['reblog_key']
      @keep_tree  = keep_tree.nil? ? false : keep_tree
      @changed    = false
      @saved      = 0
    end

    # String of post data
    def to_s
      "id = #{@id}\n" \
        "state = #{@state}\n" \
        "tags = #{@tags}\n" \
        "comment = #{@comment}\n" \
        "summary = #{@summary}\n" \
        "blog_url = #{@blog_url}\n" \
        "reblog_key = #{@reblog_key}\n" \
        "keep_tree = #{@keep_tree}\n" \
        "changed = #{@changed}\n"
    end

    # Change the state of a post
    # @param state [String] New State
    def change_state(state)
      return false unless VALID_STATE.include?(state)
      return false if @state == state
      @state = state
      @changed = true
    end

    # Add a comment to a post
    # @param comment [String] New Comment
    def replace_comment_with(comment)
      return false if comment.nil? || @comment.include?(comment)
      @comment = comment
      @changed = true
    end

    # Check if a post needs to be modified
    # @param key_text [String] key_text
    def has_key_text?(key_text)
      return true if key_text.nil?
      @comment.include?(key_text)
    end

    # Delete a Post
    # @param client [Tumblr::Client] Instance of tumblr Client
    # @param simulate [Bool] Simulate Action?
    def delete(client:, simulate: nil)
      return 1 if simulate
      res = client.delete @blog_url, @id
      @changed = true if res['id']
      res['id'] ? 1 : 0
    end

    # Reblog a Post
    # @param client [Tumblr::Client] Instance of tumblr Client
    # @param simulate [Bool] Simulate Action?
    def reblog(client:, simulate: nil)
      return 1 if simulate
      client.reblog @blog_url,
                    id: @id,
                    reblog_key: @reblog_key,
                    comment: @comment
    end

    # Save a post
    # @param client [Tumblr::Client] Instance of tumblr Client
    # @param simulate [Bool] Simulate Action?
    def save(client:, simulate: nil)
      return 0 unless @changed
      return @saved = 1 if simulate
      res = client.edit @blog_url,
                        id:                 @id,
                        reblog_key:         @reblog_key,
                        state:              @state,
                        attach_reblog_tree: @keep_tree,
                        tags:               @tags.join(','),
                        caption:            @comment
      return 0 unless res['id']
      @changed = false
      @saved   = 1
    end

    # Generate post tags from post comment
    # @param keep_tags [Bool] Preserve Existing Tags?
    # @param add_tags [String] New tags
    # @param exclude [String] Tags to exclude
    # @param credit [Bool] Give draftking a tag credit
    def generate_tags(keep_tags: nil, add_tags: nil, exclude: nil, credit: false)
      tags  = comment_to_tags(@comment)
      tags += csv_to_a(add_tags)    if add_tags
      tags += @tags                 if keep_tags
      tags << DK::CREDIT_TAG        if credit
      tags -= csv_to_a(exclude)     if exclude
      @changed = true unless @tags.sort.uniq == tags.sort.uniq
      @tags = tags
    end

    # Remove existing Post tags
    def clear_tags
      @changed = true unless @tags.empty?
      @tags = []
    end

    private

    def process_state(state)
      return DK::DRAFT unless state
      return DK::QUEUE if state == 'queued'
      state
    end

    def comment_to_tags(comment)
      comment.gsub(HTML_TAG_PATTERN, '') # Remove HTML Tags
             .gsub(%r{[\/\\|]}, ',')     # Convert Separators
             .gsub(' , ', ',')           # Clean up tags
             .split(',')                 # Return array
    end

    def csv_to_a(csv)
      csv.split(',')
    end
  end
end
