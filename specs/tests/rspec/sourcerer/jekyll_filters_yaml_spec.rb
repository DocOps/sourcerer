# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'liquid_filters_spec_helper'

RSpec.describe 'Jekyll Liquid Filters' do
  let(:filters_data) { LiquidFiltersSpecHelper.load_filters_yaml }
  let(:jekyll_filters) { LiquidFiltersSpecHelper.filters(source: 'jekyll') }

  before do
    # Ensure Liquid runtime is initialized with Jekyll filters
    Sourcerer::Jekyll.initialize_liquid_runtime
  end

  around do |example|
    # Jekyll's date filters call `.localtime`, so fixture expectations that
    # assert a specific UTC offset (e.g. date_to_rfc822) are only stable when
    # the process timezone matches the timezone the fixtures were written for.
    original_tz = ENV.fetch('TZ', nil)
    ENV['TZ'] = 'America/Los_Angeles'
    example.run
  ensure
    ENV['TZ'] = original_tz
  end

  describe 'Filter inventory' do
    it 'includes Jekyll filters' do
      expect(jekyll_filters.size).to be_positive
    end

    it 'each filter has required fields' do
      jekyll_filters.each do |filter|
        expect(filter).to have_key('key')
        expect(filter).to have_key('name')
        expect(filter).to have_key('source')
      end
    end
  end

  describe 'Testable examples' do
    jekyll_filters = LiquidFiltersSpecHelper.filters(source: 'jekyll')

    jekyll_filters.each do |filter|
      testable_examples = LiquidFiltersSpecHelper.testable_examples(filter)

      next if testable_examples.empty?

      describe "#{filter['name']} (#{filter['key']})" do
        testable_examples.each_with_index do |example, idx|
          it "example #{idx + 1}: #{example['input'].split("\n").first[0..50]}..." do
            context = LiquidFiltersSpecHelper.example_context
            actual = LiquidFiltersSpecHelper.render_template(example['input'], context)
            expected = example['output'].to_s

            expect(LiquidFiltersSpecHelper).to be_outputs_match(actual, expected),
                                               "Expected: #{expected.inspect}\nActual: #{actual.inspect}"
          end
        end
      end
    end
  end
end
