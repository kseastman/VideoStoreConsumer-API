class Customer < ApplicationRecord
  has_many :rentals
  has_many :movies, through: :rentals

  def movies_checked_out_count
    self.rentals.where(returned: false).length
  end

  def checked_out_movies
    open_rentals = self.rentals.where(returned: false)

    return open_rentals.map{|rental|
      Movie.find(rental.movie_id)
    }
  end
end
