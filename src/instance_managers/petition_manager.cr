require "../models/petition"

module PetitionManager
  extend self
  extend Loggable
  include Packets::Outgoing

  private alias Say2 = Packets::Incoming::Say2

  private PENDING_PETITIONS = {} of Int32 => Petition
  private COMPLETED_PETITIONS = {} of Int32 => Petition

  def clear_completed_petitions
    num = pending_petition_count

    completed_petitions.clear
    info { "Completed petition data cleared. #{num} petition(s) removed." }
  end

  def clear_pending_petitions
    num = pending_petition_count

    pending_petitions.clear
    info { "Pending petition queue cleared. #{num} petition(s) removed." }
  end

  def accept_petition(admin : L2PcInstance, petition_id : Int32)
    unless valid_petition?(petition_id)
      return false
    end

    cur_pt = pending_petitions[petition_id]

    if cur_pt.responder?
      return false
    end

    cur_pt.responder = admin
    cur_pt.state = PetitionState::IN_PROCESS

    # Petition application accepted. (Send to Petitioner)
    cur_pt.send_petitioner_packet(SystemMessage.petition_app_accepted)

    # Petition application accepted. Reciept No. is <ID>
    sm = SystemMessage.petition_accepted_recent_no_s1
    sm.add_int(cur_pt.id)
    cur_pt.send_responder_packet(sm)

    # Petition consultation with <Player> underway.
    sm = SystemMessage.starting_petition_with_c1
    sm.add_string(cur_pt.petitioner.name)
    cur_pt.send_responder_packet(sm)

    # Set responder name on petitioner instance
    cur_pt.petitioner.last_petition_gm_name = cur_pt.responder.name
    true
  end

  def cancel_active_petition(pc : L2PcInstance) : Bool
    pending_petitions.each_value do |cur_pt|
      if cur_pt.petitioner? && cur_pt.petitioner.l2id == pc.l2id
        return cur_pt.end_petition_consultation(PetitionState::PETITIONER_CANCEL)
      end

      if cur_pt.responder? && cur_pt.responder.l2id == pc.l2id
        return cur_pt.end_petition_consultation(PetitionState::RESPONDER_CANCEL)
      end
    end

    false
  end

  def check_petition_messages(petitioner : L2PcInstance)
    pending_petitions.each_value do |cur_pt|
      if cur_pt.petitioner? && cur_pt.petitioner.l2id == petitioner.l2id
        cur_pt.log_messages.each do |msg|
          petitioner.send_packet(msg)
        end

        return
      end
    end
  end

  def end_active_petition(pc : L2PcInstance) : Bool
    unless pc.gm?
      return false
    end

    pending_petitions.each_value do |cur_pt|
      if cur_pt.responder? && cur_pt.responder.l2id == pc.l2id
        return cur_pt.end_petition_consultation(PetitionState::COMPLETED)
      end
    end

    false
  end

  def completed_petitions : Hash(Int32, Petition)
    COMPLETED_PETITIONS
  end

  def pending_petitions : Hash(Int32, Petition)
    PENDING_PETITIONS
  end

  def pending_petition_count : Int32
    pending_petitions.size
  end

  def get_player_total_petition_count(pc : L2PcInstance) : Int32
    count = 0

    pending_petitions.each_value do |cur_pt|
      if cur_pt.petitioner? && cur_pt.petitioner.l2id == pc.l2id
        count &+= 1
      end
    end

    completed_petitions.each_value do |cur_pt|
      if cur_pt.petitioner? && cur_pt.petitioner.l2id == pc.l2id
        count &+= 1
      end
    end

    count
  end

  def petition_in_process? : Bool
    pending_petitions.local_each_value.any? &.state.in_process?
  end

  def petition_in_process?(petition_id : Int32) : Bool
    unless valid_petition?(petition_id)
      return false
    end

    cur_pt = pending_petitions[petition_id]
    cur_pt.state.in_process?
  end

  def player_in_consultation?(pc : L2PcInstance) : Bool
    pending_petitions.each_value do |cur_pt|
      unless cur_pt.state.in_process?
        next
      end

      if (cur_pt.petitioner? && cur_pt.petitioner.l2id == pc.l2id) || (cur_pt.responder? && cur_pt.responder.l2id == pc.l2id)
        return true
      end
    end

    false
  end

  def petitioning_allowed? : Bool
    Config.petitioning_allowed
  end

  def player_petition_pending?(petitioner : L2PcInstance) : Bool
    pending_petitions.each_value do |cur_pt|
      if cur_pt.petitioner? && cur_pt.petitioner.l2id == petitioner.l2id
        return true
      end
    end

    false
  end

  private def valid_petition?(petition_id : Int32) : Bool
    pending_petitions.has_key?(petition_id)
  end

  def reject_petition(admin : L2PcInstance, petition_id : Int32) : Bool
    unless valid_petition?(petition_id)
      return false
    end

    cur_pt = pending_petitions[petition_id]

    if cur_pt.responder?
      return false
    end

    cur_pt.responder = admin
    cur_pt.end_petition_consultation(PetitionState::RESPONDER_REJECT)
  end

  def send_active_petition_message(player, text : String)
    # if !player_in_consultation?(player))
    # return false

    pending_petitions.each_value do |cur_pt|
      if cur_pt.petitioner? && cur_pt.petitioner.l2id == player.l2id
        cs = CreatureSay.new(player.l2id, Say2::PETITION_PLAYER, player.name, text)
        cur_pt.add_log_message(cs)

        cur_pt.send_responder_packet(cs)
        cur_pt.send_petitioner_packet(cs)
        return true
      end

      if cur_pt.responder? && cur_pt.responder.l2id == player.l2id
        cs = CreatureSay.new(player.l2id, Say2::PETITION_GM, player.name, text)
        cur_pt.add_log_message(cs)

        cur_pt.send_responder_packet(cs)
        cur_pt.send_petitioner_packet(cs)
        return true
      end
    end

    false
  end

  def send_pending_petition_list(pc : L2PcInstance)
    content = String.build(600 + (pending_petition_count * 300)) do |io|
      io << "<html><body><center><table width=270><tr>" \
        "<td width=45><button value=\"Main\" action=\"bypass -h admin_admin\" width=45 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td>" \
        "<td width=180><center>Petition Menu</center></td>" \
        "<td width=45><button value=\"Back\" action=\"bypass -h admin_admin7\" width=45 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td></tr></table><br>" \
        "<table width=\"270\">" \
        "<tr><td><table width=\"270\"><tr><td><button value=\"Reset\" action=\"bypass -h admin_reset_petitions\" width=\"80\" height=\"21\" back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td>" \
        "<td align=right><button value=\"Refresh\" action=\"bypass -h admin_view_petitions\" width=\"80\" height=\"21\" back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td></tr></table><br></td></tr>"

      date_format = "%Y-%m-%d %H:%m"

      if pending_petition_count == 0
        io << "<tr><td>There are no currently pending petitions.</td></tr>"
      else
        io << "<tr><td><font color=\"LEVEL\">Current Petitions:</font><br></td></tr>"
      end

      color = true
      count = 0
      pending_petitions.each_value do |cur_pt|
        io << "<tr><td width=\"270\"><table width=\"270\" cellpadding=\"2\" bgcolor="
        io << (color ? "131210" : "444444")
        io << "><tr><td width=\"130\">"
        Time.from_ms(cur_pt.submit_time).to_s(date_format, io)
        io << "</td><td width=\"140\" align=right><font color=\""
        io << (cur_pt.petitioner.online? ? "00FF00" : "999999")
        io << "\">"
        io << cur_pt.petitioner.name
        io << "</font></td></tr><tr><td width=\"130\">"
        if cur_pt.state.in_process?
          io << "<font color=\""
          io << (cur_pt.responder.online? ? "00FF00" : "999999")
          io << "\">"
          io << cur_pt.responder.name
          io << "</font>"
        else
          io << "<table width=\"130\" cellpadding=\"2\"><tr><td><button value=\"View\" action=\"bypass -h admin_view_petition "
          io << cur_pt.id
          io << "\" width=\"50\" height=\"21\" back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td><td><button value=\"Reject\" action=\"bypass -h admin_reject_petition "
          io << cur_pt.id
          io << "\" width=\"50\" height=\"21\" back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td></tr></table>"
        end
        io << "</td>"
        io << cur_pt.type_as_string
        io << "<td width=\"140\" align=right>"
        io << cur_pt.type_as_string
        io << "</td></tr></table></td></tr>"
        color = !color
        count &+= 1
        if count > 10
          io << "<tr><td><font color=\"LEVEL\">There is more pending petition...</font><br></td></tr>"
          break
        end
      end

      io << "</table></center></body></html>"
    end

    html = NpcHtmlMessage.new
    html.html = content
    pc.send_packet(html)
  end

  def submit_petition(pc : L2PcInstance, text : String, type : Int32) : Int32
    # Create a new petition instance and add it to the list of pending petitions.
    new_petition = Petition.new(pc, text, type)
    new_petition_id = new_petition.id
    pending_petitions[new_petition_id] = new_petition

    # Notify all GMs that a new petition has been submitted.
    content = "#{pc.name} has submitted a new petition."
    cs = CreatureSay.new(pc.l2id, Say2::HERO_VOICE, "Petition System", content)
    AdminData.broadcast_to_gms(cs)

    new_petition_id
  end

  def view_petition(pc : L2PcInstance, petition_id : Int32)
    unless pc.gm?
      return
    end

    unless valid_petition?(petition_id)
      return
    end

    cur_pt = pending_petitions[petition_id]
    date_format = "%Y-%m-%d %H:%m"

    html = NpcHtmlMessage.new
    html.set_file(pc, "data/html/admin/petition.htm")
    html["%petition%"] = cur_pt.id
    html["%time%"] = Time.from_ms(cur_pt.submit_time).to_s(date_format)
    html["%type%"] = cur_pt.type_as_string
    html["%petitioner%"] = cur_pt.petitioner.name
    html["%online%"] = (cur_pt.petitioner.online? ? "00FF00" : "999999")
    html["%text%"] = cur_pt.content

    pc.send_packet(html)
  end
end
