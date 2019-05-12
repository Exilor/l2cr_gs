require "./abstract_saga_quest"

class Scripts::Q00086_SagaOfTheHierophant < AbstractSagaQuest
  def initialize
    super(86, self.class.simple_name, "Saga of the Hierophant")

    @npc = [
      30191,
      31626,
      31588,
      31280,
      31591,
      31646,
      31648,
      31652,
      31654,
      31655,
      31659,
      31280
    ]
    @items = [
      7080,
      7523,
      7081,
      7501,
      7284,
      7315,
      7346,
      7377,
      7408,
      7439,
      7089,
      0
    ]
    @mob = [
      27269,
      27235,
      27275
    ]
    @class_id = [
      98
    ]
    @prev_class = [
      0x11
    ]
    @npc_spawn_locations = [
      Location.new(161719, -92823, -1893),
      Location.new(124355, 82155, -2803),
      Location.new(124376, 82127, -2796)
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
