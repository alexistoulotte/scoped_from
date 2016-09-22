module ScopedFrom

  class Query

    FALSE_VALUES = %w(false no n off 0).freeze
    ORDER_DIRECTIONS = %w(asc desc).freeze
    TRUE_VALUES = %w(true yes y on 1).freeze

    attr_reader :params

    # Available options are: - :only : to restrict to specified keys.
    #                        - :except : to ignore specified keys.
    def initialize(relation, params, options = {})
      self.relation = relation
      self.options = options
      self.params = params
    end

    def order_column
      parse_order(params['order'])[:column]
    end

    def order_direction
      parse_order(params['order'])[:direction]
    end

    def relation
      relation = @relation
      params.each do |name, value|
        [value].flatten.each do |value|
          relation = invoke_param(relation, name, value)
        end
      end
      decorate_relation(relation)
    end

    protected

    def decorate_relation(relation)
      return relation if relation.respond_to?(:query)
      def relation.query
        @__query
      end
      relation.instance_variable_set('@__query', self)
      relation
    end

    def invoke_param(relation, name, value)
      if name.to_s == 'order'
        relation.order(order_to_hash(value))
      elsif relation.scope_with_one_argument?(name)
        relation.send(name, value)
      elsif relation.scope_without_argument?(name)
        relation.send(name)
      elsif relation.column_names.include?(name.to_s)
        relation.where(name => value)
      else
        relation
      end
    end

    def false?(value)
      FALSE_VALUES.include?(value.to_s.strip.downcase)
    end

    def options=(options)
      @options = options.symbolize_keys
    end

    def order_to_hash(value)
      order = parse_order(value)
      order.present? ? { order[:column] => order[:direction].downcase.to_sym } : {}
    end

    def params=(params)
      params = params.params if params.is_a?(self.class)
      params = CGI.parse(params.to_s) unless params.is_a?(Hash) || defined?(ActionController::Parameters) && params.is_a?(ActionController::Parameters)
      @params = ActiveSupport::HashWithIndifferentAccess.new
      params.each do |name, value|
        values = [value].flatten
        next if values.empty?
        if name.to_s == 'order'
          orders = parse_orders(values).map { |order| "#{order[:column]}.#{order[:direction]}" }
          @params[name] = (orders.many? ? orders : orders.first) if orders.any?
        elsif @relation.scope_without_argument?(name)
          @params[name] = true if values.all? { |value| true?(value) }
        elsif @relation.scope_with_one_argument?(name)
          value = values.many? ? values : values.first
          @params[name] = @params[name] ? [@params[name], value].flatten : value
        elsif @options[:exclude_columns].blank? && @relation.column_names.include?(name.to_s)
          if @relation.columns_hash[name.to_s].type == :boolean
            @params[name] = true if values.all? { |value| true?(value) }
            @params[name] = false if values.all? { |value| false?(value) }
          else
            value = values.many? ? values : values.first
            @params[name] = @params[name] ? [@params[name], value].flatten : value
          end
        end
      end
      @params.slice!(*[@options[:only]].flatten) if @options[:only].present?
      @params.except!(*[@options[:except]].flatten) if @options[:except].present?
    end

    def parse_order(value)
      column, direction = value.to_s.split(/[\.:\s]+/, 2)
      direction = direction.to_s.downcase
      direction = ORDER_DIRECTIONS.first unless ORDER_DIRECTIONS.include?(direction)
      @relation.column_names.include?(column) ? { column: column, direction: direction } : {}
    end

    def parse_orders(values)
      [].tap do |orders|
        values.each do |value|
          order = parse_order(value)
          orders << order if order.present? && !orders.any? { |o| o[:column] == order[:column] }
        end
      end
    end

    def relation=(relation)
      @relation = relation.is_a?(Class) ? relation.all : relation
    end

    def true?(value)
      TRUE_VALUES.include?(value.to_s.strip.downcase)
    end

  end

end
