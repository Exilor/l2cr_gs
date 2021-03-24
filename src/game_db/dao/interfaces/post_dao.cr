require "../../../community_bbs/post"

module GameDB
  module PostDAO
    macro extended
      include Loggable
    end

    abstract def delete(topic : Topic)
    abstract def update(post : Post)
    abstract def load(topic : Topic) : Array(Post)
  end
end
