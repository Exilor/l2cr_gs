require "./forum_type"
require "./forum_visibility"
require "./topic"

class Forum
  getter parent, children, topics
  property id : Int32
  property name : String
  property type : ForumType
  property post : Int32
  property visibility : ForumVisibility
  property owner_id : Int32

  def initialize(id : Int32, name : String, parent : self?, type : ForumType, visibility : ForumVisibility, owner_id : Int32)
    @id = id
    @name = name
    @type = type
    @post = 0
    @visibility = visibility
    @parent = parent
    @owner_id = owner_id

    @children = Concurrent::Map(String, Forum).new
    @topics = Concurrent::Map(Int32, Topic).new
  end

  def topic_size : Int32
    @topics.size
  end

  def get_topic(id : Int32) : Topic?
    @topics[id]?
  end

  def add_topic(t : Topic)
    @topics[t.id] = t
  end

  def remove_topic(id : Int32)
    @topics.delete(id)
  end

  def get_child_by_name(name : String)
    @children[name]?
  end

  def add_child(child : Forum)
    @children[child.name] = child
  end
end
