module Llm
  class ContentCommentaryService < BaseService
    def initialize(api_key = nil)
      @api_key = api_key || default_api_key
      Rails.logger.info "🔍 ContentCommentaryService API Key: #{api_key.inspect}"
      super(@api_key)  # Explicitly pass it to BaseService
      @base_url = "https://api.openai.com/v1/chat/completions"
      @headers = {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{@api_key}" # Ensure header includes the API key
      }
    end

    def generate_commentary(content)
      return "Content is too short for grammar checking." if content.to_s.strip.length < 20

      body = {
        model: "gpt-3.5-turbo",
        messages: [
          {
            role: "system",
            content: "You are a precise grammar and writing assistant. Your task is to identify grammatical errors, spelling mistakes, and awkward phrasing in the text. Format your response as a bulleted list of specific issues, with clear suggestions for improvement. Focus only on actual errors, not stylistic preferences. If there are no errors, simply state that the text is grammatically correct."
          },
          {
            role: "user",
            content: "Please check this blog content for grammatical errors and provide specific corrections: #{content}"
          }
        ],
        max_tokens: 250,
        temperature: 0.3
      }

      begin
        response = HTTParty.post(
          @base_url,
          headers: @headers,
          body: body.to_json,
          timeout: 30
        )

        extract_commentary(response)
      rescue HTTParty::Error => e
        handle_http_error(e)
      end
    end

    # Streaming version of generate_commentary
    def generate_commentary_stream(content, &block)
      return "Content is too short for grammar checking." if content.to_s.strip.length < 20

      body = {
        model: "gpt-3.5-turbo",
        messages: [
          {
            role: "system",
            content: "You are a precise grammar and writing assistant. Your task is to identify grammatical errors, spelling mistakes, and awkward phrasing in the text. Format your response as a bulleted list of specific issues, with clear suggestions for improvement. Focus only on actual errors, not stylistic preferences. If there are no errors, simply state that the text is grammatically correct."
          },
          {
            role: "user",
            content: "Please check this blog content for grammatical errors and provide specific corrections: #{content}"
          }
        ],
        max_tokens: 250,
        temperature: 0.3,
        stream: true
      }

      begin
        uri = URI(@base_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Post.new(uri.path, @headers)
        request.body = body.to_json

        response_text = ""

        http.request(request) do |response|
          response.read_body do |chunk|
            # Each chunk may contain multiple SSE events
            chunk.scan(/data: (.+?)(?:\n\n|$)/m).each do |data|
              next if data[0] == "[DONE]"

              begin
                parsed = JSON.parse(data[0])
                content = parsed.dig("choices", 0, "delta", "content")

                if content
                  response_text += content
                  yield response_text if block_given?
                end
              rescue JSON::ParserError => e
                Rails.logger.error "Error parsing streaming response: #{e.message}"
              end
            end
          end
        end

        response_text
      rescue => e
        Rails.logger.error "Streaming error: #{e.message}"
        raise ServiceError, "Streaming error: #{e.message}"
      end
    end

    private

    def default_api_key
      ENV["OPENAI_API_KEY"]
    end

    def extract_commentary(response)
      parsed = JSON.parse(response.body)
      commentary = parsed.dig("choices", 0, "message", "content")

      if commentary.present?
        commentary
      else
        Rails.logger.error "No commentary in response: #{response.body}"
        "Unable to generate commentary at this time."
      end
    rescue JSON::ParserError => e
      Rails.logger.error "Invalid JSON response: #{e.message}"
      "Error generating commentary."
    end
  end
end
