class BlogPostsController < ApplicationController
  before_action :set_blog_post, only: %i[ show edit update destroy ]

  # GET /blog_posts or /blog_posts.json
  def index
    @blog_posts = BlogPost.all
  end

  # GET /blog_posts/1 or /blog_posts/1.json
  def show
  end

  # GET /blog_posts/new
  def new
    @blog_post = BlogPost.new
  end

  # GET /blog_posts/1/edit
  def edit
  end

  # POST /blog_posts or /blog_posts.json
  def create
    @blog_post = BlogPost.new(blog_post_params)

    respond_to do |format|
      if @blog_post.save
        format.html { redirect_to @blog_post, notice: "Blog post was successfully created." }
        format.json { render :show, status: :created, location: @blog_post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @blog_post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /blog_posts/1 or /blog_posts/1.json
  def update
    respond_to do |format|
      if @blog_post.update(blog_post_params)
        format.html { redirect_to @blog_post, notice: "Blog post was successfully updated." }
        format.json { render :show, status: :ok, location: @blog_post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @blog_post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /blog_posts/1 or /blog_posts/1.json
  def destroy
    @blog_post.destroy!

    respond_to do |format|
      format.html { redirect_to blog_posts_path, status: :see_other, notice: "Blog post was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # POST /blog_posts/generate_commentary
  def generate_commentary
    content = params.expect(:content)

    commentary_service = Llm::ContentCommentaryService.new
    commentary = commentary_service.generate_commentary(content)

    render json: { commentary: commentary }
  rescue ActionController::ParameterMissing => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # GET /blog_posts/stream_commentary
  def stream_commentary
    content = params.expect(:content)


    response.headers["Content-Type"] = "text/event-stream"
    response.headers["Cache-Control"] = "no-cache"
    response.headers["Connection"] = "keep-alive"

    # Create a new commentary service
    commentary_service = Llm::ContentCommentaryService.new

    # Start streaming the response
    begin
      commentary_service.generate_commentary_stream(content) do |chunk|
        response.stream.write("data: #{chunk.to_json}\n\n")
      end
    rescue => e
      response.stream.write("data: #{{ error: e.message }.to_json}\n\n")
    ensure
      response.stream.write("data: [DONE]\n\n")
      response.stream.close
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_blog_post
      @blog_post = BlogPost.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def blog_post_params
      params.expect(blog_post: [ :title, :content ])
    end
end
