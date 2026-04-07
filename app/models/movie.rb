class Movie < ApplicationRecord
  def self.all_ratings
    %w[G PG PG-13 R]
  end

  def self.with_ratings(ratings, sort_by)
    if ratings.nil?
      all.order sort_by
    else
      where(rating: ratings.map(&:upcase)).order sort_by
    end
  end

  def self.find_in_tmdb(string)
    if string.is_a?(Hash)
      api_key = ENV['TMDB_API_KEY'] || 'your_api_key_here'
      url = "https://api.themoviedb.org/3/search/movie?api_key=#{api_key}&query=#{string[:title]}"
      url += "&year=#{string[:release_year]}" if string[:release_year].present?
      url += "&language=#{string[:language]}" if string[:language].present?
      response = Faraday.get(url)
      results = JSON.parse(response.body)['results']
      results.map do |movie|
        Movie.new(
          title: movie['title'],
          release_date: movie['release_date'],
          rating: 'R'
        )
      end
    else
      Faraday.get(string)
    end
  end
end