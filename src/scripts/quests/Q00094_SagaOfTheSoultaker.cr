require "./abstract_saga_quest"

class Scripts::Q00094_SagaOfTheSoultaker < AbstractSagaQuest
  def initialize
    super(94, self.class.simple_name, "Saga of the Soultaker")

    @npc = [
      30832,
      31623,
      31279,
      31279,
      31645,
      31646,
      31648,
      31650,
      31654,
      31655,
      31657,
      31279
    ]
    @items = [
      7080,
      7533,
      7081,
      7509,
      7292,
      7323,
      7354,
      7385,
      7416,
      7447,
      7085,
      0
    ]
    @mob = [
      27257,
      27243,
      27265
    ]
    @class_id = [
      95
    ]
    @prev_class = [
      0x0d
    ]
    @npc_spawn_locations = [
      Location.new(191046, -40640, -3042),
      Location.new(46066, -36396, -1685),
      Location.new(46087, -36372, -1685)
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
