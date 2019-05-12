require "./abstract_get_scroll_to_hometown_quest"

class Scripts::Q00046_OnceMoreInTheArmsOfTheMotherTree < AbstractGetScrollToHometownQuest
  def initialize
    super(46, self.class.simple_name, "Once More In the Arms of the Mother Tree")
  end

  def scroll_item_id
    SCROLL_OF_ESCAPE_ELVEN_VILLAGE
  end

  def parent_quest_name
    "Q00007_ATripBegins"
  end
end
