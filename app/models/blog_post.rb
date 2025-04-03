require 'open-uri'
class BlogPost < ApplicationRecord
    has_one_attached :image

    validates :title, presence: true
    validates :content, presence: true

    after_create :generate_ai_image

    private

    def generate_ai_image
        return if self.image.attached? # Skip if an image is already uploaded

        image_url = Llm::DalleService.new.generate_image("An artistic image representing: #{self.content}")
        # image_url = Llm::StableDiffusionService.new.generate_image("A visual representation of: #{self.content}")
        Rails.logger.info "🖼️ Generated image URL: #{image_url}"
        
        # binding.pry
        
        # Download the image and attach it
        content_type = image_url.include?(".png") ? "image/png" : "image/jpeg"

        # Download and attach image
        downloaded_image = URI.open(image_url)
        if self.image.attach(io: downloaded_image, filename: "blogpost_#{id}.jpg", content_type: content_type)
        save! # Ensure record is saved only if attachment succeeds
        else
        Rails.logger.error "Image attachment failed"
        end
    rescue => e
        Rails.logger.error "Failed to generate AI image: #{e.message}"
    end
end
