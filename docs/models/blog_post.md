# BlogPost Model Documentation

## Model Description
The `BlogPost` model represents a blog post in the application. It includes attributes for the title, content, and an image attachment. The model is designed to manage blog content and associated image generation through AI services.

## Associations
- **has_one_attached :image**: This association allows each `BlogPost` to have one attached image. It leverages Active Storage for handling file uploads.

## Validations
The `BlogPost` model enforces the following validations:
- **Title Presence**: The `title` attribute must be present. An attempt to save a `BlogPost` without a title will result in a validation error.
- **Content Presence**: The `content` attribute must be present. An attempt to save a `BlogPost` without content will also result in a validation error.

## Callbacks
- **after_create**: The `generate_ai_image` method is called after a new `BlogPost` record is created. This method handles the logic for generating an AI-generated image based on the content of the post.

## Important Methods

### `generate_ai_image`
This private method is responsible for generating an image using AI services if no image is already attached. 

**Process:**
1. Checks if an image is already attached. If it is, the method returns early.
2. Summarizes the blog post's content using `Llm::ContentSummarizerService`.
3. Generates an image based on the summarized content using `Llm::DalleService`.
4. Downloads the image and attaches it to the blog post.
5. Logs relevant information for debugging and tracking.

### Error Handling
The method includes error handling to catch exceptions, logging error messages if image generation or attachment fails.

## Usage Examples

### Creating a New BlogPost
To create a new blog post, make sure to provide both a title and content:

```ruby
post = BlogPost.create(title: "My First Blog", content: "This is the content of my first blog post.")
```

### Attaching an Image Manually
If an image needs to be attached manually, it can be done as follows:

```ruby
post = BlogPost.new(title: "My Second Blog", content: "Content for the second blog post.")
post.image.attach(io: File.open('/path/to/image.jpg'), filename: 'image.jpg', content_type: 'image/jpeg')
post.save
```

### Logging for Debugging
The model logs various information during the AI image generation process. You can monitor the logs to troubleshoot or gather insights:

```ruby
Rails.logger.info "Creating blog post..."
post = BlogPost.create(title: "Blog with AI Image", content: "Content for AI image generation.")
```

### Handling Errors
In the event of an error during image generation, it will be logged, and you can check your logs for issues:

```ruby
begin
    post = BlogPost.create(title: "Error Handling Blog", content: "This post will trigger an error in image generation.")
rescue => e
    Rails.logger.error "An error occurred: #{e.message}"
end
```

By following these guidelines and utilizing the provided examples, you can effectively interact with the `BlogPost` model in your Rails application.