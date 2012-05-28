$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '../../lib'))

require 'kookaburra/test_helpers'
require 'todo_case_app/test_support'
require 'find_a_port'

APP_PORT = FindAPort.available_port

# Start up the Rack server for testing in a forked process
rack_server_pid = fork do
  #ENV['RAILS_ENV'] = 'test'
  require 'capybara'
  require 'thwait'
  require File.join(File.dirname(__FILE__), '../../config/environment')
  api_user = User.new('kookaburra', 'cucumbersFTW!')
  RegisteredUsers.instance << api_user
  Capybara.server_port = APP_PORT
  Capybara::Server.new(TodoCaseApp::Application).boot
  ThreadsWait.all_waits(Thread.list)
end
sleep 2 # Make sure Rails has plenty of time to start up the server

at_exit do
  # Shut down the Rack server
  Process.kill(9, rack_server_pid)
  Process.wait
end

Kookaburra.configure do |c|
  c.given_driver_class = TodoCaseApp::TestSupport::GivenDriver
  c.ui_driver_class = TodoCaseApp::TestSupport::UIDriver
  c.app_host = 'http://localhost:%d' % APP_PORT
end

World(Kookaburra::TestHelpers)
