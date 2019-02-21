require "./abstract_saga_quest"

class Quests::Q00069_SagaOfTheTrickster < Quests::AbstractSagaQuest
  def initialize
    super(69, self.class.simple_name, "Saga of the Trickster")

    @npc = [
      32138,
      31270,
      31282,
      32228,
      32263,
      31646,
      31649,
      31653,
      31654,
      31655,
      31659,
      31283
    ]
    @items = [
      7080,
      9761,
      7081,
      9742,
      9724,
      9727,
      9730,
      9733,
      9736,
      9739,
      9718,
      0
    ]
    @mob = [
      27333,
      27334,
      27335
    ]
    @class_id = [
      134
    ]
    @prev_class = [
      0x82
    ]
    @npc_spawn_locations = [
      Location.new(164014, -74733, -3093),
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
