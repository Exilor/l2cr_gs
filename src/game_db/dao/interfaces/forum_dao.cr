module GameDB
  module ForumDAO
    include Loggable

    abstract def forums : Hash(String, Forum)
    abstract def save(forum : Forum)
  end
end
