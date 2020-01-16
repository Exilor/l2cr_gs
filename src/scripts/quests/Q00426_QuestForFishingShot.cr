class Scripts::Q00426_QuestForFishingShot < Quest
  private record ChanceReward, chance : Int32, reward : Int32

  private NPC = {
    31562, # Klufe
    31563, # Perelin
    31564, # Mishini
    31565, # Ogord
    31566, # Ropfi
    31567, # Bleaker
    31568, # Pamfus
    31569, # Cyano
    31570, # Lanosco
    31571, # Hufs
    31572, # O'Fulle
    31573, # Monakan
    31574, # Willie
    31575, # Litulon
    31576, # Berix
    31577, # Linnaeus
    31578, # Hilgendorf
    31579, # Klaus
    31696, # Platis
    31697, # Eindarkner
    31989, # Batidae
    32007, # Galba
    32348  # Burang
  }
  private MOBS = {
    20005 => ChanceReward.new(45, 1), # Imp Elder
    20013 => ChanceReward.new(100, 1), # Dryad
    20016 => ChanceReward.new(100, 1), # Stone Golem
    20017 => ChanceReward.new(115, 1), # Vuku Orc Fighter
    20030 => ChanceReward.new(105, 1), # Langk Lizardman
    20132 => ChanceReward.new(70, 1), # Werewolf
    20038 => ChanceReward.new(135, 1), # Venomous Spider
    20044 => ChanceReward.new(125, 1), # Lirein Elder
    20046 => ChanceReward.new(100, 1), # Stink Zombie
    20047 => ChanceReward.new(100, 1), # Sukar Wererat Leader
    20050 => ChanceReward.new(140, 1), # Arachnid Predator
    20058 => ChanceReward.new(140, 1), # Ol Mahum Guard
    20063 => ChanceReward.new(160, 1), # Ol Mahum Shooter
    20066 => ChanceReward.new(170, 1), # Ol Mahum Captain
    20070 => ChanceReward.new(180, 1), # Lesser Basilisk
    20074 => ChanceReward.new(195, 1), # Androscorpio
    20077 => ChanceReward.new(205, 1), # Androscorpio Hunter
    20078 => ChanceReward.new(205, 1), # Whispering Wind
    20079 => ChanceReward.new(205, 1), # Ant
    20080 => ChanceReward.new(220, 1), # Ant Captain
    20081 => ChanceReward.new(370, 1), # Ant Overseer
    20083 => ChanceReward.new(245, 1), # Granite Golem
    20084 => ChanceReward.new(255, 1), # Ant Patrol
    20085 => ChanceReward.new(265, 1), # Puncher
    20087 => ChanceReward.new(565, 1), # Ant Soldier
    20088 => ChanceReward.new(605, 1), # Ant Warrior Captain
    20089 => ChanceReward.new(250, 1), # Noble Ant
    20100 => ChanceReward.new(85, 1), # Skeleton Archer
    20103 => ChanceReward.new(110, 1), # Giant Spider
    20105 => ChanceReward.new(110, 1), # Dark Horror
    20115 => ChanceReward.new(190, 1), # Undine Noble
    20120 => ChanceReward.new(20, 1), # Wolf
    20131 => ChanceReward.new(45, 1), # Orc Grunt
    20135 => ChanceReward.new(360, 1), # Alligator
    20157 => ChanceReward.new(235, 1), # Marsh Stakato
    20162 => ChanceReward.new(195, 1), # Ogre
    20176 => ChanceReward.new(280, 1), # Wyrm
    20211 => ChanceReward.new(170, 1), # Ol Mahum Captain
    20225 => ChanceReward.new(160, 1), # Giant Mist Leech
    20227 => ChanceReward.new(180, 1), # Horror Mist Ripper
    20230 => ChanceReward.new(260, 1), # Marsh Stakato Worker
    20232 => ChanceReward.new(245, 1), # Marsh Stakato Soldier
    20234 => ChanceReward.new(290, 1), # Marsh Stakato Drone
    20241 => ChanceReward.new(700, 1), # Hunter Gargoyle
    20267 => ChanceReward.new(215, 1), # Breka Orc
    20268 => ChanceReward.new(295, 1), # Breka Orc Archer
    20269 => ChanceReward.new(255, 1), # Breka Orc Shaman
    20270 => ChanceReward.new(365, 1), # Breka Orc Overlord
    20271 => ChanceReward.new(295, 1), # Breka Orc Warrior
    20286 => ChanceReward.new(700, 1), # Hunter Gargoyle
    20308 => ChanceReward.new(110, 1), # Hook Spider
    20312 => ChanceReward.new(45, 1), # Rakeclaw Imp Hunter
    20317 => ChanceReward.new(20, 1), # Black Wolf
    20324 => ChanceReward.new(85, 1), # Goblin Brigand Lieutenant
    20333 => ChanceReward.new(100, 1), # Greystone Golem
    20341 => ChanceReward.new(100, 1), # Undead Slave
    20346 => ChanceReward.new(85, 1), # Darkstone Golem
    20349 => ChanceReward.new(850, 1), # Cave Bat
    20356 => ChanceReward.new(165, 1), # Langk Lizardman Leader
    20357 => ChanceReward.new(140, 1), # Langk Lizardman Lieutenant
    20363 => ChanceReward.new(70, 1), # Maraku Werewolf
    20368 => ChanceReward.new(85, 1), # Grave Keeper
    20371 => ChanceReward.new(100, 1), # Mist Terror
    20386 => ChanceReward.new(85, 1), # Balor Orc Fighter
    20389 => ChanceReward.new(90, 1), # Boogle Ratman
    20403 => ChanceReward.new(110, 1), # Hunter Tarantula
    20404 => ChanceReward.new(95, 1), # Silent Horror
    20433 => ChanceReward.new(100, 1), # Festering Bat
    20436 => ChanceReward.new(140, 1), # Ol Mahum Supplier
    20448 => ChanceReward.new(45, 1), # Utuku Orc Grunt
    20456 => ChanceReward.new(20, 1), # Ashen Wolf
    20463 => ChanceReward.new(85, 1), # Dungeon Skeleton Archer
    20470 => ChanceReward.new(45, 1), # Kaboo Orc Grunt
    20471 => ChanceReward.new(85, 1), # Kaboo Orc Fighter
    20475 => ChanceReward.new(20, 1), # Kasha Wolf
    20478 => ChanceReward.new(110, 1), # Kasha Blade Spider
    20487 => ChanceReward.new(90, 1), # Kuruka Ratman
    20511 => ChanceReward.new(100, 1), # Pitchstone Golem
    20525 => ChanceReward.new(20, 1), # Gray Wolf
    20528 => ChanceReward.new(100, 1), # Goblin Lord
    20536 => ChanceReward.new(15, 1), # Elder Brown Keltir
    20537 => ChanceReward.new(15, 1), # Elder Red Keltir
    20538 => ChanceReward.new(15, 1), # Elder Prairie Keltir
    20539 => ChanceReward.new(15, 1), # Elder Longtail Keltir
    20544 => ChanceReward.new(15, 1), # Elder Keltir
    20550 => ChanceReward.new(300, 1), # Guardian Basilisk
    20551 => ChanceReward.new(300, 1), # Road Scavenger
    20552 => ChanceReward.new(650, 1), # Fettered Soul
    20553 => ChanceReward.new(335, 1), # Windsus
    20554 => ChanceReward.new(390, 1), # Grandis
    20555 => ChanceReward.new(350, 1), # Giant Fungus
    20557 => ChanceReward.new(390, 1), # Dire Wyrm
    20559 => ChanceReward.new(420, 1), # Rotting Golem
    20560 => ChanceReward.new(440, 1), # Trisalim Spider
    20562 => ChanceReward.new(485, 1), # Spore Zombie
    20573 => ChanceReward.new(545, 1), # Tarlk Basilisk
    20575 => ChanceReward.new(645, 1), # Oel Mahum Warrior
    20630 => ChanceReward.new(350, 1), # Taik Orc
    20632 => ChanceReward.new(475, 1), # Taik Orc Warrior
    20634 => ChanceReward.new(960, 1), # Taik Orc Captain
    20636 => ChanceReward.new(495, 1), # Forest of Mirrors Ghost
    20638 => ChanceReward.new(540, 1), # Forest of Mirrors Ghost
    20641 => ChanceReward.new(680, 1), # Harit Lizardman Grunt
    20643 => ChanceReward.new(660, 1), # Harit Lizardman Warrior
    20644 => ChanceReward.new(645, 1), # Harit Lizardman Shaman
    20659 => ChanceReward.new(440, 1), # Grave Wanderer
    20661 => ChanceReward.new(575, 1), # Hatar Ratman Thief
    20663 => ChanceReward.new(525, 1), # Hatar Hanishee
    20665 => ChanceReward.new(680, 1), # Taik Orc Supply
    20667 => ChanceReward.new(730, 1), # Farcran
    20766 => ChanceReward.new(210, 1), # Scout of the Plains
    20781 => ChanceReward.new(270, 1), # Delu Lizardman Shaman
    20783 => ChanceReward.new(140, 1), # Dread Wolf
    20784 => ChanceReward.new(155, 1), # Tasaba Lizardman
    20786 => ChanceReward.new(170, 1), # Lienrik
    20788 => ChanceReward.new(325, 1), # Rakul
    20790 => ChanceReward.new(390, 1), # Dailaon
    20792 => ChanceReward.new(620, 1), # Farhite
    20794 => ChanceReward.new(635, 1), # Blade Stakato
    20796 => ChanceReward.new(640, 1), # Blade Stakato Warrior
    20798 => ChanceReward.new(850, 1), # Water Giant
    20800 => ChanceReward.new(740, 1), # Eva's Seeker
    20802 => ChanceReward.new(900, 1), # Theeder Mage
    20804 => ChanceReward.new(775, 1), # Crokian Lad
    20806 => ChanceReward.new(805, 1), # Crokian Lad Warrior
    20833 => ChanceReward.new(455, 1), # Zaken's Archer
    20834 => ChanceReward.new(680, 1), # Mardian
    20836 => ChanceReward.new(785, 1), # Pirate Zombie
    20837 => ChanceReward.new(835, 1), # Tainted Ogre
    20839 => ChanceReward.new(430, 1), # Unpleasant Humming
    20841 => ChanceReward.new(460, 1), # Fiend Archer
    20845 => ChanceReward.new(605, 1), # Pirate Zombie Captain
    20847 => ChanceReward.new(570, 1), # Veil Master
    20849 => ChanceReward.new(585, 1), # Light Worm
    20936 => ChanceReward.new(290, 1), # Tanor Silenos
    20937 => ChanceReward.new(315, 1), # Tanor Silenos Grunt
    20939 => ChanceReward.new(385, 1), # Tanor Silenos Warrior
    20940 => ChanceReward.new(500, 1), # Tanor Silenos Shaman
    20941 => ChanceReward.new(460, 1), # Tanor Silenos Chieftain
    20943 => ChanceReward.new(345, 1), # Nightmare Keeper
    20944 => ChanceReward.new(335, 1), # Nightmare Lord
    21100 => ChanceReward.new(125, 1), # Langk Lizardman Sentinel
    21101 => ChanceReward.new(155, 1), # Langk Lizardman Shaman
    21103 => ChanceReward.new(215, 1), # Roughly Hewn Rock Golem
    21105 => ChanceReward.new(310, 1), # Delu Lizardman Special Agent
    21107 => ChanceReward.new(600, 1), # Delu Lizardman Commander
    21117 => ChanceReward.new(120, 1), # Kasha Imp
    21023 => ChanceReward.new(170, 1), # Sobbing Wind
    21024 => ChanceReward.new(175, 1), # Babbling Wind
    21025 => ChanceReward.new(185, 1), # Giggling Wind
    21026 => ChanceReward.new(200, 1), # Singing Wind
    21034 => ChanceReward.new(195, 1), # Ogre
    21125 => ChanceReward.new(12, 1), # Northern Trimden
    21263 => ChanceReward.new(650, 1), # Ol Mahum Transcender
    21520 => ChanceReward.new(880, 1), # Eye of Splendor
    21526 => ChanceReward.new(970, 1), # Wisdom of Splendor
    21536 => ChanceReward.new(985, 1), # Crown of Splendor
    21602 => ChanceReward.new(555, 1), # Zaken's Pikeman
    21603 => ChanceReward.new(750, 1), # Zaken's Pikeman
    21605 => ChanceReward.new(620, 1), # Zaken's Archer
    21606 => ChanceReward.new(875, 1), # Zaken's Archer
    21611 => ChanceReward.new(590, 1), # Unpleasant Humming
    21612 => ChanceReward.new(835, 1), # Unpleasant Humming
    21617 => ChanceReward.new(615, 1), # Fiend Archer
    21618 => ChanceReward.new(875, 1), # Fiend Archer
    21635 => ChanceReward.new(775, 1), # Veil Master
    21638 => ChanceReward.new(165, 1), # Dread Wolf
    21639 => ChanceReward.new(185, 1), # Tasaba Lizardman
    21641 => ChanceReward.new(195, 1), # Ogre
    21644 => ChanceReward.new(170, 1), # Lienrik
    22231 => ChanceReward.new(10, 1), # Dominant Grey Keltir
    22233 => ChanceReward.new(20, 1), # Dominant Black Wolf
    22234 => ChanceReward.new(30, 1), # Green Goblin
    22235 => ChanceReward.new(35, 1), # Mountain Werewolf
    22237 => ChanceReward.new(55, 1), # Mountain Fungus
    22238 => ChanceReward.new(70, 1), # Mountain Werewolf Chief
    22241 => ChanceReward.new(80, 1), # Colossus
    22244 => ChanceReward.new(90, 1), # Crimson Spider
    22247 => ChanceReward.new(90, 1), # Grotto Golem
    22250 => ChanceReward.new(90, 1), # Grotto Leopard
    22252 => ChanceReward.new(95, 1), # Grotto Grizzly
    20579 => ChanceReward.new(420, 2), # Leto Lizardman Soldier
    20639 => ChanceReward.new(280, 2), # Mirror
    20646 => ChanceReward.new(145, 2), # Halingka
    20648 => ChanceReward.new(120, 2), # Paliote
    20650 => ChanceReward.new(460, 2), # Kranrot
    20651 => ChanceReward.new(260, 2), # Gamlin
    20652 => ChanceReward.new(335, 2), # Leogul
    20657 => ChanceReward.new(630, 2), # Lesser Giant Mage
    20658 => ChanceReward.new(570, 2), # Lesser Giant Elder
    20808 => ChanceReward.new(50, 2), # Nos Lad
    20809 => ChanceReward.new(865, 2), # Ghost of the Tower
    20832 => ChanceReward.new(700, 2), # Zaken's Pikeman
    20979 => ChanceReward.new(980, 2), # Elmoradan's Maid
    20991 => ChanceReward.new(665, 2), # Swamp Tribe
    20994 => ChanceReward.new(590, 2), # Garden Guard Leader
    21261 => ChanceReward.new(170, 2), # Ol Mahum Transcender
    21263 => ChanceReward.new(795, 2), # Ol Mahum Transcender
    21508 => ChanceReward.new(100, 2), # Splinter Stakato
    21510 => ChanceReward.new(280, 2), # Splinter Stakato Soldier
    21511 => ChanceReward.new(995, 2), # Splinter Stakato Drone
    21512 => ChanceReward.new(995, 2), # Splinter Stakato Drone
    21514 => ChanceReward.new(185, 2), # Needle Stakato Worker
    21516 => ChanceReward.new(495, 2), # Needle Stakato Drone
    21517 => ChanceReward.new(495, 2), # Needle Stakato Drone
    21518 => ChanceReward.new(255, 2), # Frenzy Stakato Soldier
    21636 => ChanceReward.new(950, 2), # Veil Master
    20655 => ChanceReward.new(110, 3), # Lesser Giant Shooter
    20656 => ChanceReward.new(150, 3), # Lesser Giant Scout
    20772 => ChanceReward.new(105, 3), # Barif's Pet
    20810 => ChanceReward.new(50, 3), # Hallate's Seer
    20812 => ChanceReward.new(490, 3), # Archer of Despair
    20814 => ChanceReward.new(775, 3), # Blader of Despair
    20816 => ChanceReward.new(875, 3), # Hallate's Royal Guard
    20819 => ChanceReward.new(280, 3), # Archer of Abyss
    20955 => ChanceReward.new(670, 3), # Ghostly Warrior
    20978 => ChanceReward.new(555, 3), # Elmoradan's Archer Escort
    21058 => ChanceReward.new(355, 3), # Beast Lord
    21060 => ChanceReward.new(45, 3), # Beast Seer
    21075 => ChanceReward.new(110, 3), # Slaughter Bathin
    21078 => ChanceReward.new(610, 3), # Magus Valac
    21081 => ChanceReward.new(955, 3), # Power Angel Amon
    21264 => ChanceReward.new(920, 3), # Ol Mahum Transcender
    20815 => ChanceReward.new(205, 4), # Hound Dog of Hallate
    20822 => ChanceReward.new(100, 4), # Hallate's Maid
    20824 => ChanceReward.new(665, 4), # Hallate's Commander
    20825 => ChanceReward.new(620, 4), # Hallate's Inspector
    20983 => ChanceReward.new(205, 4), # Binder
    21314 => ChanceReward.new(145, 4), # Hot Springs Bandersnatchling
    21316 => ChanceReward.new(235, 4), # Hot Springs Flava
    21318 => ChanceReward.new(280, 4), # Hot Springs Antelope
    21320 => ChanceReward.new(355, 4), # Hot Springs Yeti
    21322 => ChanceReward.new(430, 4), # Hot Springs Bandersnatch
    21376 => ChanceReward.new(280, 4), # Scarlet Stakato Worker
    21378 => ChanceReward.new(375, 4), # Scarlet Stakato Noble
    21380 => ChanceReward.new(375, 4), # Tepra Scarab
    21387 => ChanceReward.new(640, 4), # Arimanes of Destruction
    21393 => ChanceReward.new(935, 4), # Magma Drake
    21395 => ChanceReward.new(855, 4), # Elder Lavasaurus
    21652 => ChanceReward.new(375, 4), # Scarlet Stakato Noble
    21655 => ChanceReward.new(640, 4), # Arimanes of Destruction
    21657 => ChanceReward.new(935, 4), # Magma Drake
    20828 => ChanceReward.new(935, 5), # Platinum Tribe Shaman
    21061 => ChanceReward.new(530, 5), # Hallate's Guardian
    21069 => ChanceReward.new(825, 5), # Platinum Guardian Prefect
    21382 => ChanceReward.new(125, 5), # Mercenary of Destruction
    21384 => ChanceReward.new(400, 5), # Necromancer of Destruction
    21390 => ChanceReward.new(750, 5), # Ashuras of Destruction
    21654 => ChanceReward.new(400, 5), # Necromancer of Destruction
    21656 => ChanceReward.new(750, 5) # Ashuras of Destruction
  }
  private MOBS_SPECIAL = {
    20829 => ChanceReward.new(115, 6), # Platinum Tribe Overlord
    20859 => ChanceReward.new(890, 8), # Guardian Angel
    21066 => ChanceReward.new(5, 5), # Platinum Guardian Shaman
    21068 => ChanceReward.new(565, 11), # Guardian Archangel
    21071 => ChanceReward.new(400, 12) # Seal Archangel
  }
  private SWEET_FLUID = 7586

  def initialize
    super(426, self.class.simple_name, "Quest for Fishing Shot")

    add_start_npc(NPC)
    add_talk_id(NPC)
    add_kill_id(MOBS.keys)
    register_quest_items(SWEET_FLUID)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "QUEST_ACEPT"
      qs.start_quest
      return "03.htm"
    when "1"
      return "06.html"
    when "2"
      return "07.html"
    when "3"
      qs.exit_quest(true)
      return "08.html"
    end

    event
  end

  def on_kill(npc, killer, is_summon)
    if qs = get_random_party_member_state(killer, -1, 2, npc)
      if tmp = MOBS_SPECIAL[npc.id]?
        if Rnd.rand(1000) <= tmp.chance
          reward_items(qs.player, SWEET_FLUID, tmp.reward + 1)
        else
          reward_items(qs.player, SWEET_FLUID, tmp.reward)
      end
        play_sound(qs.player, Sound::ITEMSOUND_QUEST_ITEMGET)
      else
        tmp = MOBS[npc.id]
        if Rnd.rand(1000) <= tmp.chance
          reward_items(qs.player, SWEET_FLUID, tmp.reward)
          play_sound(qs.player, Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      return "01.htm"
    when State::STARTED
      unless has_quest_items?(pc, SWEET_FLUID)
        return "04.html"
      end
      return "05.html"
    end

    get_no_quest_msg(pc)
  end
end
