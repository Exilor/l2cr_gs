require "./i_audio"

class Sound < EnumClass
  include IAudio

  getter packet : PlaySound

  protected def initialize(name)
    @packet = PlaySound.create_sound(name)
  end

  def sound_name : String
    @packet.sound_name
  end

  def with_object(obj : L2Object) : PlaySound
    PlaySound.create_sound(sound_name, obj)
  end

  add(ITEMSOUND_QUEST_ACCEPT, "ItemSound.quest_accept")
  add(ITEMSOUND_QUEST_MIDDLE, "ItemSound.quest_middle")
  add(ITEMSOUND_QUEST_FINISH, "ItemSound.quest_finish")
  add(ITEMSOUND_QUEST_ITEMGET, "ItemSound.quest_itemget")
  add(ITEMSOUND_QUEST_TUTORIAL, "ItemSound.quest_tutorial")
  add(ITEMSOUND_QUEST_GIVEUP, "ItemSound.quest_giveup")
  add(ITEMSOUND_QUEST_BEFORE_BATTLE, "ItemSound.quest_before_battle")
  add(ITEMSOUND_QUEST_JACKPOT, "ItemSound.quest_jackpot")
  add(ITEMSOUND_QUEST_FANFARE_1, "ItemSound.quest_fanfare_1")
  add(ITEMSOUND_QUEST_FANFARE_2, "ItemSound.quest_fanfare_2")
  add(ITEMSOUND_QUEST_FANFARE_MIDDLE, "ItemSound.quest_fanfare_middle")
  add(ITEMSOUND_ARMOR_WOOD, "ItemSound.armor_wood_3")
  add(ITEMSOUND_ARMOR_CLOTH, "ItemSound.item_drop_equip_armor_cloth")
  add(AMDSOUND_ED_CHIMES, "AmdSound.ed_chimes_05")
  add(HORROR_01, "horror_01")
  add(AMBSOUND_HORROR_01, "AmbSound.dd_horror_01")
  add(AMBSOUND_HORROR_03, "AmbSound.d_horror_03")
  add(AMBSOUND_HORROR_15, "AmbSound.d_horror_15")
  add(ITEMSOUND_ARMOR_LEATHER, "ItemSound.itemdrop_armor_leather")
  add(ITEMSOUND_WEAPON_SPEAR, "ItemSound.itemdrop_weapon_spear")
  add(AMBSOUND_MT_CREAK, "AmbSound.mt_creak01")
  add(AMBSOUND_EG_DRON, "AmbSound.eg_dron_02")
  add(SKILLSOUND_HORROR_02, "SkillSound5.horror_02")
  add(CHRSOUND_MHFIGHTER_CRY, "ChrSound.MHFighter_cry")
  add(AMDSOUND_WIND_LOOT, "AmdSound.d_wind_loot_02")
  add(INTERFACESOUND_CHARSTAT_OPEN, "InterfaceSound.charstat_open_01")
  add(AMDSOUND_HORROR_02, "AmdSound.dd_horror_02")
  add(CHRSOUND_FDELF_CRY, "ChrSound.FDElf_Cry")
  add(AMBSOUND_WINGFLAP, "AmbSound.t_wingflap_04")
  add(AMBSOUND_THUNDER, "AmbSound.thunder_02")
  add(AMBSOUND_DRONE, "AmbSound.ed_drone_02")
  add(AMBSOUND_CRYSTAL_LOOP, "AmbSound.cd_crystal_loop")
  add(AMBSOUND_PERCUSSION_01, "AmbSound.dt_percussion_01")
  add(AMBSOUND_PERCUSSION_02, "AmbSound.ac_percussion_02")
  add(ITEMSOUND_BROKEN_KEY, "ItemSound2.broken_key")
  add(ITEMSOUND_SIREN, "ItemSound3.sys_siren")
  add(ITEMSOUND_ENCHANT_SUCCESS, "ItemSound3.sys_enchant_success")
  add(ITEMSOUND_ENCHANT_FAILED, "ItemSound3.sys_enchant_failed")
  add(ITEMSOUND_SOW_SUCCESS, "ItemSound3.sys_sow_success")
  add(SKILLSOUND_HORROR_1, "SkillSound5.horror_01")
  add(SKILLSOUND_HORROR_2, "SkillSound5.horror_02")
  add(SKILLSOUND_ANTARAS_FEAR, "SkillSound3.antaras_fear")
  add(SKILLSOUND_JEWEL_CELEBRATE, "SkillSound2.jewel.celebrate")
  add(SKILLSOUND_LIQUID_MIX, "SkillSound5.liquid_mix_01")
  add(SKILLSOUND_LIQUID_SUCCESS, "SkillSound5.liquid_success_01")
  add(SKILLSOUND_LIQUID_FAIL, "SkillSound5.liquid_fail_01")
  add(ETCSOUND_ELROKI_SONG_FULL, "EtcSound.elcroki_song_full")
  add(ETCSOUND_ELROKI_SONG_1ST, "EtcSound.elcroki_song_1st")
  add(ETCSOUND_ELROKI_SONG_2ND, "EtcSound.elcroki_song_2nd")
  add(ETCSOUND_ELROKI_SONG_3RD, "EtcSound.elcroki_song_3rd")
  add(ITEMSOUND2_RACE_START, "ItemSound2.race_start")
  add(ITEMSOUND_SHIP_ARRIVAL_DEPARTURE, "itemsound.ship_arrival_departure")
  add(ITEMSOUND_SHIP_5MIN, "itemsound.ship_5min")
  add(ITEMSOUND_SHIP_1MIN, "itemsound.ship_1min")
end
