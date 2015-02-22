#!/usr/bin/env ruby

require 'pathname'

# ENV['BUNDLE_GEMFILE'] = Pathname(__FILE__).dirname.join('Gemfile').to_s
# require 'bundler/setup'

$LOAD_PATH.push Pathname(__FILE__).dirname.parent.join('lib')
require 'cassette'
require 'cli'
require 'cutter'
require 'recording'
require 'session'

Cli.new.run
