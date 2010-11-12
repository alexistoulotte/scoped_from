module ScopedFrom
  
  class Query
    
    TRUE_VALUES = %w( true yes y on 1 ).freeze
    
    attr_reader :params
    
    # Available options are: - :only : to restrict to specified keys.
    #                        - :except : to ignore specified keys.
    #                        - :include_blank : to include blank values
    #                                           (default false).
    def initialize(scope, params, options = {})
      @scope = scope.scoped
      @options = options
      self.params = params
    end
    
    def scope
      scope = @scope
      params.each do |name, value|
        [value].flatten.each do |value|
          scope = scoped(scope, name, value)
        end
      end
      decorate_scope(scope)
    end
    
    protected
    
    def decorate_scope(scope)
      return scope if scope.respond_to?(:query)
      def scope.query
        @__query
      end
      scope.instance_variable_set('@__query', self)
      scope
    end
    
    def scoped(scope, name, value)
      if scope.scope_with_one_argument?(name)
        scope.send(name, value)
      elsif scope.scope_without_argument?(name)
        scope.send(name)
      elsif @options[:include_columns].present? && scope.column_names.include?(name.to_s)
        scope.scoped(:conditions => { name => value })
      else
        scope
      end
    end
    
    def params=(params)
      params = params.params if params.is_a?(self.class)
      params = CGI.parse(params.to_s) unless params.is_a?(Hash)
      @params = ActiveSupport::HashWithIndifferentAccess.new
      params.each do |name, value|
        value = [value].flatten
        value.delete_if(&:blank?) unless @options[:include_blank]
        next if value.empty?
        if @scope.scope_without_argument?(name)
          @params[name] = true if value.any? { |v| true?(v) }
        elsif @scope.scope_with_one_argument?(name) || @options[:include_columns].present? && @scope.column_names.include?(name.to_s)
          @params[name] = value.many? ? value : value.first
        end
      end
      @params.slice!(*[@options[:only]].flatten) if @options[:only].present?
      @params.except!(*[@options[:except]].flatten) if @options[:except].present?
    end
    
    def true?(value)
      TRUE_VALUES.include?(value.to_s.strip.downcase)
    end
    
  end
  
end