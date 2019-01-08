# abstract class Quests::AbstractSagaQuest < Quest
#     protected int[] _npc
#     protected int[] Items
#     protected int[] Mob
#     protected int[] classid
#     protected int[] prev_class
#     protected Location[] npcSpawnLocations
#     protected String[] Text
#     private SPAWN_LIST = {} of L2Npc => Int32
#     private QUEST_CLASSES = {
#       {0x7f}, {0x80, 0x81}, {0x82}, {0x05}, {0x14}, {0x15},
#       {0x02}, {0x03}, {0x2e}, {0x30}, {0x33}, {0x34}, {0x08},
#       {0x17}, {0x24}, {0x09}, {0x18}, {0x25}, {0x10}, {0x11},
#       {0x1e}, {0x0c}, {0x1b}, {0x28}, {0x0e}, {0x1c}, {0x29},
#       {0x0d}, {0x06}, {0x22}, {0x21}, {0x2b}, {0x37}, {0x39}
#     }

#     # def initialize(quest_id : Int32, name : String, descr : String)
#     #   super
#     # end

#     private def find_quest(L2PcInstance player)
#       st = get_quest_state(player, false)
#       if st)
#         if getId == 68)
#           for (int q = 0 q < 2 q++)
#             if player.class_id.id == QUEST_CLASSES[1][q])
#               return st
#           end
#           }
#       end
#         elsif player.class_id.id == QUEST_CLASSES[getId - 67][0])
#           return st
#       end
#     end
#       return
#     }

#     private findRightState(npc)
#       L2PcInstance player = nil
#       st = nil
#       if SPAWN_LIST.include?Key(npc))
#         player = L2World.player(SPAWN_LIST.get(npc))
#         if player)
#           st = player.get_quest_state(getName)
#       end
#     end
#       return st
#     }

#     private class_id(L2PcInstance player)
#       if player.class_id.id == 0x81)
#         return classid[1]
#     end
#       return classid[0]
#     }

#     private get_prev_class(L2PcInstance player)
#       if player.class_id.id == 0x81)
#         if prev_class.length == 1)
#           return -1
#       end
#         return prev_class[1]
#     end
#       return prev_class[0]
#     }

#     private void giveHalishaMark(QuestState st2)
#       if st2.get_int("spawned") == 0)
#         if st2.get_quest_items_count(Items[3]) >= 700)
#           st2.take_items(Items[3], 20)
#           xx = st2.player.x
#           yy = st2.player.y
#           zz = st2.player.z
#           L2Npc Archon = st2.add_spawn(Mob[1], xx, yy, zz)
#           add_spawn(st2, Archon)
#           st2.set("spawned", "1")
#           st2.start_quest_timer("Archon Hellisha has despawned", 600000, Archon)
#           autoChat(Archon, Text[13].replace("PLAYERNAME", st2.player.name))
#           ((L2Attackable) Archon).add_damage_hate(st2.player, 0, 99999i64)
#           Archon.set_intention(AI::ATTACK, st2.player, nil)
#         else
#           st2.give_items(Items[3], rand(1, 4))
#       end
#     end
#     }

