require_relative 'posts_helpers'
include DK::Posts

module DK
  # Tumblr Post
  class Post
    attr_accessor :comment, :image, :photoset, :changed, :saved, :comment
    attr_accessor :state, :data, :reblog_key, :tags, :blog_url, :summary
    # @param hash [Hash] Post Data
    # @param keep_tree [Bool] Attach Reblog Tree?
    def initialize(hash, keep_tree: nil)
      return if hash.nil?
      @data       = JSON.parse(hash.to_json, object_class: OpenStruct)

      # Translate
      @state      = process_state(@data.state)
      @blog_url   = tumblr_url(@data.blog_name)
      @image      = original_image_url
      @photoset   = @data.photoset_layout
      @keep_tree  = keep_tree.nil? ? false : keep_tree
      @changed    = false
      @saved      = 0
      @comment    = @data.reblog.comment
      @from       = begin
                      @data.trail.first.blog.name
                    rescue
                      '<no ID>'
                    end

      # Direct map
      @id         = @data.id
      @reblog_key = @data.reblog_key
      @summary    = @data.summary
      @tags       = @data.tags

      make_accessors(instance_variables)
    end

    # String of post data
    def to_s
      to_h.map { |k, v| "#{k} = #{v}" }.join("\n")
    end

    # Hash of post data
    def to_h
      {
        tumblr_id: @id,
        state: @state,
        tags: @tags.join(','),
        comment: @comment,
        summary: @summary,
        blog_url: @blog_url,
        reblog_key: @reblog_key,
        keep_tree: @keep_tree,
        modified: @changed,
        image: @image
      }
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
    # @param client [Tumblr::Client] Instance of Tumblr Client
    # @param simulate [Bool] Simulate Action?
    def delete(client:, simulate: nil)
      return 1 if simulate
      res = client.delete @blog_url, id
      @changed = true if res['id']
      res['id'] ? 1 : 0
    end

    # Reblog a Post
    # @param client [Tumblr::Client] Instance of Tumblr Client
    # @param simulate [Bool] Simulate Action?
    def reblog(client:, simulate: nil)
      return 1 if simulate
      retries = 0
      begin
        client.reblog @blog_url,
                      id: id,
                      reblog_key: @reblog_key,
                      comment: @comment
      rescue
        retries += 1
        retry unless retries > MAX_RETRY
        raise IOError, 'Connection to Tumblr timed-out!'
      end
    end

    # Save a post
    # @param client [Tumblr::Client] Instance of Tumblr Client
    # @param simulate [Bool] Simulate Action?
    def save(client:, simulate: nil)
      return 0 unless @changed
      return @saved = 1 if simulate
      retries = 0
      begin
        res = client.edit @blog_url,
                          id:                 id,
                          reblog_key:         @reblog_key,
                          state:              validate_state,
                          attach_reblog_tree: @keep_tree,
                          tags:               @tags.join(','),
                          caption:            @comment
      rescue
        retries += 1
        retry unless retries > MAX_RETRY
        raise IOError, 'Connection to Tumblr timed-out!'
      end
      return 0 unless res && res['id']
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

    # Appends CSV or array of tags
    def add_tags(tags)
      tags = csv_to_a(tags) if tags.is_a? String
      @tags += tags
    end

    private

    def make_accessors(keys)
      for key in keys
        singleton_class.class_eval { attr_accessor key.to_s.delete('@') }
      end
    end

    def method_missing(method, *args)
      if @data.respond_to?(method)
        return @data.send(method) unless method.to_s.include?('=')
        @data.send(method, args)
      end
    end

    def original_image_url
      return nil unless @data.photos
      @data.photos.first.original_size.url unless @data.photos.empty?
    end

    def process_state(state)
      return DK::DRAFT unless state || state.empty
      return DK::QUEUE if state == 'queued'
      return DK::PUBLISH if state.include?('pub')
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

    def validate_state
      raise "Invalid Post.state: #{@state}" unless VALID_STATE.include?(@state)
      @state
    end
  end
end
