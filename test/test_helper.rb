require 'simplecov'
require 'coveralls'

SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start do
  add_filter 'test/'
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'cayan'

require 'minitest/autorun'
require 'webmock/minitest'
require 'pry'