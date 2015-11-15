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
    
    if params[:ratings] and params[:sort_by]
      red = false
      @ratings = params[:ratings].keys
      @sort_by = params[:sort_by]
    elsif params[:ratings] and params[:sort_by] == nil
      @ratings = params[:ratings].keys
      if session[:sort_by]
        @sort_by = session[:sort_by]
        red = true
      else
        @sort_by = nil
        red = false
      end
    elsif params[:ratings] == nil and params[:sort_by]
      @sort_by = params[:sort_by]
      if session[:ratings]
        @ratings = session[:ratings]
        red = true
      else
        @ratings = @all_ratings
        red = false
      end
    else
      red = true
      if session[:ratings] and session[:sort_by]
        @ratings = session[:ratings]
        @sort_by = session[:sort_by]
      elsif session[:ratings] and session[:sort_by] == nil
        @ratings = session[:ratings]
        @sort_by = nil
      elsif session[:ratings] == nil and session[:sort_by]
        @ratings = @all_ratings
        @sort_by = session[:sort_by]
      else
        @ratings = @all_ratings
        @sort_by = nil
        red = false
      end  
    end
    
    session[:sort_by] = @sort_by
    session[:ratings] = @ratings
    
    if red
      flash.keep
      ratings_params = Hash[*@ratings.collect {|k| [k, '1']}.flatten]
      return redirect_to movies_path(nil, {:sort_by => @sort_by, :ratings => ratings_params})
    else
      @movies = Movie.where(:rating => @ratings)
      if @sort_by
        @movies = @movies.order(@sort_by)
      end      
    end


    
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
