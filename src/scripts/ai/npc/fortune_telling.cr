class Scripts::FortuneTelling < AbstractNpcAI
  private MINE = 32616
  private COST = 1000

  def initialize
    super(self.class.simple_name, "gracia/AI/NPC")

    add_start_npc(MINE)
    add_talk_id(MINE)
  end

  def on_talk(npc, pc)
    if pc.adena < COST
      "lowadena.htm"
    else
      take_items(pc, Inventory::ADENA_ID, COST)
      get_htm(pc, "fortune.htm").sub("%fortune%", Rnd.rand(1800309..1800695).to_s)
    end
  end
end
