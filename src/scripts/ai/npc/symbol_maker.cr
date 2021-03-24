class Scripts::SymbolMaker < AbstractNpcAI
  private NPCS = {
    31046, # Marsden
    31047, # Kell
    31048, # McDermott
    31049, # Pepper
    31050, # Thora
    31051, # Keach
    31052, # Heid
    31053, # Kidder
    31264, # Olsun
    31308, # Achim
    31953  # Rankar
  }

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_first_talk_id(NPCS)
    add_start_npc(NPCS)
    add_talk_id(NPCS)
  end

  def on_adv_event(event, npc, pc)
    return unless pc

    case event
    when /\Asymbol_maker(?:-[123])?\.htm\z/
      return event
    when "Draw"
      pc.send_packet(HennaEquipList.new(pc))
    when "Remove"
      pc.send_packet(HennaRemoveList.new(pc))
    end

    nil
  end

  def on_first_talk(npc, pc)
    "symbol_maker.htm"
  end
end
