module Llm
  class ContentSummarizerService < BaseService
    def initialize(api_key = nil)
      @api_key = api_key || default_api_key
      super(@api_key)
      @base_url = "https://api.openai.com/v1/chat/completions"
      @headers = {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{@api_key}"
      }
    end

    def summarize(content, max_length = 400)
      prompt = "Summarize the following content in a creative and engaging way, suitable for an image generation prompt. Keep it under #{max_length} characters:\n\n#{content}"

      body = {
        model: "gpt-4o-mini",
        messages: [
          {
            role: "user",
            content: prompt
          }
        ],
        max_tokens: 300
      }

      begin
        response = HTTParty.post(
          @base_url,
          headers: @headers,
          body: body.to_json,
          timeout: 30
        )

        extract_summary(response)
      rescue HTTParty::Error => e
        handle_http_error(e)
      end
    end

    private

    def default_api_key
      ENV["OPENAI_API_KEY"]
    end

    def extract_summary(response)
      parsed = JSON.parse(response.body)
      summary = parsed.dig("choices", 0, "message", "content")

      if summary.present?
        summary.strip
      else
        Rails.logger.error "No summary in response: #{response.body}"
        raise ServiceError, "Failed to generate summary"
      end
    rescue JSON::ParserError => e
      Rails.logger.error "Invalid JSON response: #{e.message}"
      raise ServiceError, "Invalid API response format"
    end
  end
end
