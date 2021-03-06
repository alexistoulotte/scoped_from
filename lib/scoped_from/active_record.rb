module ScopedFrom

  module ActiveRecord

    extend ActiveSupport::Concern

    included do |base|
      base.class_attribute(:scope_arities)
      base.scope_arities = ActiveSupport::HashWithIndifferentAccess.new
    end

    class_methods do

      def scope(name, scope_options, &block)
        super
        scope_arities[name] = scope_options.is_a?(Proc) ? scope_options.arity : -1
      end

      def scope_with_one_argument?(name)
        scope_arities[name] == 1
      end

      def scope_without_argument?(name)
        scope_arities[name] == 0
      end

      def scoped_from(params, options = {})
        query_class = "#{name}Query".safe_constantize
        query_class = Query unless query_class.is_a?(Class) && query_class.ancestors.include?(Query)
        query_class.new(self, params, options).relation
      end

    end

  end

end
