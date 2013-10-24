require 'rubygems'
require 'bundler/setup'
require 'cgi'
require 'active_record'
require 'active_support/concern'
require 'active_support/core_ext/object/to_query'

module ScopedFrom

  def self.version
    @@version ||= File.read(File.expand_path("#{__dir__}/../VERSION")).strip.freeze
  end

end

lib_path = "#{__dir__}/scoped_from"

require "#{lib_path}/active_record"
require "#{lib_path}/query"

ActiveRecord::Base.send(:include, ScopedFrom::ActiveRecord)