#     def on_adv_event(event, npc, player)
#       st = get_quest_state(player, false)
#       htmltext = nil
#       if st)
#         case event)
#         when "0-011.htm":
#         when "0-012.htm":
#         when "0-013.htm":
#         when "0-014.htm":
#         when "0-015.htm":
#           htmltext = event
#           break
#         when "accept":
#           st.start_quest
#           give_items(player, Items[10], 1)
#           htmltext = "0-03.htm"
#           break
#         when "0-1":
#           if player.level < 76)
#             htmltext = "0-02.htm"
#             if st.created?)
#               st.exit_quest(true)
#             end
#           else
#             htmltext = "0-05.htm"
#           end
#           break
#         when "0-2":
#           if player.level < 76)
#             take_items(player, Items[10], -1)
#             st.set_cond(20, true)
#             htmltext = "0-08.htm"
#           else
#             take_items(player, Items[10], -1)
#             add_exp_and_sp(player, 2299404, 0)
#             give_adena(player, 5000000, true)
#             give_items(player, 6622, 1)
#             klass = class_id(player)
#             prev_class = get_prev_class(player)
#             player.class_id=(klass)
#             if !player.subclass_active? && (player.base_class == prev_class))
#               player.base_class=(klass)
#             end
#             player.broadcast_user_info
#             cast(npc, player, 4339, 1)
#             st.exit_quest(false)
#             htmltext = "0-07.htm"
#           end
#           break
#         when "1-3":
#           st.set_cond(3)
#           htmltext = "1-05.htm"
#           break
#         when "1-4":
#           st.set_cond(4)
#           take_items(player, Items[0], 1)
#           if Items[11] != 0)
#             take_items(player, Items[11], 1)
#           end
#           give_items(player, Items[1], 1)
#           htmltext = "1-06.htm"
#           break
#         when "2-1":
#           st.set_cond(2)
#           htmltext = "2-05.htm"
#           break
#         when "2-2":
#           st.set_cond(5)
#           take_items(player, Items[1], 1)
#           give_items(player, Items[4], 1)
#           htmltext = "2-06.htm"
#           break
#         when "3-5":
#           htmltext = "3-07.htm"
#           break
#         when "3-6":
#           st.set_cond(11)
#           htmltext = "3-02.htm"
#           break
#         when "3-7":
#           st.set_cond(12)
#           htmltext = "3-03.htm"
#           break
#         when "3-8":
#           st.set_cond(13)
#           take_items(player, Items[2], 1)
#           give_items(player, Items[7], 1)
#           htmltext = "3-08.htm"
#           break
#         when "4-1":
#           htmltext = "4-010.htm"
#           break
#         when "4-2":
#           give_items(player, Items[9], 1)
#           st.set_cond(18, true)
#           htmltext = "4-011.htm"
#           break
#         when "4-3":
#           give_items(player, Items[9], 1)
#           st.set_cond(18, true)
#           autoChat(npc, Text[13].replace("PLAYERNAME", player.name))
#           st.set("Quest0", "0")
#           cancel_quest_timer("Mob_2 has despawned", npc, player)
#           DeleteSpawn(st, npc)
#           return
#         when "5-1":
#           st.set_cond(6, true)
#           take_items(player, Items[4], 1)
#           cast(npc, player, 4546, 1)
#           htmltext = "5-02.htm"
#           break
#         when "6-1":
#           st.set_cond(8, true)
#           st.set("spawned", "0")
#           take_items(player, Items[5], 1)
#           cast(npc, player, 4546, 1)
#           htmltext = "6-03.htm"
#           break
#         when "7-1":
#           if st.get_int("spawned") == 1)
#             htmltext = "7-03.htm"
#           elsif st.get_int("spawned") == 0)
#             L2Npc Mob_1 = add_spawn(Mob[0], npcSpawnLocations[0], false, 0)
#             st.set("spawned", "1")
#             st.start_quest_timer("Mob_1 Timer 1", 500, Mob_1)
#             st.start_quest_timer("Mob_1 has despawned", 300000, Mob_1)
#             add_spawn(st, Mob_1)
#             htmltext = "7-02.htm"
#           else
#             htmltext = "7-04.htm"
#           end
#           break
#         when "7-2":
#           st.set_cond(10, true)
#           take_items(player, Items[6], 1)
#           cast(npc, player, 4546, 1)
#           htmltext = "7-06.htm"
#           break
#         when "8-1":
#           st.set_cond(14, true)
#           take_items(player, Items[7], 1)
#           cast(npc, player, 4546, 1)
#           htmltext = "8-02.htm"
#           break
#         when "9-1":
#           st.set_cond(17, true)
#           st.set("Quest0", "0")
#           st.set("Tab", "0")
#           take_items(player, Items[8], 1)
#           cast(npc, player, 4546, 1)
#           htmltext = "9-03.htm"
#           break
#         when "10-1":
#           if st.get_int("Quest0") == 0)
#             L2Npc Mob_3 = add_spawn(Mob[2], npcSpawnLocations[1], false, 0)
#             L2Npc Mob_2 = add_spawn(_npc[4], npcSpawnLocations[2], false, 0)
#             add_spawn(st, Mob_3)
#             add_spawn(st, Mob_2)
#             st.set("Mob_2", String.valueOf(Mob_2.l2id))
#             st.set("Quest0", "1")
#             st.set("Quest1", "45")
#             st.startRepeatingQuestTimer("Mob_3 Timer 1", 500, Mob_3)
#             st.start_quest_timer("Mob_3 has despawned", 59000, Mob_3)
#             st.start_quest_timer("Mob_2 Timer 1", 500, Mob_2)
#             st.start_quest_timer("Mob_2 has despawned", 60000, Mob_2)
#             htmltext = "10-02.htm"
#           elsif st.get_int("Quest1") == 45)
#             htmltext = "10-03.htm"
#           else
#             htmltext = "10-04.htm"
#           end
#           break
#         when "10-2":
#           st.set_cond(19, true)
#           take_items(player, Items[9], 1)
#           cast(npc, player, 4546, 1)
#           htmltext = "10-06.htm"
#           break
#         when "11-9":
#           st.set_cond(15)
#           htmltext = "11-03.htm"
#           break
#         when "Mob_1 Timer 1":
#           autoChat(npc, Text[0].replace("PLAYERNAME", player.name))
#           return
#         when "Mob_1 has despawned":
#           autoChat(npc, Text[1].replace("PLAYERNAME", player.name))
#           st.set("spawned", "0")
#           DeleteSpawn(st, npc)
#           return
#         when "Archon Hellisha has despawned":
#           autoChat(npc, Text[6].replace("PLAYERNAME", player.name))
#           st.set("spawned", "0")
#           DeleteSpawn(st, npc)
#           return
#         when "Mob_3 Timer 1":
#           L2Npc Mob_2 = FindSpawn(player, (L2Npc) L2World.findObject(st.get_int("Mob_2")))
#           if npc.known_list.knowsObject(Mob_2))
#             ((L2Attackable) npc).add_damage_hate(Mob_2, 0, 99999i64)
#             npc.set_intention(AI::ATTACK, Mob_2, nil)
#             Mob_2.set_intention(AI::ATTACK, npc, nil)
#             autoChat(npc, Text[14].replace("PLAYERNAME", player.name))
#             cancel_quest_timer("Mob_3 Timer 1", npc, player)
#           end
#           return
#         when "Mob_3 has despawned":
#           autoChat(npc, Text[15].replace("PLAYERNAME", player.name))
#           st.set("Quest0", "2")
#           DeleteSpawn(st, npc)
#           return
#         when "Mob_2 Timer 1":
#           autoChat(npc, Text[7].replace("PLAYERNAME", player.name))
#           st.start_quest_timer("Mob_2 Timer 2", 1500, npc)
#           if st.get_int("Quest1") == 45)
#             st.set("Quest1", "0")
#           end
#           return
#         when "Mob_2 Timer 2":
#           autoChat(npc, Text[8].replace("PLAYERNAME", player.name))
#           st.start_quest_timer("Mob_2 Timer 3", 10000, npc)
#           return
#         when "Mob_2 Timer 3":
#           if st.get_int("Quest0") == 0)
#             st.start_quest_timer("Mob_2 Timer 3", 13000, npc)
#             if Rnd.bool)
#               autoChat(npc, Text[9].replace("PLAYERNAME", player.name))
#             else
#               autoChat(npc, Text[10].replace("PLAYERNAME", player.name))
#             end
#           end
#           return
#         when "Mob_2 has despawned":
#           st.set("Quest1", String.valueOf(st.get_int("Quest1") + 1))
#           if (st.get_int("Quest0") == 1) || (st.get_int("Quest0") == 2) || (st.get_int("Quest1") > 3))
#             st.set("Quest0", "0")
#             # TODO this IF will never be true
#             if st.get_int("Quest0") == 1)
#               autoChat(npc, Text[11].replace("PLAYERNAME", player.name))
#             else
#               autoChat(npc, Text[12].replace("PLAYERNAME", player.name))
#             end
#             DeleteSpawn(st, npc)
#           else
#             st.start_quest_timer("Mob_2 has despawned", 1000, npc)
#           end
#           return
#       }
#     end
#     return htmltext
#   }

