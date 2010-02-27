$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))

begin
  # Try to require the preresolved locked set of gems.
  require File.expand_path('.bundle/environment')
rescue LoadError
  # Fall back on doing an unlocked resolve at runtime.
  require "rubygems"
  require "bundler"
  Bundler.setup
end

Bundler.require