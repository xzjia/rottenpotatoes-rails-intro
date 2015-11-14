class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    @sort_by = nil
    @ratings = @all_ratings

    if params.fetch("ratings", false)
      @ratings = params[:ratings].keys
    end

    if ["title", "release_date"].member?(params.fetch("sort_by", nil))
      @sort_by = params[:sort_by]
    end

    sess_sort = session.fetch("movies_sort", nil)
    sess_ratings = session.fetch("movies_ratings", @all_ratings)

    # If you access default URL and have stored settings, then redirect you to right URL
    if (@ratings == @all_ratings and @sort_by == nil and
        (sess_ratings != @all_ratings or sess_sort != nil))
      flash.keep
      # We store ratings as array, but to GET params they should pass as hash
      ratings_params = Hash[*sess_ratings.collect {|k| [k, 'yes']}.flatten]
      return redirect_to movies_path(nil, {:sort_by => sess_sort, :ratings => ratings_params})
    end

    @movies = Movie.where(:rating => @ratings)
    if @sort_by
      @movies = @movies.order(@sort_by)
    end

    session[:movies_sort] = @sort_by
    session[:movies_ratings] = @ratings  
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
