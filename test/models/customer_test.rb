require 'test_helper'

class CustomerTest < ActiveSupport::TestCase
  let (:customer_data) {
    {
      "name": "Ada Testington III",
      "registered_at": "Wed, 29 Apr 2015 07:54:14 -0700",
      "address": "12345 Ada Ave E",
      "city": "Seattle",
      "state": "WA",
      "postal_code": "98107",
      "phone": "(123) 456-7890",
      "account_credit": 13.15
    }
  }

  before do
    @customer = Customer.create!(customer_data)
  end

  describe "Constructor" do
    it "Can be created" do
      Customer.create!(customer_data)
    end

    it "Has rentals" do
      @customer.must_respond_to :rentals
    end

    it "Has movies" do
      @customer.must_respond_to :movies
    end
  end

  describe "movies_checked_out_count" do
    it "Should exist" do
      @customer.must_respond_to :movies_checked_out_count
    end

    it "Returns 0 if no rentals" do
      # Burn the world
      Rental.destroy_all

      @customer.reload
      @customer.movies_checked_out_count.must_equal 0
    end

    it "Returns the number of movies checked out" do
      Rental.destroy_all

      Rental.create!(
        customer: @customer,
        movie: movies(:one),
        due_date: Date.today + 7,
        returned: false
      )
      Rental.create!(
        customer: @customer,
        movie: movies(:two),
        due_date: Date.today + 7,
        returned: false
      )

      @customer.reload
      @customer.movies_checked_out_count.must_equal 2
    end

    it "Ignores returned movies" do
      Rental.destroy_all

      Rental.create!(
        customer: @customer,
        movie: movies(:one),
        due_date: Date.today + 7,
        returned: true
      )

      @customer.reload
      @customer.movies_checked_out_count.must_equal 0
    end
  end

  describe "checked_out_movies" do
    it "Should exist" do
      @customer.must_respond_to :checked_out_movies
    end

    it "returns an empty array if the customer has no rentals" do
      @customer.checked_out_movies.must_equal []
    end

    it "returns the movie as json of a rental that has not yet been checked in" do
      @customer.checked_out_movies.must_equal []

      Rental.create!(
        customer: @customer,
        movie: movies(:one),
        due_date: Date.today + 7,
        returned: false
      )

      movie = Movie.find(Rental.last.movie_id)

      @customer.checked_out_movies[0]['id'].must_equal movie.id
    end

    it "returns the due date of the movie" do
      @customer.checked_out_movies.must_equal []

      Rental.create!(
        customer: @customer,
        movie: movies(:one),
        due_date: Date.today + 7,
        returned: false
      )

      movie = Movie.find(Rental.last.movie_id)
      @customer.checked_out_movies[0].keys.must_include 'due_date'
    end

    it "ignores returned movies" do
      Rental.create!(
        customer: @customer,
        movie: movies(:one),
        due_date: Date.today + 7,
        returned: false
      )

      @customer.checked_out_movies.length.must_equal 1

      rental = Rental.last
      rental.update!(returned: true)

      @customer.checked_out_movies.must_be_empty

    end
  end
end
