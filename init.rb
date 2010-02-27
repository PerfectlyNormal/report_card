begin
  # Try to require the preresolved locked set of gems.
  puts "Requiring #{File.expand_path('.bundle/environment')}"
  require File.expand_path('.bundle/environment')
rescue LoadError
  # Fall back on doing an unlocked resolve at runtime.
  require "rubygems"
  require "bundler"
  Bundler.setup
end

Bundler.require