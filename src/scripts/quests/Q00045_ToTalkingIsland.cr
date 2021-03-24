require "./abstract_get_scroll_to_hometown_quest"

class Scripts::Q00045_ToTalkingIsland < AbstractGetScrollToHometownQuest
  def initialize
    super(45, self.class.simple_name, "To Talking Island")
  end

  def scroll_item_id : Int32
    SCROLL_OF_ESCAPE_TALKING_ISLAND_VILLAGE
  end

  def parent_quest_name : String
    "Q00006_StepIntoTheFuture"
  end
end