#   def on_attack(npc, player, damage, is_summon)
#     st2 = findRightState(npc)
#     if st2)
#       cond = st2.cond
#       st = get_quest_state(player, false)
#       npc_id = npc.id
#       if (npc_id == Mob[2]) && (st == st2) && (cond == 17))
#         quest0 = st.get_int("Quest0") + 1
#         if quest0 == 1)
#           autoChat(npc, Text[16].replace("PLAYERNAME", player.name))
#         end

#         if quest0 > 15)
#           quest0 = 1
#           autoChat(npc, Text[17].replace("PLAYERNAME", player.name))
#           cancel_quest_timer("Mob_3 has despawned", npc, st2.player)
#           st.set("Tab", "1")
#           DeleteSpawn(st, npc)
#         end

#         st.set("Quest0", Integer.toString(quest0))
#       elsif (npc_id == Mob[1]) && (cond == 15))
#         if (st != st2) || ((st == st2) && player.in_party?))
#           autoChat(npc, Text[5].replace("PLAYERNAME", player.name))
#           cancel_quest_timer("Archon Hellisha has despawned", npc, st2.player)
#           st2.set("spawned", "0")
#           DeleteSpawn(st2, npc)
#         end
#       end
#     end
#     return super
#   }

#   def on_first_talk(npc, player)
#     htmltext = ""
#     st = get_quest_state(player, false)
#     npc_id = npc.id
#     if st)
#       if npc_id == _npc[4])
#         cond = st.cond
#         if cond == 17)
#           st2 = findRightState(npc)
#           if st2)
#             player.setLastQuestNpcObject(npc.l2id)
#             tab = st.get_int("Tab")
#             quest0 = st.get_int("Quest0")

