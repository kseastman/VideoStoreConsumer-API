require 'test_helper'

class MoviesWrapperTest < ActionDispatch::IntegrationTest
  describe "id_search" do
    it "returns an instance of movie" do
      VCR.use_cassette('movies') do
        first_movie = MovieWrapper.search('Princess Bride').first

        movie = MovieWrapper.id_search(first_movie.external_id.to_s)
        movie.must_be_instance_of Movie
      end
    end
  end
end
