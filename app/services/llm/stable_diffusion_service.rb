module Llm
    class StableDiffusionService < BaseService
      def initialize(api_key = nil)
        super(api_key)
        @base_url = "https://api.stability.ai/v2beta/stable-image/generate/sd3"
      end

      def generate_image(prompt, width = 1024, height = 1024)
        body = {
          prompt: prompt,
          width: width,
          height: height,
          samples: 1
        }

        begin
          response = HTTParty.post(
            @base_url,
            headers: @headers.merge("Authorization" => "Bearer #{@api_key}"),
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
        ENV["STABILITY_AI_KEY"]
      end

      def extract_image_url(response)
        parsed = JSON.parse(response.body)
        image_url = parsed.dig("artifacts", 0, "url")

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
