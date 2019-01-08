require "./abstract_get_scroll_to_hometown_quest"

class Quests::Q00045_ToTalkingIsland < Quests::AbstractGetScrollToHometownQuest
  def initialize
    super(45, self.class.simple_name, "To Talking Island")
  end

  def scroll_item_id
    SCROLL_OF_ESCAPE_TALKING_ISLAND_VILLAGE
  end

  def parent_quest_name
    "Q00006_StepIntoTheFuture"
  end
end
