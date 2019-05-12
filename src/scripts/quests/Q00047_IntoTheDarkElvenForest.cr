require "./abstract_get_scroll_to_hometown_quest"

class Scripts::Q00047_IntoTheDarkElvenForest < AbstractGetScrollToHometownQuest
  def initialize
    super(47, self.class.simple_name, "Into the Dark Elven Forest")
  end

  def scroll_item_id
    SCROLL_OF_ESCAPE_DARK_ELF_VILLAGE
  end

  def parent_quest_name
    "Q00008_AnAdventureBegins"
  end
end
