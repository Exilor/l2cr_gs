module GameDB
  module ForumDAO
    macro extended
      include Loggable
    end

    abstract def forums : Hash(String, Forum)
    abstract def save(forum : Forum)
  end
end
