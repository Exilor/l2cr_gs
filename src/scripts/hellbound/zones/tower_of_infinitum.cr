class NpcAI::TowerOfInfinitum < AbstractNpcAI
  # NPCs
  private JERIAN = 32302
  private GK_FIRST = 32745
  private GK_LAST = 32752
  # Skills
  private PASS_SKILL = 2357
  # Misc
  private TELE_COORDS = {
    32745 => [
      Location.new(-22208, 277122, -13376),
      nil
    ] of Location?,
    32746 => [
      Location.new(-22208, 277106, -11648),
      Location.new(-22208, 277074, -15040)
    ] of Location?,
    32747 => [
      Location.new(-22208, 277120, -9920),
      Location.new(-22208, 277120, -13376)
    ] of Location?,
    32748 => [
      Location.new(-19024, 277126, -8256),
      Location.new(-22208, 277106, -11648)
    ] of Location?,
    32749 => [
      Location.new(-19024, 277106, -9920),
      Location.new(-22208, 277122, -9920)
    ] of Location?,
    32750 => [
      Location.new(-19008, 277100, -11648),
      Location.new(-19024, 277122, -8256)
    ] of Location?,
    32751 => [
      Location.new(-19008, 277100, -13376),
      Location.new(-19008, 277106, -9920)
    ] of Location?,
    32752 => [
      Location.new(14602, 283179, -7500),
      Location.new(-19008, 277100, -11648)
    ] of Location?
  }
  private ENTER_LOCATION = Location.new(-22204, 277056, -15023)

  def initialize
    super(self.class.simple_name, "hellbound/AI/Zones")

    add_start_npc(JERIAN)
    add_talk_id(JERIAN)

    GK_FIRST.upto(GK_LAST) do |i|
      add_start_npc(i)
      add_talk_id(i)
    end
  end

  def on_adv_event(event, npc, pc)
    htmltext = event
    npc = npc.not_nil!
    pc = pc.not_nil!
    npc_id = npc.id

    if event.casecmp?("enter") && npc_id == JERIAN
      if HellboundEngine.level >= 11
        party = pc.party?
        if party && party.leader_l2id == pc.l2id
          party.members.each do |m|
            if !Util.in_range?(300, m, npc, true) || !m.affected_by_skill?(PASS_SKILL)
              return "32302-02.htm"
            end
          end
          party.members.each do |m|
            m.tele_to_location(ENTER_LOCATION, true)
          end
          htmltext = nil
        else
          htmltext = "32302-02a.htm"
        end
      else
        htmltext = "32302-02b.htm"
      end
    elsif (event.casecmp?("up") || event.casecmp?("down")) && npc_id >= GK_FIRST && npc_id <= GK_LAST
      direction = event.casecmp?("up") ? 0 : 1
      party = pc.party?

      if party.nil?
        htmltext = "gk-noparty.htm"
      elsif !party.leader?(pc)
        htmltext = "gk-noreq.htm"
      else
        party.members.each do |m|
          if !Util.in_range?(1000, m, npc, false) || (m.z - npc.z).abs > 100
            return "gk-noreq.htm"
          end
        end


        if tele = TELE_COORDS.dig?(npc_id, direction)
          party.members.each do |m|
            m.tele_to_location(tele, true)
          end
        end
        htmltext = nil
      end
    end

    htmltext
  end
end
