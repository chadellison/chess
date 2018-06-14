require 'rails_helper'

RSpec.describe ChatMessage, type: :model do
  it 'belongs to a game' do
    game = Game.new
    chat_message = ChatMessage.new

    game.chat_messages = [chat_message]
    expect(game.chat_messages.first).to eq chat_message
  end
end
