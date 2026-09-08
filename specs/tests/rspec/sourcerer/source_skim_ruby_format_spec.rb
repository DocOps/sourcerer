# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe Sourcerer::SourceSkim, 'Ruby format' do # rubocop:disable RSpec/DescribeMethod, RSpec/SpecFilePathFormat
  let(:fixtures_dir) { File.expand_path('../../fixtures', __dir__) }
  let(:rb_fixture)   { File.join(fixtures_dir, 'source_skim_sample.rb') }

  # fixture: module Sample, module Sample::Greeter (method .greet),
  # class Sample::Widget (methods #initialize, #label)

  describe '.skim_file (auto-detected from .rb extension)' do
    subject(:result) { described_class.skim_file(rb_fixture) }

    it 'returns a Hash with classes, modules, and methods keys' do
      expect(result).to include(:classes, :modules, :methods)
    end

    it 'lists classes with name and line, but no desc by default' do
      expect(result[:classes]).to contain_exactly(
        { name: 'Sample::Widget', line: 16 })
    end

    it 'lists modules with name and line' do
      expect(result[:modules]).to contain_exactly(
        { name: 'Sample', line: 3 },
        { name: 'Sample::Greeter', line: 5 })
    end

    it 'lists methods with fully-qualified names and line numbers' do
      expect(result[:methods]).to contain_exactly(
        { name: 'Sample::Greeter.greet', line: 10 },
        { name: 'Sample::Widget#initialize', line: 18 },
        { name: 'Sample::Widget#label', line: 23 })
    end
  end

  describe '.skim_file with descriptions: true' do
    subject(:result) { described_class.skim_file(rb_fixture, descriptions: true) }

    it 'includes docstrings on classes' do
      widget = result[:classes].find { |c| c[:name] == 'Sample::Widget' }
      expect(widget[:desc]).to eq('A sample class used to validate RubySkimmer output.')
    end

    it 'includes docstrings on modules' do
      greeter = result[:modules].find { |m| m[:name] == 'Sample::Greeter' }
      expect(greeter[:desc]).to eq('A sample module used to validate RubySkimmer output.')
    end

    it 'includes docstrings on methods' do
      greet = result[:methods].find { |m| m[:name] == 'Sample::Greeter.greet' }
      expect(greet[:desc]).to eq('Builds a greeting string.')
    end

    it 'includes an empty string when no docstring is present' do
      sample_module = result[:modules].find { |m| m[:name] == 'Sample' }
      expect(sample_module[:desc]).to eq('')
    end
  end

  describe '.skim_string with format: :ruby' do
    subject(:result) { described_class.skim_string(File.read(rb_fixture), format: :ruby) }

    it 'produces the same skim as .skim_file' do
      expect(result).to eq(described_class.skim_file(rb_fixture))
    end
  end
end
