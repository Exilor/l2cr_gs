require "../../../../community_bbs/manager/topic_bbs_manager"

module GameDB
  module TopicDAOMySQLImpl
    extend self
    extend TopicDAO

    private SELECT_TOPICS = "SELECT * FROM topic WHERE topic_forum_id=? ORDER BY topic_id DESC"
    private DELETE_TOPIC = "DELETE FROM topic WHERE topic_id=? AND topic_forum_id=?"
    private INSERT_TOPIC = "INSERT INTO topic (topic_id,topic_forum_id,topic_name,topic_date,topic_ownername,topic_ownerid,topic_type,topic_reply) values (?,?,?,?,?,?,?,?)"

    def load(forum : Forum)
      GameDB.each(SELECT_TOPICS, forum.id) do |rs|
        topic = Topic.new(
          rs.get_i32(:"topic_id"),
          rs.get_i32(:"topic_forum_id"),
          rs.get_string(:"topic_name"),
          rs.get_i64(:"topic_date"),
          rs.get_string(:"topic_ownername"),
          rs.get_i32(:"topic_ownerid"),
          TopicType[rs.get_i32(:"topoc_type")],
          rs.get_i32(:"topic_reply"),
        )

        TopicBBSManager.add_topic(topic)

        forum.topics[topic.id] = topic

        if topic.id > TopicBBSManager.get_max_id(forum)
          TopicBBSManager.set_max_id(topic.id, forum)
        end
      end
    rescue e
      error e
    end

    def save(topic : Topic)
      GameDB.exec(
        INSERT_TOPIC,
        topic.id,
        topic.forum_id,
        topic.name,
        topic.date,
        topic.owner_name,
        topic.owner_id,
        topic.type.to_i,
        topic.reply
      )
    rescue e
      error e
    end

    def delete(topic : Topic, forum : Forum)
      TopicBBSManager.delete_topic(topic)
      forum.remove_topic(topic.id)

      begin
        GameDB.exec(DELETE_TOPIC, topic.id, forum.id)
      rescue e
        error e
      end
    end
  end
end
