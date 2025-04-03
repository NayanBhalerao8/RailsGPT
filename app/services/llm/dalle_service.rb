require 'httparty'
module Llm
    class DalleService < BaseService
  
      def initialize(api_key = nil)
        @api_key = api_key || default_api_key
        Rails.logger.info "🔍 DalleService API Key: #{api_key.inspect}"
        super(@api_key)  # Explicitly pass it to BaseService
        @base_url = "https://api.openai.com/v1/images/generations"
        @headers = {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{@api_key}" # Ensure header includes the API key
        }
      end
  
      def generate_image(prompt, size = "1024x1024")
        body = {
          model: "dall-e-2",  # Use DALL·E 2 for the cheapest option
          prompt: prompt,
          n: 1,
          size: size
        }
  
        begin
          response = HTTParty.post(
            @base_url,
            headers: @headers,  # Use the correctly set headers
            body: body.to_json,
            timeout: 60
          )
  
          extract_image_url(response)
        rescue HTTParty::Error => e
          handle_http_error(e)
        end
      end
  
      private
  
      def default_api_key
        ENV['OPENAI_API_KEY']
      end
  
      def extract_image_url(response)
        parsed = JSON.parse(response.body)
        image_url = parsed.dig("data", 0, "url")
  
        if image_url.present?
          image_url
        else
          Rails.logger.error "No image URL in response: #{response.body}"
          raise ServiceError, "Failed to generate image"
        end
      rescue JSON::ParserError => e
        Rails.logger.error "Invalid JSON response: #{e.message}"
        raise ServiceError, "Invalid API response format"
      end
    end
  end
  