require "../../../models/holders/quest_item_holder"

class Scripts::Alexandria < AbstractNpcAI
  private class AdditionalQuestItemHolder < QuestItemHolder
    getter additional_id

    def initialize(id : Int32, chance : Int32, count : Int64, @additional_id : Int32)
      super(id, chance, count)
    end
  end

  private ALEXANDRIA = 30098
  private REQUIRED_ITEMS = {
    ItemHolder.new(57, 3550000),
    ItemHolder.new(5094, 400),
    ItemHolder.new(6471, 200),
    ItemHolder.new(9814, 40),
    ItemHolder.new(9815, 30),
    ItemHolder.new(9816, 50),
    ItemHolder.new(9817, 50)
  }
  private LITTLE_DEVILS = {
    AdditionalQuestItemHolder.new(10321, 600, 1, 10408),
    QuestItemHolder.new(10322, 10),
    QuestItemHolder.new(10323, 10),
    QuestItemHolder.new(10324, 5),
    QuestItemHolder.new(10325, 5),
    QuestItemHolder.new(10326, 370)
  }
  private LITTLE_ANGELS = {
    AdditionalQuestItemHolder.new(10315, 600, 1, 10408),
    QuestItemHolder.new(10316, 10),
    QuestItemHolder.new(10317, 10),
    QuestItemHolder.new(10318, 5),
    QuestItemHolder.new(10319, 5),
    QuestItemHolder.new(10320, 370)
  }
  private AGATHIONS = {
    "littleAngel" => LITTLE_ANGELS,
    "littleDevil" => LITTLE_DEVILS
  }

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(ALEXANDRIA)
    add_talk_id(ALEXANDRIA)
    add_first_talk_id(ALEXANDRIA)
  end

  def on_adv_event(event, npc, pc)
    pc = pc.not_nil!

    if event == "30098-02.html"
      html = event
    elsif tmp = AGATHIONS[event]?
      chance = Rnd.rand(1000)
      chance2 = chance3 = 0
      tmp.each do |agathion|
        chance3 += agathion.chance

        if chance >= chance2 && chance2 < chance3
          if take_all_items(pc, REQUIRED_ITEMS)
            give_items(pc, agathion)
            html = "30098-03.html"

            if agathion.is_a?(AdditionalQuestItemHolder)
              give_items(pc, agathion.additional_id, 1)
              html = "30098-03a.html"
            end
          else
            html = "30098-04.html"
          end

          break
        end

        chance2 += agathion.chance
      end
    end

    html
  end
end
