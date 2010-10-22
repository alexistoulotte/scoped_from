module ScopedFrom
  
  class Query
    
    TRUE_VALUES = %w( true yes y on 1 ).freeze
    
    attr_reader :params
    
    # Available options are: - :only : to restrict to specified keys.
    #                        - :except : to ignore specified keys.
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
      scope
    end
    
    protected
    
    def scoped(scope, name, value)
      arity = scope.scope_arity(name)
      if arity == 1
        scope.send(name, value)
      elsif arity == -1 && true?(value)
        scope.send(name)
      else
        scope
      end
    end
    
    def params=(params)
      params = params.params if params.is_a?(self.class)
      params = CGI.parse(params.to_s) unless params.is_a?(Hash)
      @params = ActiveSupport::HashWithIndifferentAccess.new
      params.each do |name, value|
        if value.is_a?(Array)
          value = value.flatten
          value.delete_if(&:blank?)
          value = value.first unless value.many?
        end
        @params[name] = value if value.present?
      end
      @params.slice!(*[@options[:only]].flatten) if @options[:only].present?
      @params.except!(*[@options[:except]].flatten) if @options[:except].present?
    end
    
    def true?(value)
      TRUE_VALUES.include?(value.to_s.strip.downcase)
    end
    
  end
  
end