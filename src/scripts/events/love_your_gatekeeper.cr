class Scripts::LoveYourGatekeeper < LongTimeEvent
  # NPC
  private GATEKEEPER = 32477
  # Item
  private GATEKEEPER_TRANSFORMATION_STICK = 12814
  # Skills
  private TELEPORTER_TRANSFORM = SkillHolder.new(5655)
  # Misc
  private HOURS = 24
  private PRICE = 10000
  private REUSE = simple_name + "_reuse"

  def initialize
    super(self.class.simple_name, "events")

    add_start_npc(GATEKEEPER)
    add_first_talk_id(GATEKEEPER)
    add_talk_id(GATEKEEPER)
  end

  def on_adv_event(event, npc, pc)
    pc = pc.not_nil!

    case event
    when "transform_stick"
      if pc.adena >= PRICE
        reuse = pc.variables.get_i64(REUSE, 0)
        if reuse > Time.ms
          remaining_time = (reuse - Time.ms) // 1000
          hours = (remaining_time // 3600).to_i32
          minutes = ((remaining_time % 3600) // 60).to_i32
          sm = SystemMessage.available_after_s1_s2_hours_s3_minutes
          sm.add_item_name(GATEKEEPER_TRANSFORMATION_STICK)
          sm.add_int(hours)
          sm.add_int(minutes)
          pc.send_packet(sm)
        else
          take_items(pc, Inventory::ADENA_ID, PRICE)
          give_items(pc, GATEKEEPER_TRANSFORMATION_STICK, 1)
          pc.variables[REUSE] = Time.ms + (HOURS * 3_600_000)
        end
      else
        return "32477-3.htm"
      end

      return
    when "transform"
      unless pc.transformed?
        pc.do_cast(TELEPORTER_TRANSFORM)
      end

      return
    end

    event
  end

  def on_first_talk(npc, pc)
    return "32477.htm"
  end
end
