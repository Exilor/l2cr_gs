# class Scripts::TvTManagerScript < AbstractNpcAI
#   include IVoicedCommandHandler

#   private MANAGER_ID = 70010
#   private COMMANDS = {
#     "tvt",
#     "tvtjoin",
#     "tvtleave"
#   }

#   def initialize
#     super(self.class.simple_name, "custom/events/TvT")

#     add_first_talk_id(MANAGER_ID)
#     add_talk_id(MANAGER_ID)
#     add_start_npc(MANAGER_ID)

#     if Config.tvt_allow_voiced_command
#       VoicedCommandHandler.register(self)
#     end
#   end

#   def on_adv_event(event, npc, pc)
#     if pc.nil? || !TvTEvent.participating?
#       return super
#     end

#     case event
#     when "join"
#       lvl = pc.level
#       team1_count = TvTEvent.teams_player_counts[0]
#       team2_count = TvTEvent.teams_player_counts[1]
#       if pc.cursed_weapon_equipped?
#         html = get_htm(pc, "CursedWeaponEquipped.html")
#       elsif OlympiadManager.registered?(pc)
#         html = get_htm(player, "Olympiad.html")
#       elsif pc.karma > 0
#         html = get_htm(pc, "Karma.html")
#       elsif !lvl.between?(Config.tvt_event_min_lvl, Config.tvt_event_max_lvl)
#         html = get_htm(pc, "Level.html")
#         html = html.gsub("%min%", Config.tvt_event_min_lvl.to_s)
#         html = html.gsub("%max%", Config.tvt_event_max_lvl.to_s)
#       elsif team1_count == Config.tvt_event_max_players_in_teams && team2_count == Config.tvt_event_max_players_in_teams
#         html = get_htm(pc, "TeamsFull.html")
#         html = html.gsub("%max%", Config.tvt_event_max_players_in_teams)
#       elsif Config.tvt_event_max_participants_per_ip > 0 && !AntiFeedManager.try_add_player(AntiFeedManager::TVT_ID, pc, Config.tvt_event_max_participants_per_ip)
#         html = get_htm(pc, "IPRestriction.html")
#         html = html.gsub("%max%", (AntiFeedManager.get_limit(pc, Config.tvt_event_max_participants_per_ip)).to_s)
#       elsif TvTEvent.needs_participation_fee? && !TvTEvent.has_participation_fee?(pc)
#         html = get_htm(pc, "ParticipationFee.html")
#         html = html.gsub("%fee%", TvTEvent.participation_fee)
#       elsif TvTEvent.add_participant(pc)
#         html = get_htm(pc, "Registered.html")
#       end
#     when "remove"
#       if TvTEvent.remove_participant(pc.l2id)
#         if Config.tvt_event_max_participants_per_ip > 0
#           AntiFeedManager.remove_player(AntiFeedManager::TVT_ID, pc)
#         end
#         html = get_htm(pc, "Unregistered.html")
#       else
#         pc.send_message("You cannot unregister to this event.")
#       end
#     else
#       # nothing
#     end

#     html
#   end

#   def on_first_talk(npc, pc)
#     if TvTEvent.participating?
#       is_participant = TvTEvent.get_player_participant(pc.l2id)
#       teams_player_counts = TvTEvent.teams_player_counts
#       if is_participant
#         html = "Participation.html"
#       else
#         html = "RemoveParticipation.html"
#       end
#       html = html.gsub("%objectId%", npc.l2id.to_s)
#       html = html.gsub("%team1name%", Config.tvt_event_team_1_name)
#       html = html.gsub("%team1playercount%", teams_player_counts[0].to_s)
#       html = html.gsub("%team2name%", Config.tvt_event_team_2_name)
#       html = html.gsub("%team2playercount%", teams_player_counts[1].to_s)
#       html = html.gsub("%playercount%", (teams_player_counts[0] + teams_player_counts[1]).to_s)

#       unless is_participant
#         html = html.gsub("%fee%", TvTEvent.participation_fee
#       end
#     elsif TvTEvent.starting? || TvTEvent.started?
#       html = get_tvt_status(pc)
#     end

#     html
#   end

#   def use_voiced_command(command : String, pc : L2PcInstance, params : String) : Bool
#     case command
#     when "tvt"
#       if TvTEvent.starting? || TvTEvent.started?
#         html = get_tvt_status(pc)
#       else
#         html = "The event has not started."
#       end
#     when "tvtjoin"
#       html = on_adv_event("join", nil, pc)
#     when "tvtleave"
#       html = on_adv_event("remove", nil, pc)
#     else
#       # nothing
#     end

#     if html
#       pc.send_packet(NpcHtmlMessage.new(html))
#     end

#     true
#   end

#   def commands : Enumerable(String)
#     COMMANDS
#   end

#   private def get_tvt_status(pc)
#     teams_player_counts = TvTEvent.teams_player_counts
#     teams_points_counts = TvTEvent.teams_points
#     html = get_htm(pc, "Status.html")
#     html = html.gsub("%team1name%", Config.tvt_event_team_1_name)
#     html = html.gsub("%team1playercount%", teams_player_counts[0].to_s)
#     html = html.gsub("%team1points%", teams_points_counts[0].to_s)
#     html = html.gsub("%team2name%", Config.tvt_event_team_2_name)
#     html = html.gsub("%team2playercount%", teams_player_counts[1].to_s)
#     html.gsub("%team2points%", teams_points_counts[1].to_s)
#   end
# end
