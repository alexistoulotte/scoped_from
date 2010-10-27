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
        query_class = "#{name}Query".constantize rescue nil
        query_class = Query unless query_class.is_a?(Class) && query_class.ancestors.include?(Query)
        query_class.new(self, params, options).scope
      end
      
      private
      
      def scope_arities
        read_inheritable_attribute(:scope_arities) || write_inheritable_attribute(:scope_arities, ActiveSupport::HashWithIndifferentAccess.new)
      end

    end
    
  end
  
end