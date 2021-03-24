require "../models/quests/quest"
require "../models/quests/abstract_npc_ai"
require "../scripts/**"
# 511 quests and 176 scripts
module QuestManager
  extend self
  include Loggable

  private QUESTS = {} of String => Quest
  private SCRIPTS = {} of String => Quest

  def load
    timer = Timer.new

    # This goes first, for scripts that add spawns with minions in #initialize.
    MinionSpawnManager.new

    # Classes inside the Scripts namespace are to be instantiated in no
    # particular order. Classes outside of it must be managed manually.
    {% for script in Scripts.constants %}
      Scripts::{{script.id}}.new
    {% end %}

    # This class manages Territory War scripts.
    TerritoryWarSuperClass.load

    info { "Loaded #{QUESTS.size} quests and #{SCRIPTS.size} scripts in #{timer} s." }
  end

  def add_quest(quest : Quest)
    if Config.alt_dev_show_quests_load_in_logs
      debug { "Added quest #{quest.class.simple_name}." }
    end

    QUESTS[quest.name] = quest
  end

  def add_script(script : Quest)
    if Config.alt_dev_show_scripts_load_in_logs
      debug { "Added script #{script.class.simple_name}." }
    end

    SCRIPTS[script.class.simple_name] = script
  end

  def get_quest(name : String) : Quest?
    QUESTS[name]? || SCRIPTS[name]?
  end

  def get_quest(quest_id : Int32) : Quest?
    QUESTS.find_value { |q| q.id == quest_id }
  end

  def quests : Hash(String, Quest)
    QUESTS
  end

  def scripts : Hash(String, Quest)
    SCRIPTS
  end

  def save
    {QUESTS, SCRIPTS}.each &.each_value &.save_global_data
  end
end
