module Api
  module V1
    class AllGamesController < ApplicationController
      # include ActionController::Live

      def index
        # sse = SSE.new(response.stream)
        # response.headers['Content-Type'] = 'text/event-stream'

        games = (1..4).map do
          game = Game.create
          MachineVsMachineJob.perform_later(game)
          game
          # sse.write({data: GameSerializer.serialize(game)})
        end
        game_data = games.map { |game| GameSerializer.serialize(game) }
        render json: { data: game_data }
        # 10.times do |i|
        #   sse.write({count: i}.to_json)
        # end
      # rescue IOError
      # ensure
      #   sse.close
      end

      def show
        game = Game.find(params[:id])
        render json: { data: GameSerializer.serialize(game) }
      end
    end
  end
end
