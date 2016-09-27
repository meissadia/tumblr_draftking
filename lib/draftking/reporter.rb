require 'terminal-table'

module DK
  # PostReporter
  class PostReporter
    attr_accessor :posts, :headers, :rows, :fields
    def initialize(opts)
      @posts   = opts[:posts]
      @fields  = populate_fields(opts[:fields])
      @headers = populate_headers(opts[:headers])
      @title   = opts[:title]
    end

    def populate_fields(fields)
      return fields if fields
      res = @posts.first.instance_variables.map do |x|
        x = x.to_s.delete('@')
        @posts.first.respond_to?(x) ? x : nil
      end.compact
    end

    def populate_headers(headers)
      return headers if headers
      return @fields.map(&:to_s) if @fields
    end

    def populate_report_rows
      @rows = [] # clear existing report data
      @posts.each do |post|
        @rows << @fields.map { |field| post.send(field.to_sym) }
      end
    end

    def show
      populate_report_rows
      opts = { rows: @rows, headings: @headers, title: @title }
      puts Terminal::Table.new(opts) unless @rows.empty?
    end
  end
end
