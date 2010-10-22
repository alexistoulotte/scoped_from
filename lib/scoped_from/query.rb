module ScopedFrom
  
  class Query
    
    attr_reader :params
    
    # Available options are: - :only : to restrict to specified keys.
    #                        - :except : to ignore specified keys.
    def initialize(scope, params, options = {})
      @options = options
      self.params = params
    end
    
    private
    
    def params=(params)
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
    
  end
  
end