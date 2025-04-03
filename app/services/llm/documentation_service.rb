module Llm
  class DocumentationService < BaseService
    def initialize(api_key = nil)
      @api_key = api_key || default_api_key
      super(@api_key)
      @base_url = "https://api.openai.com/v1/chat/completions"
      @headers = {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{@api_key}"
      }
    end

    def generate_model_documentation(model_class)
      code = read_model_code(model_class)
      prompt = <<~PROMPT
        Analyze this Rails model code and generate comprehensive documentation in Markdown format.
        Include:
        1. Model description
        2. Associations
        3. Validations
        4. Callbacks
        5. Important methods
        6. Usage examples
        
        Code to analyze:
        #{code}
      PROMPT

      generate_documentation(prompt)
    end

    def generate_controller_documentation(controller_class)
      code = read_controller_code(controller_class)
      prompt = <<~PROMPT
        Analyze this Rails controller code and generate comprehensive documentation in Markdown format.
        Include:
        1. Controller description
        2. Available actions
        3. Parameters for each action
        4. Response formats
        5. Authentication/Authorization requirements
        6. Usage examples
        
        Code to analyze:
        #{code}
      PROMPT

      generate_documentation(prompt)
    end

    def generate_api_documentation(controller_class)
      code = read_controller_code(controller_class)
      prompt = <<~PROMPT
        Analyze this Rails controller code and generate OpenAPI (Swagger) documentation in YAML format.
        Include:
        1. Paths for all endpoints
        2. HTTP methods
        3. Request parameters
        4. Response schemas
        5. Authentication requirements
        6. Example requests and responses
        
        Code to analyze:
        #{code}
      PROMPT

      generate_documentation(prompt)
    end

    def add_code_comments(code, language = 'ruby')
      prompt = <<~PROMPT
        Add clear and meaningful comments to this #{language} code.
        Follow these guidelines:
        1. Add method documentation using standard documentation format
        2. Explain complex logic
        3. Document important variables
        4. Keep comments concise and professional
        
        Code to comment:
        #{code}
      PROMPT

      generate_documentation(prompt)
    end

    private

    def read_model_code(model_class)
      file_path = Rails.root.join('app', 'models', "#{model_class.name.underscore}.rb")
      File.read(file_path)
    end

    def read_controller_code(controller_class)
      file_path = Rails.root.join('app', 'controllers', "#{controller_class.name.underscore}.rb")
      File.read(file_path)
    end

    def generate_documentation(prompt)
      body = {
        model: "gpt-4o-mini",
        messages: [
          {
            role: "system",
            content: "You are a professional software documentation expert. Generate clear, accurate, and well-structured documentation."
          },
          {
            role: "user",
            content: prompt
          }
        ],
        max_tokens: 2000
      }

      begin
        response = HTTParty.post(
          @base_url,
          headers: @headers,
          body: body.to_json,
          timeout: 60
        )

        extract_response(response)
      rescue HTTParty::Error => e
        handle_http_error(e)
      end
    end

    def extract_response(response)
      parsed = JSON.parse(response.body)
      content = parsed.dig("choices", 0, "message", "content")

      if content.present?
        content.strip
      else
        Rails.logger.error "No content in response: #{response.body}"
        raise ServiceError, "Failed to generate documentation"
      end
    rescue JSON::ParserError => e
      Rails.logger.error "Invalid JSON response: #{e.message}"
      raise ServiceError, "Invalid API response format"
    end

    def default_api_key
      ENV['OPENAI_API_KEY']
    end
  end
end 