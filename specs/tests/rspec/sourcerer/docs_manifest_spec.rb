# frozen_string_literal: true

require_relative '../spec_helper'
require 'tmpdir'
require 'asciidoctor'

RSpec.describe 'specs/data/docs-manifest.yml', 'generated docs' do # rubocop:disable RSpec/DescribeMethod
  let(:root) { File.expand_path('../../../..', __dir__) }
  let(:manifest_path) { File.join(root, 'specs/data/docs-manifest.yml') }
  let(:manifest) { Sourcerer::Yaml.load_with_tags(manifest_path) }

  it 'has at least one entry' do
    expect(manifest['docs']).not_to be_empty
  end

  it 'every entry names an existing template and data file' do
    manifest['docs'].each do |entry|
      expect(File).to exist(File.join(root, entry['template'])), "missing template for #{entry['name']}"
      expect(File).to exist(File.join(root, entry['data'])), "missing data file for #{entry['name']}"
    end
  end

  describe 'rendering every manifest entry' do
    manifest_for_examples = Sourcerer::Yaml.load_with_tags(
      File.expand_path('../../../data/docs-manifest.yml', __dir__))

    manifest_for_examples['docs'].each do |entry|
      describe entry['name'] do
        it 'renders to valid AsciiDoc with no warnings' do
          root = File.expand_path('../../../..', __dir__)
          Dir.mktmpdir do |tmpdir|
            out_file = File.join(tmpdir, "#{entry['name']}.adoc")

            Sourcerer::Rendering.render_template(
              File.join(root, entry['template']),
              File.join(root, entry['data']),
              out_file,
              vars: entry['vars'] || {})

            logger = Asciidoctor::MemoryLogger.new
            Asciidoctor.load_file(out_file, safe: :safe, logger: logger)

            expect(logger.messages).to be_empty
          end
        end
      end
    end
  end
end
