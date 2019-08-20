module AdminCommandHandler::AdminFightCalculator
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    begin
      if command.starts_with?("admin_fight_calculator_show")
        handle_show(command.from("admin_fight_calculator_show".size), pc)
      elsif command.starts_with?("admin_fcs")
        handle_show(command.from("admin_fcs".size), pc)
      elsif command.starts_with?("admin_fight_calculator")
        handle_start(command.from("admin_fight_calculator".size), pc)
      end
    rescue e
      warn e
    end

    true
  end

  private def handle_start(params, pc)
    st = params.split
    lvl1 = 0
    lvl2 = 0
    mid1 = 0
    mid2 = 0
    until st.empty?
      s = st.shift
      if s == "lvl1"
        lvl1 = st.shift.to_i
        next
      end
      if s == "lvl2"
        lvl2 = st.shift.to_i
        next
      end
      if s == "mid1"
        mid1 = st.shift.to_i
        next
      end
      if s == "mid2"
        mid2 = st.shift.to_i
        next
      end
    end

    if mid1 != 0
      npc1 = NpcData[mid1]?
    end
    if mid2 != 0
      npc2 = NpcData[mid2]?
    end

    admin_reply = Packets::Outgoing::NpcHtmlMessage.new

    if npc1 && npc2
      reply_msg = String.build do |io|
        io << "<html><title>Selected mobs to fight</title>"
        io << "<body>"
        io << "<table>"
        io << "<tr><td>First</td><td>Second</td></tr>"
        io << "<tr><td>level "
        io << lvl1
        io << "</td><td>level "
        io << lvl2
        io << "</td></tr>"
        io << "<tr><td>id "
        io << npc1.id
        io << "</td><td>id "
        io << npc2.id
        io << "</td></tr>"
        io << "<tr><td>"
        io << npc1.name
        io << "</td><td>"
        io << npc2.name
        io << "</td></tr>"
        io << "</table>"
        io << "<center><br><br><br>"
        io << "<button value=\"OK\" action=\"bypass -h admin_fight_calculator_show "
        io << npc1.id
        io << " "
        io << npc2.id
        io << "\"  width=100 height=15 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\">"
        io << "</center>"
        io << "</body></html>"
      end
    elsif lvl1 != 0 && npc1.nil?
      npcs = NpcData.get_all_of_level(lvl1)
      reply_msg = String.build(50 + (npcs.size * 200)) do |io|
        io << "<html><title>Select first mob to fight</title>"
        io << "<body><table>"

        npcs.each do |n|
          io << "<tr><td><a action=\"bypass -h admin_fight_calculator lvl1 "
          io << lvl1
          io << " lvl2 "
          io << lvl2
          io << " mid1 "
          io << n.id
          io << " mid2 "
          io << mid2
          io << "\">"
          io << n.name
          io << "</a></td></tr>"
        end

        io << "</table></body></html>"
      end
    elsif lvl2 != 0 && npc2.nil?
      npcs = NpcData.get_all_of_level(lvl2)
      reply_msg = String.build(50 + (npcs.size * 200)) do |io|
        io << "<html><title>Select second mob to fight</title>"
        io << "<body><table>"

        npcs.each do |n|
          io << "<tr><td><a action=\"bypass -h admin_fight_calculator lvl1 "
          io << lvl1
          io << " lvl2 "
          io << lvl2
          io << " mid1 "
          io << mid1
          io << " mid2 "
          io << n.id
          io << "\">"
          io << n.name
          io << "</a></td></tr>"
        end

        io << "</table></body></html>"
      end
    else
      reply_msg = String.build do |io|
        io << "<html><title>Select mobs to fight</title>"
        io << "<body>"
        io << "<table>"
        io << "<tr><td>First</td><td>Second</td></tr>"
        io << "<tr><td><edit var=\"lvl1\" width=80></td><td><edit var=\"lvl2\" width=80></td></tr>"
        io << "</table>"
        io << "<center><br><br><br>"
        io << "<button value=\"OK\" action=\"bypass -h admin_fight_calculator lvl1 $lvl1 lvl2 $lvl2\"  width=100 height=15 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\">"
        io << "</center>"
        io << "</body></html>"
      end
    end

    admin_reply.html = reply_msg
    pc.send_packet(admin_reply)
  end

  private def handle_show(params, pc)
    params = params.strip

    if params.size == 0
      npc1 = pc
      unless npc2 = pc.target.as?(L2Character)
        pc.send_packet(SystemMessageId::INCORRECT_TARGET)
        return
      end
    else
      mid1 = 0
      mid2 = 0
      st = params.split
      mid1 = st.shift.to_i
      mid2 = st.shift.to_i

      npc1 = L2MonsterInstance.new(NpcData[mid1])
      npc2 = L2MonsterInstance.new(NpcData[mid2])
    end

    miss1 = 0
    miss2 = 0
    shld1 = 0
    shld2 = 0
    crit1 = 0
    crit2 = 0
    patk1 : Float64 = 0.0
    patk2 : Float64 = 0.0
    pdef1 : Float64 = 0.0
    pdef2 : Float64 = 0.0
    dmg1 : Float64 = 0.0
    dmg2 : Float64 = 0.0

    satk1 = npc1.calculate_time_between_attacks
    satk2 = npc2.calculate_time_between_attacks

    satk1 = 100000 // satk1
    satk2 = 100000 // satk2

    10000.times do |i|
      _miss1 = Formulas.hit_miss(npc1, npc2)
      if _miss1
        miss1 += 1
      end
      _shld1 = Formulas.shld_use(npc1, npc2, nil, false)
      if _shld1 > 0
        shld1 += 1
      end
      _crit1 = Formulas.crit(npc1, npc2)
      if _crit1
        crit1 += 1
      end

      _patk1 = npc1.get_p_atk(npc2)
      _patk1 += npc1.random_damage_multiplier
      patk1 += _patk1

      _pdef1 = npc1.get_p_def(npc2)
      pdef1 += _pdef1

      unless _miss1
        _dmg1 = Formulas.phys_dam(npc1, npc2, _shld1, _crit1, false)
        dmg1 += _dmg1
        npc1.abort_attack
      end
    end

    10000.times do |i|
      _miss2 = Formulas.hit_miss(npc2, npc1)
      if _miss2
        miss2 += 1
      end
      _shld2 = Formulas.shld_use(npc2, npc1, nil, false)
      if _shld2 > 0
        shld2 += 1
      end
      _crit2 = Formulas.crit(npc2, npc1)
      if _crit2
        crit2 += 1
      end

      _patk2 = npc2.get_p_atk(npc1)
      _patk2 *= npc2.random_damage_multiplier
      patk2 += _patk2

      _pdef2 = npc2.get_p_def(npc1)
      pdef2 += _pdef2

      unless _miss2
        _dmg2 = Formulas.phys_dam(npc2, npc1, _shld2, _crit2, false)
        dmg2 += _dmg2
        npc2.abort_attack
      end
    end

    miss1 /= 100
    miss2 /= 100
    shld1 /= 100
    shld2 /= 100
    crit1 /= 100
    crit2 /= 100
    patk1 /= 10000
    patk2 /= 10000
    pdef1 /= 10000
    pdef2 /= 10000
    dmg1 /= 10000
    dmg2 /= 10000

    # total damage per 100 seconds
    tdmg1 = (satk1 * dmg1).to_i
    tdmg2 = (satk2 * dmg2).to_i
    # HP restored per 100 seconds
    maxhp1 = npc1.max_hp
    hp1 = ((Formulas.hp_regen(npc1) * 100000) / Formulas.get_regenerate_period(npc1)).to_i

    maxhp2 = npc2.max_hp
    hp2 = ((Formulas.hp_regen(npc2) * 100000) / Formulas.get_regenerate_period(npc2)).to_i

    admin_reply = Packets::Outgoing::NpcHtmlMessage.new

    reply_msg = String.build(1000) do |io|
      io << "<html><title>Selected mobs to fight</title>"
      io << "<body>"
      io << "<table>"

      if params.size == 0
        io << "<tr><td width=140>Parameter</td><td width=70>me</td><td width=70>target</td></tr>"
      else
        io << "<tr><td width=140>Parameter</td><td width=70>"
        io << npc1.template.as(L2NpcTemplate).name
        io << "</td><td width=70>"
        io << npc2.template.as(L2NpcTemplate).name
        io << "</td></tr>"
      end

      io << "<tr><td>miss</td><td>"
      io << miss1
      io << "%</td><td>"
      io << miss2
      io << "%</td></tr>"
      io << "<tr><td>shld</td><td>"
      io << shld2
      io << "%</td><td>"
      io << shld1
      io << "%</td></tr>"
      io << "<tr><td>crit</td><td>"
      io << crit1
      io << "%</td><td>"
      io << crit2
      io << "%</td></tr>"
      io << "<tr><td>pAtk / pDef</td><td>"
      io << patk1.to_i
      io << " / "
      io << pdef1.to_i
      io << "</td><td>"
      io << patk2.to_i
      io << " / "
      io << pdef2.to_i
      io << "</td></tr>"
      io << "<tr><td>made hits</td><td>"
      io << satk1
      io << "</td><td>"
      io << satk2
      io << "</td></tr>"
      io << "<tr><td>dmg per hit</td><td>"
      io << dmg1.to_i
      io << "</td><td>"
      io << dmg2.to_i
      io << "</td></tr>"
      io << "<tr><td>got dmg</td><td>"
      io << tdmg2
      io << "</td><td>"
      io << tdmg1
      io << "</td></tr>"
      io << "<tr><td>got regen</td><td>"
      io << hp1
      io << "</td><td>"
      io << hp2
      io << "</td></tr>"
      io << "<tr><td>had HP</td><td>"
      io << maxhp1.to_i
      io << "</td><td>"
      io << maxhp2.to_i
      io << "</td></tr>"
      io << "<tr><td>die</td>"

      if tdmg2 - hp1 > 1
        io << "<td>"
        io << ((100 * maxhp1) / (tdmg2 - hp1)).to_i
        io << " sec</td>"
      else
        io << "<td>never</td>"
      end

      if tdmg1 - hp2 > 1
        io << "<td>"
        io << ((100 * maxhp2) / (tdmg1 - hp2)).to_i
        io << " sec</td>"
      else
        io << "<td>never</td>"
      end

      io << "</tr>"
      io << "</table>"
      io << "<center><br>"

      if params.size == 0
        io << "<button value=\"Retry\" action=\"bypass -h admin_fight_calculator_show\"  width=100 height=15 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\">"
      else
        io << "<button value=\"Retry\" action=\"bypass -h admin_fight_calculator_show "
        io << npc1.template.as(L2NpcTemplate).id
        io << " "
        io << npc2.template.as(L2NpcTemplate).id
        io << "\"  width=100 height=15 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\">"
      end

      io << "</center>"
      io << "</body></html>"
    end
    admin_reply.html = reply_msg
    pc.send_packet(admin_reply)

    if params.size != 0
      npc1.as(L2MonsterInstance).delete_me
      npc2.as(L2MonsterInstance).delete_me
    end
  end

  def commands
    {
      "admin_fight_calculator",
      "admin_fight_calculator_show",
      "admin_fcs"
    }
  end
end
