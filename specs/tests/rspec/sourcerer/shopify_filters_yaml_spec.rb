# frozen_string_literal: true

require_relative '../spec_helper'
require_relative 'liquid_filters_spec_helper'

RSpec.describe 'Shopify Liquid Filters' do
  let(:filters_data) { LiquidFiltersSpecHelper.load_filters_yaml }
  let(:shopify_filters) { LiquidFiltersSpecHelper.filters(source: 'shopify') }

  before do
    # Ensure Liquid runtime is initialized with Jekyll/Sourcerer filters
    Sourcerer::Jekyll.initialize_liquid_runtime
  end

  describe 'Filter inventory' do
    it 'includes Shopify filters' do
      expect(shopify_filters.size).to be_positive
    end

    it 'each filter has required fields' do
      shopify_filters.each do |filter|
        expect(filter).to have_key('key')
        expect(filter).to have_key('name')
        expect(filter).to have_key('source')
      end
    end
  end

  describe 'Testable examples' do
    shopify_filters = LiquidFiltersSpecHelper.filters(source: 'shopify')

    shopify_filters.each do |filter|
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
