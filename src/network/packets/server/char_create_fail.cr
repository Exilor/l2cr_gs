# class Packets::Outgoing::CharCreateFail < GameServerPacket
#   initializer error: UInt8

#   def write_impl
#     c 0x10
#     d @error
#   end

#   def self.creation_failed
#     new(0)
#   end

#   def self.too_many_characters
#     new(1)
#   end

#   def self.name_already_exists
#     new(2)
#   end

#   def self.reason_16_eng_chars
#     new(3)
#   end

#   def self.incorrect_name
#     new(4)
#   end

#   def self.create_now_allowed
#     new(5)
#   end

#   def self.choose_another_svr
#     new(6)
#   end
# end


class Packets::Outgoing::CharCreateFail < GameServerPacket
  private initializer error: UInt8

  def write_impl
    c 0x10
    d @error
  end

  CREATION_FAILED     = new(0)
  TOO_MANY_CHARACTERS = new(1)
  NAME_ALREADY_EXISTS = new(2)
  REASON_16_ENG_CHARS = new(3)
  INCORRECT_NAME      = new(4)
  CREATE_NOW_ALLOWED  = new(5)
  CHOOSE_ANOTHER_SVR  = new(6)
end
