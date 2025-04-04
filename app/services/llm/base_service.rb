module Llm
    class BaseService
      class ServiceError < StandardError; end

      def initialize(api_key = nil)
        @api_key = api_key || default_api_key
        Rails.logger.info "🔍 BaseService API KEY: #{@api_key.inspect}"
        @headers = default_headers

        raise ArgumentError, "API key is not configured" if @api_key.blank?
      end

      def generate_summary(input_text, max_length = 300)
        raise NotImplementedError, "#{self.class} must implement #generate_summary"
      end

      def generate_tags(text)
        raise NotImplementedError, "#{self.class} must implement #generate_tags"
      end

      private

      def default_api_key
        raise NotImplementedError, "#{self.class} must implement #default_api_key"
      end

      def default_headers
        { "Content-Type" => "application/json" }
      end

      def handle_api_response(response)
        case response.code
        when 200
          extract_summary(response.body)
        when 401, 403
          Rails.logger.error "Authentication failed: #{response.body}"
          raise ServiceError, "API authentication failed"
        when 429
          Rails.logger.error "Rate limit exceeded: #{response.body}"
          raise ServiceError, "API rate limit exceeded"
        else
          Rails.logger.error "API error: #{response.code} - #{response.body}"
          raise ServiceError, "API error (#{response.code})"
        end
      end

      def extract_summary(response_body)
        raise NotImplementedError, "#{self.class} must implement #extract_summary"
      end
    end
end
