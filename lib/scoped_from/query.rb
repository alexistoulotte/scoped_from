module ScopedFrom
  
  class Query

    ORDER_DIRECTIONS = %w( asc desc ).freeze
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
    
    def order_column
      parse_order(params['order'])[:column]
    end
    
    def order_direction
      parse_order(params['order'])[:direction]
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
    
    def order_to_sql(value)
      order = parse_order(value)
      "#{order[:column]} #{order[:direction].upcase}" if order.present?
    end
    
    def scoped(scope, name, value)
      if name.to_s == 'order'
        scope.order(order_to_sql(value))
      elsif scope.scope_with_one_argument?(name)
        scope.send(name, value)
      elsif scope.scope_without_argument?(name)
        scope.send(name)
      elsif scope.column_names.include?(name.to_s)
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
        values = [value].flatten
        values.delete_if(&:blank?) unless @options[:include_blank]
        next if values.empty?
        if name.to_s == 'order'
          order = parse_order(values.last)
          @params[name] = "#{order[:column]}.#{order[:direction]}" if order.present?
        elsif @scope.scope_without_argument?(name)
          @params[name] = true if values.any? { |value| true?(value) }
        elsif @scope.scope_with_one_argument?(name) || @options[:include_columns].present? && @scope.column_names.include?(name.to_s)
          value = values.many? ? values : values.first
          @params[name] = @params[name] ? [@params[name], value].flatten : value
        end
      end
      @params.slice!(*[@options[:only]].flatten) if @options[:only].present?
      @params.except!(*[@options[:except]].flatten) if @options[:except].present?
    end
    
    def parse_order(value)
      column, direction = value.to_s.split(/[\.:\s]+/, 2)
      direction = direction.to_s.downcase
      direction = ORDER_DIRECTIONS.first unless ORDER_DIRECTIONS.include?(direction)
      @scope.column_names.include?(column) ? { :column => column, :direction => direction } : {}
    end
    
    def true?(value)
      TRUE_VALUES.include?(value.to_s.strip.downcase)
    end
    
  end
  
end