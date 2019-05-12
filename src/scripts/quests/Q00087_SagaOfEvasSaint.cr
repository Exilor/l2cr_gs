require "./abstract_saga_quest"

class Scripts::Q00087_SagaOfEvasSaint < AbstractSagaQuest
  def initialize
    super(87, self.class.simple_name, "Saga of Eva's Saint")

    @npc = [
      30191,
      31626,
      31588,
      31280,
      31620,
      31646,
      31649,
      31653,
      31654,
      31655,
      31657,
      31280
    ]
    @items = [
      7080,
      7524,
      7081,
      7502,
      7285,
      7316,
      7347,
      7378,
      7409,
      7440,
      7088,
      0
    ]
    @mob = [
      27266,
      27236,
      27276
    ]
    @class_id = [
      105
    ]
    @prev_class = [
      0x1e
    ]
    @npc_spawn_locations = [
      Location.new(164650, -74121, -2871),
      Location.new(46087, -36372, -1685),
      Location.new(46066, -36396, -1685)
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
