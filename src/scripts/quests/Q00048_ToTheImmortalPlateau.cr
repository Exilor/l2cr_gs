require "./abstract_get_scroll_to_hometown_quest"

class Quests::Q00048_ToTheImmortalPlateau < Quests::AbstractGetScrollToHometownQuest
  def initialize
    super(48, self.class.simple_name, "To The Immortal Plateau")
  end

  def scroll_item_id
    SCROLL_OF_ESCAPE_ORC_VILLAGE
  end

  def parent_quest_name
    "Q00009_IntoTheCityOfHumans"
  end
end
