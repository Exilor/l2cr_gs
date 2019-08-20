class Scripts::WeaverOlf < AbstractNpcAI
  # NPCs
  private NPCs = {
    32610, # Olf Kanore
    32612  # Olf Adams
  }

  private UNSEAL_PRICE = {
    3200,
    11800,
    26500,
    136600
  }

  private CHANCES = {
    1,  # top
    10, # high
    40, # mid
    100 # low
  }

  private PINS = {
    {
      13898, # Sealed Magic Pin (C-Grade)
      13905, # Top-Grade Magic Pin (C-Grade)
      13904, # High-Grade Magic Pin (C-Grade)
      13903, # Mid-Grade Magic Pin (C-Grade)
      13902  # Low-Grade Magic Pin (C-Grade)
    },
    {
      13899, # Sealed Magic Pin (B-Grade)
      13909, # Top-Grade Magic Pin (B-Grade)
      13908, # High-Grade Magic Pin (B-Grade)
      13907, # Mid-Grade Magic Pin (B-Grade)
      13906  # Low-Grade Magic Pin (B-Grade)
    },
    {
      13900, # Sealed Magic Pin (A-Grade)
      13913, # Top-Grade Magic Pin (A-Grade)
      13912, # High-Grade Magic Pin (A-Grade)
      13911, # Mid-Grade Magic Pin (A-Grade)
      13910  # Low-Grade Magic Pin (A-Grade)
    },
    {
      13901, # Sealed Magic Pin (S-Grade)
      13917, # Top-Grade Magic Pin (S-Grade)
      13916, # High-Grade Magic Pin (S-Grade)
      13915, # Mid-Grade Magic Pin (S-Grade)
      13914  # Low-Grade Magic Pin (S-Grade)
    }
  }

  private POUCHS = {
    {
      13918, # Sealed Magic Pouch (C-Grade)
      13925, # Top-Grade Magic Pouch (C-Grade)
      13924, # High-Grade Magic Pouch (C-Grade)
      13923, # Mid-Grade Magic Pouch (C-Grade)
      13922  # Low-Grade Magic Pouch (C-Grade)
    },
    {
      13919, # Sealed Magic Pouch (B-Grade)
      13929, # Top-Grade Magic Pouch (B-Grade)
      13928, # High-Grade Magic Pouch (B-Grade)
      13927, # Mid-Grade Magic Pouch (B-Grade)
      13926  # Low-Grade Magic Pouch (B-Grade)
    },
    {
      13920, # Sealed Magic Pouch (A-Grade)
      13933, # Top-Grade Magic Pouch (A-Grade)
      13932, # High-Grade Magic Pouch (A-Grade)
      13931, # Mid-Grade Magic Pouch (A-Grade)
      13930  # Low-Grade Magic Pouch (A-Grade)
    },
    {
      13921, # Sealed Magic Pouch (S-Grade)
      13937, # Top-Grade Magic Pouch (S-Grade)
      13936, # High-Grade Magic Pouch (S-Grade)
      13935, # Mid-Grade Magic Pouch (S-Grade)
      13934  # Low-Grade Magic Pouch (S-Grade)
    }
  }

  private CLIPS_ORNAMENTS = {
    {
      14902, # Sealed Magic Rune Clip (A-Grade)
      14909, # Top-level Magic Rune Clip (A-Grade)
      14908, # High-level Magic Rune Clip (A-Grade)
      14907, # Mid-level Magic Rune Clip (A-Grade)
      14906  # Low-level Magic Rune Clip (A-Grade)
    },
    {
      14903, # Sealed Magic Rune Clip (S-Grade)
      14913, # Top-level Magic Rune Clip (S-Grade)
      14912, # High-level Magic Rune Clip (S-Grade)
      14911, # Mid-level Magic Rune Clip (S-Grade)
      14910  # Low-level Magic Rune Clip (S-Grade)
    },
    {
      14904, # Sealed Magic Ornament (A-Grade)
      14917, # Top-grade Magic Ornament (A-Grade)
      14916, # High-grade Magic Ornament (A-Grade)
      14915, # Mid-grade Magic Ornament (A-Grade)
      14914  # Low-grade Magic Ornament (A-Grade)
    },
    {
      14905, # Sealed Magic Ornament (S-Grade)
      14921, # Top-grade Magic Ornament (S-Grade)
      14920, # High-grade Magic Ornament (S-Grade)
      14919, # Mid-grade Magic Ornament (S-Grade)
      14918  # Low-grade Magic Ornament (S-Grade)
    }
  }

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(NPCs)
    add_talk_id(NPCs)
  end

  def on_adv_event(event, npc, pc)
    return unless npc && pc

    if event.includes?("_grade_")
      grade = event[0].to_i
      if event.ends_with?("_pin")
        price = UNSEAL_PRICE[grade]
        item_ids = PINS[grade]
      elsif event.ends_with?("_pouch")
        price = UNSEAL_PRICE[grade]
        item_ids = POUCHS[grade]
      elsif event.ends_with?("_clip")
        price = UNSEAL_PRICE[grade]
        item_ids = CLIPS_ORNAMENTS[grade - 2]
      elsif event.ends_with?("_ornament")
        price = UNSEAL_PRICE[grade]
        item_ids = CLIPS_ORNAMENTS[grade]
      else
        return super
      end

      if has_quest_items?(pc, item_ids[0])
        if pc.adena > price
          take_items(pc, Inventory::ADENA_ID, price)
          take_items(pc, item_ids[0], 1)
          rand = rand(200)
          if rand <= CHANCES[0]
            give_items(pc, item_ids[1], 1)
          elsif rand <= CHANCES[1]
            give_items(pc, item_ids[2], 1)
          elsif rand <= CHANCES[2]
            give_items(pc, item_ids[3], 1)
          elsif rand <= CHANCES[3]
            give_items(pc, item_ids[4], 1)
          else
            npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::WHAT_A_PREDICAMENT_MY_ATTEMPTS_WERE_UNSUCCESSFUL))
          end
        else
          return "#{npc.id}-low.htm"
        end
      else
        return "#{npc.id}-no.htm"
      end
      return super
    end

    event
  end

  def on_talk(npc, pc)
    return "#{npc.id}-1.htm"
  end
end
