require "application_system_test_case"

class BlogPostsTest < ApplicationSystemTestCase
  setup do
    @blog_post = blog_posts(:one)
  end

  test "visiting the index" do
    visit blog_posts_url
    assert_selector "h1", text: "Blog Posts"
  end

  test "should create blog post" do
    visit blog_posts_url
    click_on "New Blog Post"

    fill_in "Content", with: @blog_post.content
    fill_in "Title", with: @blog_post.title
    click_on "Create Blog post"

    assert_text "Blog post was successfully created"
    click_on "Back to posts"
  end

  test "should update Blog post" do
    visit blog_post_url(@blog_post)
    click_on "Edit", match: :first

    fill_in "Content", with: @blog_post.content
    fill_in "Title", with: @blog_post.title
    click_on "Update Blog post"

    assert_text "Blog post was successfully updated"
    click_on "Back to posts"
  end

  test "should destroy Blog post" do
    visit blog_post_url(@blog_post)
    accept_confirm do
      click_on "Delete post", match: :first
    end

    assert_text "Blog post was successfully destroyed"
  end
end
