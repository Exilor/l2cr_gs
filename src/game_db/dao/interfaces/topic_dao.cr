module GameDB
  module TopicDAO
    include Loggable

    abstract def load(forum : Forum)
    abstract def save(topic : Topic)
    abstract def delete(topic : Topic, forum : Forum)
  end
end
