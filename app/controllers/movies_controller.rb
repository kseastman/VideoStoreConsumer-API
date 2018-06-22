require 'pry'
class MoviesController < ApplicationController
  before_action :require_movie, only: [:show]

  def index
    if params[:query]
      data = MovieWrapper.search(params[:query])
    else
      data = Movie.all
    end

    render status: :ok, json: data.as_json(
      only: [:title, :overview, :inventory],
      methods: [:release_year]
    )
  end

  def show
    render(
      status: :ok,
      json: @movie.as_json(
        only: [:title, :overview, :inventory],
        methods: [:release_year]
        )
      )
  end

  def create
    movie = MovieWrapper.id_search(params[:query])
    if movie
      if movie.save
        render(
          status: :ok,
          json: movie.as_json(
            only: [:title, :overview, :release_date, :inventory]
          ))
      else
        render status: :error, json: { errors: movie.errors.messages }
      end
    else
      render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
    end
  end

  private

  def require_movie
    @movie = Movie.find_by(title: params[:title])
    unless @movie
      render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
    end
  end

end
