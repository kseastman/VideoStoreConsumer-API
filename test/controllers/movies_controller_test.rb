require 'test_helper'

class MoviesControllerTest < ActionDispatch::IntegrationTest
  describe "index" do
    it "returns a JSON array" do
      get movies_url
      assert_response :success
      @response.headers['Content-Type'].must_include 'json'

      # Attempt to parse
      data = JSON.parse @response.body
      data.must_be_kind_of Array
    end

    it "should return many movie fields" do
      get movies_url
      assert_response :success

      data = JSON.parse @response.body
      data.each do |movie|
        movie.must_include "title"
        movie.must_include "release_date"
      end
    end

    it "returns all movies when no query params are given" do
      get movies_url
      assert_response :success

      data = JSON.parse @response.body
      data.length.must_equal Movie.count

      expected_names = {}
      Movie.all.each do |movie|
        expected_names[movie["title"]] = false
      end

      data.each do |movie|
        expected_names[movie["title"]].must_equal false, "Got back duplicate movie #{movie["title"]}"
        expected_names[movie["title"]] = true
      end
    end
  end

  describe "show" do
    it "Returns a JSON object" do
      get movie_url(title: movies(:one).title)
      assert_response :success
      @response.headers['Content-Type'].must_include 'json'

      # Attempt to parse
      data = JSON.parse @response.body
      data.must_be_kind_of Hash
    end

    it "Returns expected fields" do
      get movie_url(title: movies(:one).title)
      assert_response :success

      movie = JSON.parse @response.body
      movie.must_include "title"
      movie.must_include "overview"
      movie.must_include "release_date"
      movie.must_include "inventory"
      movie.must_include "available_inventory"
    end

    it "Returns an error when the movie doesn't exist" do
      get movie_url(title: "does_not_exist")
      assert_response :not_found

      data = JSON.parse @response.body
      data.must_include "errors"
      data["errors"].must_include "title"

    end
  end

  describe "create" do
    it "builds a new movie from api request" do
      VCR.use_cassette("movies") do
        first_movie = MovieWrapper.search('Princess Bride').first

        post movies_url(query: first_movie.external_id.to_s)
        assert_response :success

        body = JSON.parse(response.body)
        body.must_be_kind_of Hash

        # movie = Movie.last
        body['title'].must_equal "The Princess Bride"
      end
    end

    it "does not allow a duplicate movie to be created" do
      VCR.use_cassette("movies") do
        #Arrange
        first_movie = MovieWrapper.search('Princess Bride').first

        post movies_url(query: first_movie.external_id.to_s)
        assert_response :success

        movie = Movie.last

        movie.title.must_equal "The Princess Bride"

        #Act
        post movies_url(query: first_movie.external_id.to_s)

        #Assert
        assert_response :not_found
      end
    end
  end
end
