$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'clean_tape'

begin
  require 'pry'
rescue LoadError
end
