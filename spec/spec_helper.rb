# frozen_string_literal: true

if %w[yes true 1].include?(ENV['COVERAGE'])
  require 'simplecov'
  require 'simplecov-console'
  require 'simplecov_json_formatter'

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
    [
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::JSONFormatter,
      SimpleCov::Formatter::Console
    ]
  )

  SimpleCov.start 'test_frameworks' do
    enable_coverage :branch
  end
end

require 'webmock/rspec'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr'
  config.hook_into :webmock
  config.default_cassette_options = { match_requests_on: %i[uri method] }
end

RSpec.configure do |config|
  config.color = true

  config.expect_with :rspec do |expectations|
    expectations.max_formatted_output_length = 1_000_000
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
