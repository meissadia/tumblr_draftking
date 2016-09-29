require_relative 'test_helper'

class TestReporter < Minitest::Test
  class Sprinkler
    attr_accessor :id, :on, :distance
    def initialize(opts)
      opts.each_pair { |k, v| send("#{k}=", v) }
    end
  end
  class CustomReporter < DK::Reporter
    def initialize(opts)
      super(opts)
    end

    def show
      populate_report_rows
      @headers = @headers.map { |x| x.to_s + '-CUSTOM' }
      opts = { rows: @rows, headings: @headers, title: @title }
      puts Terminal::Table.new(opts) unless @rows.empty?
    end
  end

  def test_report_on_objects
    objects = (1..5).map { |x| Sprinkler.new(id: x, on: [true, false].sample, distance: [1, 2, 3, 4].sample) }
    report = CustomReporter.new(objects: objects, title: 'Sprinkler Configuration Report')
    refute report.fields.empty?,  'Default of fields failed'
    refute report.headers.empty?, 'Default of headers failed'
    report.show

    field_list = %w(on id)
    report = DK::Reporter.new(objects: objects, title: 'Sprinkler Configuration Report 2', fields: field_list)
    assert_equal field_list, report.fields, 'Custom fields failed'
    assert_equal field_list, report.headers, 'Custom headers failed'
  end
end
