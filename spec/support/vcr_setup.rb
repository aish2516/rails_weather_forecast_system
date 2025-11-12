require 'vcr'
require 'webmock/rspec'

VCR.configure do |config|
	config.cassette_library_dir = "spec/vcr"     #Folder to store cassettes
	config.hook_into :webmock           # Use WebMoc for HTTP requests
	config.configure_rspec_metadata!    # Allows automatic tagging  in RSpec
	config.allow_http_connections_when_no_cassette = false          # Blocks external API calls if no cassette exists   
end