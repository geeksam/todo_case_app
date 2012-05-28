require 'rspec/autorun'

$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), '../app')))

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__), 'support/**/*.rb'))].each do |f|
  require f
end
