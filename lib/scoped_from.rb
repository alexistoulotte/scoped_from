require 'rubygems'
require 'bundler/setup'
require 'cgi'
require 'active_record'
require 'active_support/core_ext/object/to_query'

lib_path = File.expand_path(File.dirname(__FILE__) + '/scoped_from')

require "#{lib_path}/active_record"
require "#{lib_path}/query"

ActiveRecord::Base.send(:include, ScopedFrom::ActiveRecord)