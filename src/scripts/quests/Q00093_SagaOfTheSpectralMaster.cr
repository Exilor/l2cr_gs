require "./abstract_saga_quest"

class Scripts::Q00093_SagaOfTheSpectralMaster < AbstractSagaQuest
  def initialize
    super(93, self.class.simple_name, "Saga of the Spectral Master")

    @npc = [
      30175,
      31287,
      31613,
      30175,
      31632,
      31646,
      31649,
      31653,
      31654,
      31655,
      31656,
      31613
    ]
    @items = [
      7080,
      7606,
      7081,
      7508,
      7291,
      7322,
      7353,
      7384,
      7415,
      7446,
      7112,
      0
    ]
    @mob = [
      27315,
      27242,
      27312
    ]
    @class_id = [
      111
    ]
    @prev_class = [
      0x29
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
