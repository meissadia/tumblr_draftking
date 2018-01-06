require 'terminal-table'

module DK
  # Generate report of object data
  class Reporter
    attr_accessor :headers, :rows, :fields, :title, :objects, :last
    def initialize(opts)
      @objects = opts[:objects]
      @title   = build_title(opts)
      @rows    = opts[:rows]
      @fields  = @rows ? nil : populate_fields(opts[:fields], @objects.first)
      @headers = populate_headers(opts[:headers])
    end

    # Report Title
    # @param opts[:simulate] [Boolean] Show simulation indicator
    # @param opts[:title] [String] Report Title
    def build_title(opts)
      "#{opts[:title]}#{"\n" + REPORT_SIM if opts[:simulate]}"
    end

    # Determine Field List
    # @param fields [[Symbol]] Field Symbol Array
    # @param obj [Object] Example Object
    # @return [[Symbol]] Field List
    def populate_fields(fields, obj = nil)
      # Report all fields, unless specified.
      return fields if fields
      obj.instance_variables.map do |x|
        x = x.to_s.delete('@')
        obj.respond_to?(x) ? x : nil
      end.compact if obj
    end

    # Determine Display Headers
    # @param headers [[String]] Column Headers
    # @return [[String]]
    def populate_headers(headers)
      # Use field names as headers, unless specified
      return headers if headers
      return @fields.map(&:to_s) if @fields
    end

    # Collect report data
    def populate_report_rows
      # Read data based on field list
      return if @rows
      @rows = []
      @objects.each do |object|
        @rows << @fields.map { |field| object.send(field.to_sym) }
      end
    end

    # Display Report
    def show
      populate_report_rows
      opts = { rows: @rows, headings: @headers || [], title: @title }
      puts Terminal::Table.new(opts) unless @rows.empty?
    end
    alias to_s show
  end
end
