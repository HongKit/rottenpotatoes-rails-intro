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
    @all_ratings = Movie.select(:rating).order(:rating).distinct.map(&:rating)
    @selected_ratings = params[:ratings] || {}
    # session[:ratings] = session[:ratings] || Hash[@all_ratings.map {|rating| [rating, rating]}]
    if session[:sort] and not params[:sort]
      redirect_to movies_path(:sort => session[:sort], :ratings => @selected_ratings) and return
    end
    if session[:ratings] and not params[:ratings]
      redirect_to movies_path(:sort => (params[:sort] || ""), :ratings => session[:ratings]) and return
    end
    if @selected_ratings == {}
      @selected_ratings = session[:ratings]
    end
    if params[:ratings] != session[:ratings]
      session[:ratings] = @selected_ratings
    end
    query = Movie.where(rating: @selected_ratings.keys)
    if params[:sort]
      session[:sort] = params[:sort]
    end
    if params[:sort] == 'title_header'
      @movies = query.order(:title)
      @title_header = 'hilite'
    elsif params[:sort] == 'release_date_header'
      @movies = query.order(:release_date)
      @release_date_header = 'hilite'
    else
      @movies = query
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
