require 'active_record'

lib_path = File.expand_path(File.dirname(__FILE__) + '/scoped_from')

require "#{lib_path}/active_record"

ActiveRecord::Base.send(:include, ScopedFrom::ActiveRecord)