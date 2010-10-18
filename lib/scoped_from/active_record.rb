module ScopedFrom

  module ActiveRecord

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      
      def scope(name, scope_options, &block)
        super
        scope_arities[name] = scope_options.is_a?(Proc) ? scope_options.arity : -1
      end
      
      def scope_arity(name)
        scope_arities[name]
      end
      
      def scoped_from(params, options = {})
        scope = scoped
        (params || {}).each do |name, value|
          scope = scope.send(name, value) if scopes.key?(name.to_sym)
        end
        scope
      end
      
      private
      
      def scope_arities
        read_inheritable_attribute(:scope_arities) || write_inheritable_attribute(:scope_arities, {}.with_indifferent_access)
      end

    end
    
  end
  
end