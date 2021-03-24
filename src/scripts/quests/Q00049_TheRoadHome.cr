require "./abstract_get_scroll_to_hometown_quest"

class Scripts::Q00049_TheRoadHome < AbstractGetScrollToHometownQuest
  def initialize
    super(49, self.class.simple_name, "The Road Home")
  end

  def scroll_item_id : Int32
    SCROLL_OF_ESCAPE_DWARVEN_VILLAGE
  end

  def parent_quest_name : String
    "Q00010_IntoTheWorld"
  end
end
