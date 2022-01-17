require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    p session[:total_score] = 0 if !session.has_key?("total_score")
    p @total = session[:total_score]
    @letters = []
    10.times { @letters << ('A'..'Z').to_a.sample }
  end

  def score
    p @word = params[:word]
    p @letters = params[:letters].split("")

    def valid_in_grid?(grid, word)
      letters = word.upcase.chars
      return letters.all? { |letter| grid.count(letter) >= letters.count(letter) }
    end

    def lookup_word(word)
      url = "https://wagon-dictionary.herokuapp.com/#{word}"
      response = URI.open(url).read
      return JSON.parse(response)
    end

    def determine_score(response, valid_in_grid, word)
      return response["found"] && valid_in_grid ? (word.length * 10) : 0
    end

    def generate_message(response, valid_in_grid)
      if response["error"]
        return "Sorr, but #{@word} does not seem to be a valid English world!"
      elsif response["found"]
        if valid_in_grid
          return "Congratulations! #{@word.capitalize} is a valid English word!"
        else
          return "Sorry, but #{@word} can't be built out of #{@letters.join(", ").upcase}!"
        end
      end
    end

    def run_game(attempt, grid)
      response = lookup_word(attempt)
      valid_in_grid = valid_in_grid?(grid, attempt)
      score = determine_score(response, valid_in_grid, attempt)
      message = generate_message(response, valid_in_grid)
      return { score: score, message: message}
    end

    p @results = run_game(@word, @letters)
    p session[:total_score] += @results[:score]
    @total = session[:total_score]
  end
end
