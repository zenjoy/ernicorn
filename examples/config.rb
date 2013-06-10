# Ernicorn configuration
#
# Ernicorn config files typically live at config/ernicorn.rb and support all
# Unicorn config options:
#
#    http://unicorn.bogomips.org/Unicorn/Configurator.html
#
# Example unicorn config files:
#
#   http://unicorn.bogomips.org/examples/unicorn.conf.rb
#   http://unicorn.bogomips.org/examples/unicorn.conf.minimal.rb
warn "Running unicorn config file: #{__FILE__}"

port = 9777
# server options
listen port
worker_processes 2
working_directory File.dirname(__FILE__)
pid "/tmp/ernicorn-#{port}.pid"

# ernicorn configuration
Ernicorn.loglevel 1

# enable COW where possible
GC.respond_to?(:copy_on_write_friendly=) &&
  GC.copy_on_write_friendly = true

# load server code and expose modules
require File.expand_path('../handler', __FILE__)
Ernicorn.expose(:example, Example)

# hook into new child immediately after forking
after_fork  do |server, worker|
end

# hook into master immediately before forking a worker
before_fork do |server, worker|
  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end