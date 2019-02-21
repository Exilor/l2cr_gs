require "./abstract_saga_quest"

class Quests::Q00096_SagaOfTheSpectralDancer < Quests::AbstractSagaQuest
  def initialize
    super(96, self.class.simple_name, "Saga of the Spectral Dancer")

    @npc = [
      31582,
      31623,
      31284,
      31284,
      31611,
      31646,
      31649,
      31653,
      31654,
      31655,
      31656,
      31284
    ]
    @items = [
      7080,
      7527,
      7081,
      7511,
      7294,
      7325,
      7356,
      7387,
      7418,
      7449,
      7092,
      0
    ]
    @mob = [
      27272,
      27245,
      27264
    ]
    @class_id = [
      107
    ]
    @prev_class = [
      0x22
    ]
    @npc_spawn_locations = [
      Location.new(164650, -74121, -2871),
      Location.new(47429, -56923, -2383),
      Location.new(47391, -56929, -2370)
    ]
    @text = [
      "PLAYERNAME! Pursued to here! However, I jumped out of the Banshouren boundaries! You look at the giant as the sign of power!",
      "... Oh ... good! So it was ... let's begin!",
      "I do not have the patience ..! I have been a giant force ...! Cough chatter ah ah ah!",
      "Paying homage to those who disrupt the orderly will be PLAYERNAME's death!",
      "Now, my soul freed from the shackles of the millennium, Halixia, to the back side I come ...",
      "Why do you interfere others' battles?",
      "This is a waste of time.. Say goodbye...!",
      "...That is the enemy",
      "...Goodness! PLAYERNAME you are still looking?",
      "PLAYERNAME ... Not just to whom the victory. Only personnel involved in the fighting are eligible to share in the victory.",
      "Your sword is not an ornament. Don't you think, PLAYERNAME?",
      "Goodness! I no longer sense a battle there now.",
      "let...",
      "Only engaged in the battle to bar their choice. Perhaps you should regret.",
      "The human nation was foolish to try and fight a giant's strength.",
      "Must...Retreat... Too...Strong.",
      "PLAYERNAME. Defeat...by...retaining...and...Mo...Hacker",
      "....! Fight...Defeat...It...Fight...Defeat...It..."
    ]
    register_npcs
  end
end
