module ScopedFrom
  
  class Query
    
    attr_reader :params
    
    def initialize(scope, params, options = {})
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
    end
    
  end
  
end