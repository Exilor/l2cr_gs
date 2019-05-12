require "./abstract_saga_quest"

class Scripts::Q00075_SagaOfTheTitan < AbstractSagaQuest
  def initialize
    super(75, self.class.simple_name, "Saga of the Titan")

    @npc = [
      31327,
      31624,
      31289,
      31290,
      31607,
      31646,
      31649,
      31651,
      31654,
      31655,
      31658,
      31290
    ]
    @items = [
      7080,
      7539,
      7081,
      7490,
      7273,
      7304,
      7335,
      7366,
      7397,
      7428,
      7098,
      0
    ]
    @mob = [
      27292,
      27224,
      27283
    ]
    @class_id = [
      113
    ]
    @prev_class = [
      0x2e
    ]
    @npc_spawn_locations = [
      Location.new(119518, -28658, -3811),
      Location.new(181215, 36676, -4812),
      Location.new(181227, 36703, -4816)
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
