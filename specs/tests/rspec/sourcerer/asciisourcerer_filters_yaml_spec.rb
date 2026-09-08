# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'liquid_filters_spec_helper'

RSpec.describe 'AsciiSourcerer Liquid Filters' do
  let(:filter_host) do
    Class.new do
      include Liquid::StandardFilters
      include Sourcerer::Jekyll::Liquid::Filters
    end.new
  end

  let(:filters_data) { LiquidFiltersSpecHelper.load_filters_yaml }
  let(:asciisourcerer_filters) do
    LiquidFiltersSpecHelper.filters(source: 'asciisourcerer')
  end

  before do
    # Ensure filter context is available
    Sourcerer::Jekyll.initialize_liquid_runtime
  end

  describe 'Filter inventory' do
    it 'includes at least some AsciiSourcerer filters' do
      expect(asciisourcerer_filters.size).to be_positive
    end

    it 'each filter has a key and name' do
      asciisourcerer_filters.each do |filter|
        expect(filter).to have_key('key')
        expect(filter).to have_key('name')
        expect(filter['key']).not_to be_empty
        expect(filter['name']).not_to be_empty
      end
    end
  end

  describe 'Testable examples' do
    asciisourcerer_filters = LiquidFiltersSpecHelper.filters(source: 'asciisourcerer')

    asciisourcerer_filters.each do |filter|
      testable_examples = LiquidFiltersSpecHelper.testable_examples(filter)

      next if testable_examples.empty?

      describe "#{filter['name']} (#{filter['key']})" do
        testable_examples.each_with_index do |example, idx|
          it "example #{idx + 1}: #{example['input'].split("\n").first}" do
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
