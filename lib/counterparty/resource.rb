module Counterparty
  # A base class for the purpose of extending by api result hashes
  class CounterResource
    attr_accessor :result_attributes

    def initialize(attrs={})
      @result_attributes = attrs.keys.sort.collect(&:to_sym)
      attrs.each{|k,v| instance_variable_set '@%s' % k, v}
    end

    def ==(b)
      ( b.respond_to?(:result_attributes) &&
        result_attributes == b.result_attributes && 
        @result_attributes.all?{ |k| send(k) == b.send(k) } )
    end

    def save!
      puts to_params.inspect
      ret = connection.request to_create_request, to_params
      puts "Ret:"+ret.inspect
      ret
    end

    private

    def connection
      self.class.connection
    end

    def to_params
      Hash[* @result_attributes.collect{|k| 
        v = self.send(k)
        (v) ? [k,self.send(k)] : nil
      }.compact.flatten]
    end

    def to_create_request
      'create_%s' % self.class.api_name
    end

    class << self
      attr_writer :connection

      def api_name
        to_s.split('::').last.gsub(/[^\A]([A-Z])/, '_\\1').downcase
      end

      def connection
        @connection || Counterparty.connection
      end

      def to_get_request
        'get_%ss' % api_name
      end

      def find(params)
        connection.request(to_get_request, params).collect{|r| new r}
      end
    end
  end
end

