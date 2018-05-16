$: << File.join(File.dirname(__FILE__),"..", "lib")

require 'pry'
require 'alephant/lookup'
require 'crimp'
require 'logger'

ENV['AWS_REGION'] = 'eu-west-1'
