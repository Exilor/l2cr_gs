require "./abstract_saga_quest"

class Scripts::Q00079_SagaOfTheAdventurer < AbstractSagaQuest
  def initialize
    super(79, self.class.simple_name, "Saga of the Adventurer")

    @npc = [
      31603,
      31584,
      31579,
      31615,
      31619,
      31646,
      31647,
      31651,
      31654,
      31655,
      31658,
      31616
    ]
    @items = [
      7080,
      7516,
      7081,
      7494,
      7277,
      7308,
      7339,
      7370,
      7401,
      7432,
      7102,
      0
    ]
    @mob = [
      27299,
      27228,
      27302
    ]
    @class_id = [
      93
    ]
    @prev_class = [
      0x08
    ]
    @npc_spawn_locations = [
      Location.new(119518, -28658, -3811),
      Location.new(181205, 36676, -4816),
      Location.new(181215, 36676, -4812)
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
