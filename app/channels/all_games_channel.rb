class AllGamesChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'all_games'
  end

  def unsubscribed
  end
end
