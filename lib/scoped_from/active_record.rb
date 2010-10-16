module ScopedFrom

  module ActiveRecord

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def scoped_from(params, options = {})
        scope = scoped
        (params || {}).each do |name, value|
          scope = scope.send(name, value) if scopes.key?(name.to_sym)
        end
        scope
      end

    end
    
  end
  
end