class Packets::Outgoing::PlaySound < GameServerPacket
  def sound_name
    @sound_file
  end

  def self.create_sound(name : String) : self
    new(name)
  end

  def self.create_sound(name : String, obj : L2Object?) : self
    new(name, obj)
  end

  def self.create_music(name : String) : self
    create_music(name, 0)
  end

  def self.create_music(name : String, delay : Int32) : self
    new(1, name, delay)
  end

  def self.create_voice(name : String) : self
    create_voice(name, 0)
  end

  def self.create_voice(name : String, delay : Int32)
    new(2, name, delay)
  end

  def initialize(@sound_file : String)
    @type = 0
    @bind_to_object = 0
    @l2id = 0
    @loc_x = 0
    @loc_y = 0
    @loc_z = 0
    @delay = 0
  end

  def initialize(@sound_file : String, obj : L2Object?)
    @type = 0
    if obj
      @bind_to_object = 1
      @l2id = obj.l2id
      @loc_x = obj.x
      @loc_y = obj.y
      @loc_z = obj.z
    else
      @bind_to_object = 0
      @l2id = 0
      @loc_x = 0
      @loc_y = 0
      @loc_z = 0
    end
    @delay = 0
  end

  def initialize(@type : Int32, @sound_file : String, @delay : Int32)
    @bind_to_object = 0
    @l2id = 0
    @loc_x = 0
    @loc_y = 0
    @loc_z = 0
  end

  def write_impl
    c 0x9e

    d @type
    s @sound_file
    d @bind_to_object
    d @l2id
    d @loc_x
    d @loc_y
    d @loc_z
    d @delay
  end
end