#             if st == st2)
#               if tab == 1)
#                 if quest0 == 0)
#                   htmltext = "4-04.htm"
#                 elsif quest0 == 1)
#                   htmltext = "4-06.htm"
#                 end
#               elsif quest0 == 0)
#                 htmltext = "4-01.htm"
#               elsif quest0 == 1)
#                 htmltext = "4-03.htm"
#               end
#             elsif tab == 1)
#               if quest0 == 0)
#                 htmltext = "4-05.htm"
#               elsif quest0 == 1)
#                 htmltext = "4-07.htm"
#               end
#             elsif quest0 == 0)
#               htmltext = "4-02.htm"
#             end
#           end
#         elsif cond == 18)
#           htmltext = "4-08.htm"
#         end
#       end
#     end
#     if htmltext == "")
#       npc.showChatWindow(player)
#     end
#     return htmltext
#   }

#   def on_kill(npc, player, is_summon)
#     npc_id = npc.id
#     st = get_quest_state(player, false)
#     for (int Archon_Minion = 21646 Archon_Minion < 21652 Archon_Minion++)
#       if npc_id == Archon_Minion)
#         L2Party party = player.getParty
#         if party)
#           List<QuestState> partyQuestMembers = []
#           for (L2PcInstance player1 : party.getMembers)
#             st1 = find_quest(player1)
#             if st1 && player1.inside_radius?(player, Config.alt_party_range2, false, false))
#               if st1.cond?(15))
#                 partyQuestMembers.pushst1
#               end
#             end
#           }
#           if partyQuestMembers.size > 0)
#             st2 = partyQuestMembers.get(rand(partyQuestMembers.size))
#             giveHalishaMark(st2)
#           end
#         else
#           st1 = find_quest(player)
#           if st1)
#             if st1.cond?(15))
#               giveHalishaMarkst1
#             end
#           end
#         end
#         return super
#       end
#     }

#     int[] Archon_Hellisha_Norm =
#       18212,
#       18214,
#       18215,
#       18216,
#       18218
#     }
#     for (int element : Archon_Hellisha_Norm)
#       if npc_id == element)
#         st1 = find_quest(player)
#         if st1)
#           if st1.cond?(15))
#             # This is just a guess....not really sure what it actually says, if anything
#             autoChat(npc, Text[4].replace("PLAYERNAME", st1.player.name))
#             st1.give_items(Items[8], 1)
#             st1.take_items(Items[3], -1)
#             st1.set_cond(16, true)
#           end
#         end
#         return super
#       end
#     }

