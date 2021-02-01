require "./topic_type"

class Topic
  property_initializer id : Int32, forum_id : Int32, name : String,
    date : Int64, owner_name : String, owner_id : Int32, type : TopicType,
    reply : Int32
end
