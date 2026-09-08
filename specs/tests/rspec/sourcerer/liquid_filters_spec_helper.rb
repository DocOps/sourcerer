# frozen_string_literal: true

require 'liquid'
require 'jekyll'
require_relative '../spec_helper'

module LiquidFiltersSpecHelper
  # A real Jekyll::Site, built once per process, to satisfy the `site` register
  # that Jekyll's and jekyll-asciidoc's built-in Liquid filters expect at
  # `@context.registers[:site]` (`where`, `sort`, `relative_url`,
  # `absolute_url`, `asciidocify`, etc. all reach into it for config, a
  # filter-result cache, or a converter instance).
  def self.test_site
    @test_site ||= begin
      Jekyll.logger.log_level = :error
      Jekyll::Site.new(Jekyll.configuration('url' => 'https://example.com', 'baseurl' => '/docs'))
    end
  end

  # Load filter definitions from YAML using Sourcerer's canonical YAML loader
  # @return [Array<Hash>] parsed YAML filters with example_data
  def self.load_filters_yaml
    yaml_path = File.join(__dir__, '../../../data/liquid-filters.yml')
    Sourcerer::Yaml.load_with_tags(yaml_path)
  end

  # Get all filters or filter by source
  # @param source [String, nil] optional source to filter by (e.g., 'AsciiSourcerer', 'Jekyll')
  # @return [Array<Hash>] array of filter definitions
  def self.filters source: nil
    data = load_filters_yaml
    filters = data['filters'] || []
    source ? filters.select { |f| f['source'] == source } : filters
  end

  # Get testable examples for a filter (excluding those with test: false)
  # @param filter [Hash] filter definition
  # @return [Array<Hash>] array of testable examples
  def self.testable_examples filter
    examples = filter['examples'] || []
    examples.reject { |ex| ex['test'] == false }
  end

  # Initialize Liquid context with example data
  # @return [Hash] context hash ready for template rendering
  def self.example_context
    data = load_filters_yaml
    example_data = data['example_data'] || {}
    example_data.transform_keys(&:to_s)
  end

  # Render a Liquid template with filter context
  # @param template_str [String] Liquid template to render
  # @param context [Hash] template context (merged with example_data)
  # @return [String] rendered output
  def self.render_template template_str, context = {}
    full_context = example_context.merge(context.transform_keys(&:to_s))

    template = Liquid::Template.parse(template_str)
    template.render(full_context, registers: { site: test_site })
  end

  # Normalize whitespace for comparison
  # Handles multi-line outputs by normalizing trailing spaces and leading indent
  # @param str [String] string to normalize
  # @return [String] normalized string
  def self.normalize_output str
    str.to_s
       .strip # Remove leading/trailing whitespace
       .gsub(/\s+\n/, "\n")           # Remove trailing spaces on lines
       .gsub(/\n\s+/, "\n")           # Remove leading spaces on continuation lines
  end

  # Compare actual vs expected output
  # @param actual [String] actual rendered output
  # @param expected [String] expected output from YAML
  # @param strict [Boolean] if true, use strict comparison; if false, normalize first
  # @return [Boolean] true if outputs match
  def self.outputs_match? actual, expected, strict: false
    if strict
      actual == expected
    else
      normalize_output(actual) == normalize_output(expected)
    end
  end
end
