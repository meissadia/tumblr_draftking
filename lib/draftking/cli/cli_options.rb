module DK
  # Options helper methods for CLI
  class Options
    # Define option descriptions
    def self.op_strings
      d = {}
      d[:add_tags]      = 'Comma separated string of tags to add.'
      d[:blog]          = 'Name of blog to use. Excluding this will default to main blog.'
      d[:comment]       = 'Comment to add to any posts which do not already contain it.'
      d[:filter]        = "Only apply command to posts who's comment contains the FILTER string."
      d[:keep_comments] = 'Keep the previous comments on a post.'
      d[:keep_tags]     = 'Keep existing tags, in addition to newly generated tags.'
      d[:limit]         = 'Restrict number of posts selected.'
      d[:mute]          = 'Suppress progress messages.'
      d[:publish]       = 'Indicate that posts should be moved to the Published state.'
      d[:simulate]      = 'Simulation mode: Display program output without modifying actual tumblr data.'
      d[:source]        = 'Modify posts from your : d-drafts, q-queue'
      d[:state]         = 'Set post state: d-draft, q-queued'
      d[:credit]        = 'Give draftking credit with a tag'
      d
    end

    # String of operation descriptions
    def self.descriptions(array)
      d = op_strings
      array.map { |opt| d[opt] || "not found #{opt}" }.join("\n\n")
    end
  end
end
