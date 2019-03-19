require "./abstract_saga_quest"

class Quests::Q00073_SagaOfTheDuelist < Quests::AbstractSagaQuest
  private TUNATUN = 31537
  private TOP_QUALITY_MEAT = 7546

  def initialize
    super(73, self.class.simple_name, "Saga of the Duelist")

    @npc = [
      30849,
      31624,
      31226,
      31331,
      31639,
      31646,
      31647,
      31653,
      31654,
      31655,
      31656,
      31277
    ]
    @items = [
      7080,
      7537,
      7081,
      7488,
      7271,
      7302,
      7333,
      7364,
      7395,
      7426,
      7096,
      7546
    ]
    @mob = [
      27289,
      27222,
      27281
    ]
    @class_id = [
      88
    ]
    @prev_class = [
      0x02
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
    add_talk_id(TUNATUN)
  end

  def on_talk(npc, pc)
    if npc.id == TUNATUN
      st = get_quest_state(pc, false)
      if st && st.cond?(3)
        unless st.has_quest_items?(TOP_QUALITY_MEAT)
          st.give_items(TOP_QUALITY_MEAT, 1)
          return "tunatun_01.htm"
        end

        return "tunatun_02.htm"
      end

      return get_no_quest_msg(pc)
    end

    super
  end
end
