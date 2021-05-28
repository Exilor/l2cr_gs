class Scripts::Wedding < AbstractNpcAI
  # NPC
  private MANAGER_ID = 50007
  # Item
  private FORMAL_WEAR = 6408

  def initialize
    super(self.class.simple_name, "custom/events")

    add_first_talk_id(MANAGER_ID)
    add_talk_id(MANAGER_ID)
    add_start_npc(MANAGER_ID)
  end

  def on_adv_event(event, npc, player)
    player = player.not_nil!

    if player.partner_id == 0
      return "NoPartner.html"
    end

    partner = L2World.get_player(player.partner_id)
    if partner.nil? || !partner.online?
      return "NotFound.html"
    end

    if player.married?
      return "Already.html"
    end

    if player.marry_accepted?
      return "WaitForPartner.html"
    end

    if player.marry_request?
      if !wearing_formal_dress?(player) || !wearing_formal_dress?(partner)
        html = send_html(partner, "NoFormal.html", nil, nil)
      else
        player.marry_request = false
        partner.marry_request = false
        html = get_htm(player, "Ask.html")
        html = html.gsub("%player%", partner.name)
      end

      return html
    end

    case event
    when "ask"
      if !wearing_formal_dress?(player) || !wearing_formal_dress?(partner)
        html = send_html(partner, "NoFormal.html", nil, nil)
      else
        player.marry_accepted = true
        partner.marry_request = true

        send_html(partner, "Ask.html", "%player%", player.name)

        html = get_htm(player, "Requested.html")
        html = html.gsub("%player%", partner.name)
      end
    when "accept"
      if !wearing_formal_dress?(player) || !wearing_formal_dress?(partner)
        html = send_html(partner, "NoFormal.html", nil, nil)
      elsif player.adena < Config.wedding_price || partner.adena < Config.wedding_price
        html = send_html(partner, "Adena.html", "%fee%", Config.wedding_price)
      else
        player.reduce_adena("Wedding", Config.wedding_price, player.last_folk_npc, true)
        partner.reduce_adena("Wedding", Config.wedding_price, player.last_folk_npc, true)

        # Accept the wedding request
        player.marry_accepted = true
        couple = CoupleManager.get_couple(player.couple_id).not_nil!
        couple.marry

        # Messages to the couple
        player.send_message("Congratulations you are married!")
        player.married = true
        player.marry_request = false
        partner.send_message("Congratulations you are married!")
        partner.married = true
        partner.marry_request = false

        # Wedding march
        player.broadcast_packet(MagicSkillUse.new(player, player, 2230, 1, 1, 0))
        partner.broadcast_packet(MagicSkillUse.new(partner, partner, 2230, 1, 1, 0))

        if skill = CommonSkill::LARGE_FIREWORK.skill?
          player.do_cast(skill)
          partner.do_cast(skill)
        end

        Broadcast.to_all_online_players("Congratulations to #{player} and #{partner}! They have been married.")

        html = send_html(partner, "Accepted.html", nil, nil)
      end
    when "decline"
      player.marry_request = false
      partner.marry_request = false
      player.marry_accepted = false
      partner.marry_accepted = false

      player.send_message("You declined your partner's marriage request.")
      partner.send_message("Your partner declined your marriage request.")

      html = send_html(partner, "Declined.html", nil, nil)
    end

    html
  end

  def on_first_talk(npc, player)
    html = get_htm(player, "Start.html")
    html.gsub("%fee%", Config.wedding_price)
  end

  private def send_html(player, file_name, regex, replacement)
    html = get_htm(player, file_name)
    if regex && replacement
      html = html.gsub(regex, replacement)
    end
    player.send_packet(NpcHtmlMessage.new(html))
    html
  end

  private def wearing_formal_dress?(player)
    if Config.wedding_formalwear
      formal_wear = player.chest_armor_instance
      return !!formal_wear && formal_wear.id == FORMAL_WEAR
    end

    true
  end
end
