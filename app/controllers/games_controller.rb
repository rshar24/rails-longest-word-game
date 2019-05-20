require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @characters = []
    random_no = 10
    # random_no = rand(10..15)
    random_no.times { @characters.push(('A'..'Z').to_a.sample) }
    session[:score] ||= 0
  end

  def grid_check(grid)
    letter_count = {}
    grid.each do |letter|
      if letter_count[letter].nil?
        letter_count[letter] = 1
      else
        letter_count[letter] += 1
      end
    end
    letter_count
  end

  def reset
    session[:score] = 0
    redirect_to new_path
  end

  def score
    characters = params[:characters].split('')
    attempt_array = params[:answer].upcase.split('')
    letter_count = grid_check(characters)
    attempt_hash = {}
    attempt_array.each do |letter|
      if attempt_hash[letter].nil? && !letter_count[letter].nil?
        attempt_hash[letter] = 1
      elsif !attempt_hash[letter].nil? && attempt_hash[letter] < letter_count[letter]
        attempt_hash[letter] += 1
      else
        @score = 0
        @reply = "Sorry but #{params[:answer].upcase} can't be built out of #{ characters.join(', ') }"
        return @reply
      end
    end
    url = "https://wagon-dictionary.herokuapp.com/#{params[:answer]}"
    attempt_serialized = open(url).read
    attempt_api = JSON.parse(attempt_serialized)
    if attempt_api['found'] == true
      @score = attempt_array.length
      @reply = "Congratulations! #{params[:answer].upcase} is a valid English word!"
    elsif attempt_api['found'] == false
      @score = 0
      @reply = "Sorry but #{params[:answer].upcase} does not seem to be a valid English word..."
    end
    session[:score] += @score
    @total_score = session[:score]
  end
end
