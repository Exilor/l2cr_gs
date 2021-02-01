module GameDB
  module PostDAO
    include Loggable

    abstract def delete(topic : Topic)
    abstract def update(post : Post)
    abstract def load(topic : Topic) : Array(Post)
  end
end