#     for (int Guardian_Angel = 27214 Guardian_Angel < 27217 Guardian_Angel++)
#       if npc_id == Guardian_Angel)
#         st1 = find_quest(player)
#         if st1 && st1.cond?(6))
#           kills = st1.get_int("kills")
#           if kills < 9)
#             st1.set("kills", Integer.toString(kills + 1))
#           else
#             st1.give_items(Items[5], 1)
#             st.set_cond(7, true)
#           end
#         end
#         return super
#       end
#     }
#     if st && (npc_id != Mob[2]))
#       st2 = findRightState(npc)
#       if st2)
#         cond = st.cond
#         if (npc_id == Mob[0]) && (cond == 8))
#           if !player.in_party?)
#             if st == st2)
#               autoChat(npc, Text[12].replace("PLAYERNAME", player.name))
#               give_items(player, Items[6], 1)
#               st.set_cond(9, true)
#             end
#           end
#           cancel_quest_timer("Mob_1 has despawned", npc, st2.player)
#           st2.set("spawned", "0")
#           DeleteSpawn(st2, npc)
#         elsif (npc_id == Mob[1]) && (cond == 15))
#           if !player.in_party?)
#             if st == st2)
#               autoChat(npc, Text[4].replace("PLAYERNAME", player.name))
#               give_items(player, Items[8], 1)
#               take_items(player, Items[3], -1)
#               st.set_cond(16, true)
#             else
#               autoChat(npc, Text[5].replace("PLAYERNAME", player.name))
#             end
#           end
#           cancel_quest_timer("Archon Hellisha has despawned", npc, st2.player)
#           st2.set("spawned", "0")
#           DeleteSpawn(st2, npc)
#         end
#       end
#     elsif npc_id == Mob[0])
#       st = findRightState(npc)
#       if st)
#         cancel_quest_timer("Mob_1 has despawned", npc, st.player)
#         st.set("spawned", "0")
#         DeleteSpawn(st, npc)
#       end
#     elsif npc_id == Mob[1])
#       st = findRightState(npc)
#       if st)
#         cancel_quest_timer("Archon Hellisha has despawned", npc, st.player)
#         st.set("spawned", "0")
#         DeleteSpawn(st, npc)
#       end
#     end
#     return super
#   }

#   def on_skill_see(npc, player, skill skill, l2_object[] targets, is_summon)
#     if SPAWN_LIST.include?Key(npc) && (SPAWN_LIST.get(npc) != player.l2id))
#       L2PcInstance quest_player = (L2PcInstance) L2World.findObject(SPAWN_LIST.get(npc))
#       if quest_player.nil?)
#         return
#       end

#       for (L2Object obj : targets)
#         if (obj == quest_player) || (obj == npc))
#           st2 = findRightState(npc)
#           if st2.nil?)
#             return
#           end
#           autoChat(npc, Text[5].replace("PLAYERNAME", player.name))
#           cancel_quest_timer("Archon Hellisha has despawned", npc, st2.player)
#           st2.set("spawned", "0")
#           DeleteSpawn(st2, npc)
#         end
#       }
#     end
#     return super
#   }

