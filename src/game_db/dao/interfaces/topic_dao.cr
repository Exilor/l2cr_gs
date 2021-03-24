module GameDB
  module TopicDAO
    macro extended
      include Loggable
    end

    abstract def load(forum : Forum)
    abstract def save(topic : Topic)
    abstract def delete(topic : Topic, forum : Forum)
  end
end
