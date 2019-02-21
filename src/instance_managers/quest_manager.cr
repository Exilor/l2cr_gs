require "../models/quests/quest"
require "../models/quests/abstract_npc_ai"
require "../scripts/**"

module QuestManager
  extend self
  extend Loggable

  private QUESTS = Hash(String, Quest).new
  private SCRIPTS = Hash(String, Quest).new

  def load
    {% for sub in Quest.all_subclasses.reject &.abstract? %}
      {{sub.id}}.new
    {% end %}

    info "Loaded #{QUESTS.size} quests and #{SCRIPTS.size} scripts."
  end

  def add_quest(quest : Quest)
    if Config.alt_dev_show_quests_load_in_logs
      debug "Added quest #{quest.class.simple_name}."
    end

    QUESTS[quest.name] = quest
  end

  def add_script(script : Quest)
    if Config.alt_dev_show_scripts_load_in_logs
      info "Added script #{script.class.simple_name}."
    end

    SCRIPTS[script.class.simple_name] = script
  end

  def get_quest(name : String) : Quest?
    QUESTS[name]? || SCRIPTS[name]?
  end

  def get_quest(quest_id : Int32) : Quest?
    QUESTS.find_value { |q| q.id == quest_id }
  end

  def quests
    QUESTS
  end

  def scripts
    SCRIPTS
  end

  def save
    QUESTS.each_value &.save_global_data
    SCRIPTS.each_value &.save_global_data
  end
end
