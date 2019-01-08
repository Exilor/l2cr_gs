module GameDB
  module TeleportBookmarkDAO
    abstract def delete(pc : L2PcInstance, id : Int32)
    abstract def insert(pc : L2PcInstance, id : Int32, x : Int32, y : Int32, z : Int32, icon : Int32, tag : String, name : String)
    abstract def update(pc : L2PcInstance, id : Int32, icon : Int32, tag : String, name : String)
    abstract def load(pc : L2PcInstance)
  end
end
