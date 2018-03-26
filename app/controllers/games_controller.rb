require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = Array.new(10) { ('A'..'Z').to_a.sample }
    @starttime = Time.now
  end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    time_taken > 60.0 ? 0 :attempt.size * (1.0 - time_taken / 60.0)
  end

  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    return json['found']
  end

  def score
    @attempt = params[:words]
    @grid = params[:letters].split(',')
    @endtime = Time.now
    @time = (@endtime.to_time.to_i - params[:starttime].to_time.to_i)
    @result = []
    if included?(@attempt.upcase, @grid)
      if english_word?(@attempt)
        score = compute_score(@attempt, @time)
        cookies[:score] = score
        score > cookies[:score] ? cookies[:topscore] = score : cookies[:topscore] = cookies[:topscore]
        return @result = [score, @time, "Well done"]
      else
        return @result = [0, @time, "Not an english word"]
      end
    else
      return @result = [0, @time, "Not in the grid"]
    end
  end

end
