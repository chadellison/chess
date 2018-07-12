class MachineVsMachineJob < ApplicationJob
  queue_as :default

  def perform(game)
    game.machine_vs_machine
  end
end
