class NpcAI::FirstClassTransferTalk < AbstractNpcAI
  def initialize
    super(self.class.simple_name, "ai/npc/VillageMasters")

    @MASTERS = {
      30026 => Race::HUMAN,    # Blitz, TI Fighter Guild Head Master
      30031 => Race::HUMAN,    # Biotin, TI Einhasad Temple High Priest
      30154 => Race::ELF,      # Asterios, Elven Village Tetrarch
      30358 => Race::DARK_ELF, # Thifiell, Dark Elf Village Tetrarch
      30565 => Race::ORC,      # Kakai, Orc Village Flame Lord
      30520 => Race::DWARF,    # Reed, Dwarven Village Warehouse Chief
      30525 => Race::DWARF,    # Bronk, Dwarven Village Head Blacksmith
      # Kamael Village NPCs
      32171 => Race::DWARF,    # Hoffa, Warehouse Chief
      32158 => Race::DWARF,    # Fisler, Dwarf Guild Warehouse Chief
      32157 => Race::DWARF,    # Moka, Dwarf Guild Head Blacksmith
      32160 => Race::DARK_ELF, # Devon, Dark Elf Guild Grand Magister
      32147 => Race::ELF,      # Rivian, Elf Guild Grand Master
      32150 => Race::ORC,      # Took, Orc Guild High Prefect
      32153 => Race::HUMAN,    # Prana, Human Guild High Priest
      32154 => Race::HUMAN,    # Aldenia, Human Guild Grand Master
    }

    add_start_npc(@MASTERS.keys)
    add_talk_id(@MASTERS.keys)
  end

  def on_adv_event(event, *args)
    event
  end

  def on_talk(npc, pc)
    if @MASTERS[npc.id] == pc.race
      htmltext = "#{npc.id}_"
    else
      return "#{npc.id}_no.html"
    end

    case @MASTERS[npc.id]
    when Race::HUMAN
      case pc.class_id.level
      when 0
        if pc.mage_class?
          if npc.is_a?(L2VillageMasterPriestInstance)
            htmltext += "mystic.html"
          else # custom: maybe it"s an error on L2J"s part that this is missing
            htmltext += "no.html"
          end
        else
          if npc.is_a?(L2VillageMasterFighterInstance)
            htmltext += "fighter.html"
          else # custom: maybe it"s an error on L2J"s part that this is missing
            htmltext += "no.html"
          end
        end
      when 1
        htmltext += "transfer_1.html"
      else
        htmltext += "transfer_2.html"
      end
    when Race::ELF, Race::DARK_ELF, Race::ORC
      case pc.class_id.level
      when 0
        htmltext += (pc.mage_class? ? "mystic.html" : "fighter.html")
      when 1
        htmltext += "transfer_1.html"
      else
        htmltext += "transfer_2.html"
      end
    when Race::DWARF
      case pc.class_id.level
      when 0
        htmltext += "fighter.html"
      when 1
        htmltext += "transfer_1.html"
      else
        htmltext += "transfer_2.html"
      end
    else
      htmltext += "no.html"
    end

    htmltext
  end
end
