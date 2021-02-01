module ForumsBBSManager
  extend self
  extend Loggable

  private FORUMS_BY_NAME = Hash(String, Forum).new
  private FORUMS_BY_ID = Hash(Int32, Forum).new

  def load
    FORUMS_BY_NAME.merge!(GameDB.forum.forums)
    FORUMS_BY_NAME.each_value { |forum| FORUMS_BY_ID[forum.id] = forum }
    info { "Loaded #{FORUMS_BY_NAME.size} forums." }
  end

  def get_forum_by_name(name : String) : Forum?
    FORUMS_BY_NAME[name]?
  end

  def get_forum_by_id(id : Int32) : Forum?
    FORUMS_BY_ID[id]?
  end

  def create(name : String, parent : Forum, type : ForumType, visibility : ForumVisibility, owner_id : Int32) : Forum
    forum = Forum.new(0, name, parent, type, visibility, owner_id)
    parent.add_child(forum)
    GameDB.forum.save(forum)
    FORUMS_BY_NAME[forum.name] = forum
    FORUMS_BY_ID[forum.id] = forum
    forum
  end

  def load(id : Int32, name : String, parent : Forum, type : ForumType, visibility : ForumVisibility, owner_id : Int32) : Forum
    forum = Forum.new(id, name, parent, type, visibility, owner_id)
    parent.add_child(forum)
    FORUMS_BY_NAME[forum.name] = forum
    FORUMS_BY_ID[forum.id] = forum
    forum
  end

  def on_clan_level(clan : L2Clan)
    if clan.level >= 2 && Config.enable_community_board
      if root = get_forum_by_name("ClanRoot")
        if forum = root.get_child_by_name(clan.name)
          create(
            clan.name,
            root,
            ForumType::CLAN,
            ForumVisibility::CLAN_MEMBER_ONLY,
            clan.id
          )
        end
      end
    end
  end
end