#   def on_talk(npc, player)
#     htmltext = get_no_quest_msg(player)
#     st = get_quest_state(player, true)
#     npc_id = npc.id
#     if (npc_id == _npc[0]) && st.completed?)
#       htmltext = get_already_completed_msg(player)
#     elsif player.class_id.id == get_prev_class(player)
#         case st.cond
#         when 0: # check it's not really -1!
#           if npc_id == _npc[0])
#             htmltext = "0-01.htm"
#           end
#           break
#         when 1:
#           if npc_id == _npc[0])
#             htmltext = "0-04.htm"
#           elsif npc_id == _npc[2])
#             htmltext = "2-01.htm"
#           end
#           break
#         when 2:
#           if npc_id == _npc[2])
#             htmltext = "2-02.htm"
#           elsif npc_id == _npc[1])
#             htmltext = "1-01.htm"
#           end
#           break
#         when 3:
#           if (npc_id == _npc[1]) && has_quest_items?(player, Items[0]))
#             if (Items[11] == 0) || has_quest_items?(player, Items[11]))
#               htmltext = "1-03.htm"
#             else
#               htmltext = "1-02.htm"
#             end
#           end
#           break
#         when 4:
#           if npc_id == _npc[1])
#             htmltext = "1-04.htm"
#           elsif npc_id == _npc[2])
#             htmltext = "2-03.htm"
#           end
#           break
#         when 5:
#           if npc_id == _npc[2])
#             htmltext = "2-04.htm"
#           elsif npc_id == _npc[5])
#             htmltext = "5-01.htm"
#           end
#           break
#         when 6:
#           if npc_id == _npc[5])
#             htmltext = "5-03.htm"
#           elsif npc_id == _npc[6])
#             htmltext = "6-01.htm"
#           end
#           break
#         when 7:
#           if npc_id == _npc[6])
#             htmltext = "6-02.htm"
#           end
#           break
#         when 8:
#           if npc_id == _npc[6])
#             htmltext = "6-04.htm"
#           elsif npc_id == _npc[7])
#             htmltext = "7-01.htm"
#           end
#           break
#         when 9:
#           if npc_id == _npc[7])
#             htmltext = "7-05.htm"
#           end
#           break
#         when 10:
#           if npc_id == _npc[7])
#             htmltext = "7-07.htm"
#           elsif npc_id == _npc[3])
#             htmltext = "3-01.htm"
#           end
#           break
#         when 11:
#         when 12:
#           if npc_id == _npc[3])
#             if has_quest_items?(player, Items[2]))
#               htmltext = "3-05.htm"
#             else
#               htmltext = "3-04.htm"
#             end
#           end
#           break
#         when 13:
#           if npc_id == _npc[3])
#             htmltext = "3-06.htm"
#           elsif npc_id == _npc[8])
#             htmltext = "8-01.htm"
#           end
#           break
#         when 14:
#           if npc_id == _npc[8])
#             htmltext = "8-03.htm"
#           elsif npc_id == _npc[11])
#             htmltext = "11-01.htm"
#           end
#           break
#         when 15:
#           if npc_id == _npc[11])
#             htmltext = "11-02.htm"
#           elsif npc_id == _npc[9])
#             htmltext = "9-01.htm"
#           end
#           break
#         when 16:
#           if npc_id == _npc[9])
#             htmltext = "9-02.htm"
#           end
#           break
#         when 17:
#           if npc_id == _npc[9])
#             htmltext = "9-04.htm"
#           elsif npc_id == _npc[10])
#             htmltext = "10-01.htm"
#           end
#           break
#         when 18:
#           if npc_id == _npc[10])
#             htmltext = "10-05.htm"
#           end
#           break
#         when 19:
#           if npc_id == _npc[10])
#             htmltext = "10-07.htm"
#           elsif npc_id == _npc[0])
#             htmltext = "0-06.htm"
#           end
#           break
#         when 20:
#           if npc_id == _npc[0])
#             if player.level >= 76)
#               htmltext = "0-09.htm"
#               if (class_id(player) < 131) || (class_id(player) > 135)) # in Kamael quests, npc wants to chat for a bit before changing class
#                 st.exit_quest(false)
#                 add_exp_and_sp(player, 2299404, 0)
#                 give_adena(player, 5000000, true)
#                 give_items(player, 6622, 1) # XXX rewardItems?
#                 classId = class_id(player)
#                 prev_class = get_prev_class(player)
#                 player.class_id=(classId)
#                 if !player.subclass_active? && (player.base_class == prev_class))
#                   player.base_class=(classId)
#                 end
#                 player.broadcast_user_info
#                 cast(npc, player, 4339, 1)
#               end
#             else
#               htmltext = "0-010.htm"
#             end
#           end
#           break
#       }
#     end
#     return htmltext
#   }

#   public void registerNPCs
#     add_start_npc(_npc[0])
#     add_attack_id(Mob[2], Mob[1])
#     add_skill_see_id(Mob[1])
#     add_first_talk_id(_npc[4])
#     add_talk_id(_npc)
#     add_kill_id(Mob)
#     final int[] questItemIds = Items.clone
#     questItemIds[0] = 0
#     questItemIds[2] = 0 # remove Ice Crystal and Divine Stone of Wisdom
#     register_quest_items(questItemIds)
#     for (int Archon_Minion = 21646 Archon_Minion < 21652 Archon_Minion++)
#       add_kill_id(Archon_Minion)
#     }
#     int[] Archon_Hellisha_Norm =
#       18212,
#       18214,
#       18215,
#       18216,
#       18218
#     }
#     add_kill_id(Archon_Hellisha_Norm)
#     for (int Guardian_Angel = 27214 Guardian_Angel < 27217 Guardian_Angel++)
#       add_kill_id(Guardian_Angel)
#     }
#   }

#   def self.add_spawn(QuestState st, L2Npc mob)
#     SPAWN_LIST.put(mob, st.player.l2id)
#   }

#   def self.autoChat(npc, String text)
#     npc.broadcast_packet(NpcSay.new(npc.l2id, 0, npc.id, text))
#   }

#   def self.cast(npc, L2Character target, skillId, level)
#     target.broadcast_packet(new MagicSkillUse(target, target, skillId, level, 6000, 1))
#     target.broadcast_packet(new MagicSkillUse(npc, npc, skillId, level, 6000, 1))
#   }

#   def self.DeleteSpawn(QuestState st, npc)
#     if SPAWN_LIST.include?Key(npc))
#       SPAWN_LIST.remove(npc)
#       npc.delete_me
#     end
#   }

#   private static L2Npc FindSpawn(L2PcInstance player, npc)
#     if SPAWN_LIST.include?Key(npc) && (SPAWN_LIST.get(npc) == player.l2id))
#       return npc
#     end
#     return
#   }
# }
