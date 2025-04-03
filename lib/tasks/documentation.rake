namespace :docs do
  desc "Generate documentation for all models"
  task models: :environment do
    doc_service = Llm::DocumentationService.new
    output_dir = Rails.root.join("docs", "models")
    FileUtils.mkdir_p(output_dir)

    Rails.application.eager_load!
    ActiveRecord::Base.descendants.each do |model|
      next if model.name == "ApplicationRecord"

      puts "Generating documentation for #{model.name}..."
      begin
        docs = doc_service.generate_model_documentation(model)
        File.write(output_dir.join("#{model.name.underscore}.md"), docs)
        puts "✓ Documentation generated for #{model.name}"
      rescue => e
        puts "✗ Failed to generate documentation for #{model.name}: #{e.message}"
      end
    end
  end

  desc "Generate documentation for all controllers"
  task controllers: :environment do
    doc_service = Llm::DocumentationService.new
    output_dir = Rails.root.join("docs", "controllers")
    FileUtils.mkdir_p(output_dir)

    Rails.application.eager_load!
    ApplicationController.descendants.each do |controller|
      next if controller.name == "ApplicationController"

      puts "Generating documentation for #{controller.name}..."
      begin
        docs = doc_service.generate_controller_documentation(controller)
        File.write(output_dir.join("#{controller.name.underscore}.md"), docs)
        puts "✓ Documentation generated for #{controller.name}"
      rescue => e
        puts "✗ Failed to generate documentation for #{controller.name}: #{e.message}"
      end
    end
  end

  desc "Generate API documentation for all controllers"
  task api: :environment do
    doc_service = Llm::DocumentationService.new
    output_dir = Rails.root.join("docs", "api")
    FileUtils.mkdir_p(output_dir)

    Rails.application.eager_load!
    ApplicationController.descendants.each do |controller|
      next if controller.name == "ApplicationController"

      puts "Generating API documentation for #{controller.name}..."
      begin
        docs = doc_service.generate_api_documentation(controller)
        File.write(output_dir.join("#{controller.name.underscore}.yaml"), docs)
        puts "✓ API documentation generated for #{controller.name}"
      rescue => e
        puts "✗ Failed to generate API documentation for #{controller.name}: #{e.message}"
      end
    end
  end

  desc "Add comments to a specific file"
  task :comment, [ :file_path ] => :environment do |t, args|
    if args[:file_path].blank?
      puts "Please provide a file path: rake docs:comment[path/to/file.rb]"
      exit 1
    end

    file_path = Rails.root.join(args[:file_path])
    unless File.exist?(file_path)
      puts "File not found: #{file_path}"
      exit 1
    end

    doc_service = Llm::DocumentationService.new
    code = File.read(file_path)
    language = File.extname(file_path).delete(".")

    puts "Adding comments to #{file_path}..."
    begin
      commented_code = doc_service.add_code_comments(code, language)
      File.write(file_path, commented_code)
      puts "✓ Comments added successfully"
    rescue => e
      puts "✗ Failed to add comments: #{e.message}"
    end
  end

  desc "Generate all documentation"
  task all: [ :models, :controllers, :api ]
end
