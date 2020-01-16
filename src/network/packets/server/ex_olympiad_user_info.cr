class Packets::Outgoing::ExOlympiadUserInfo < GameServerPacket
  @cur_hp = 0
  @max_hp = 100
  @cur_cp = 0
  @max_cp = 100

  @pc : L2PcInstance?
  @par : Participant?

  def initialize(pc : L2PcInstance?)
    @pc = pc

    if pc
      @cur_hp = pc.current_hp.to_i
      @max_hp = pc.max_hp
      @cur_cp = pc.current_cp.to_i
      @max_cp = pc.max_cp
    end
  end

  def initialize(par : Participant)
    @par = par
    pc = par.player?
    @pc = pc

    if pc
      @cur_hp = pc.current_hp.to_i
      @max_hp = pc.max_hp
      @cur_cp = pc.current_cp.to_i
      @max_cp = pc.max_cp
    end
  end

  private def write_impl
    c 0xfe
    h 0x7a

    if pc = @pc
      c pc.olympiad_side
      d pc.l2id
      s pc.name
      d pc.class_id.to_i
    else
      par = @par.not_nil!
      c par.side
      d par.l2id
      s par.name
      d par.base_class
    end

    d @cur_hp
    d @max_hp
    d @cur_cp
    d @max_cp
  end
end
