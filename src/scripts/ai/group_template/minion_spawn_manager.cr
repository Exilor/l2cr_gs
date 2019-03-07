class NpcAI::MinionSpawnManager < AbstractNpcAI
  private NPC = [
    18344, # Ancient Egg
    18352, # Kamael Guard
    18353, # Guardian of Records
    18354, # Guardian of Observation
    18355, # Spicula's Guard
    18356, # Harkilgamed's Gatekeeper
    18357, # Rodenpicula's Gatekeeper
    18359, # Arviterre's Guardian
    18360, # Katenar's Gatekeeper
    18361, # Guardian of Prediction
    18484, # Naia Failan
    18491, # Lock
    18547, # Ancient Experiment
    18551, # Cruma Phantom
    35375, # Bloody Lord Nurka
    20376, # Varikan Brigand Leader
    20398, # Vrykolakas
    20520, # Pirate Captain Uthanka
    20522, # White Fang
    20738, # Kobold Looter Bepook
    20745, # Gigantiops
    20747, # Roxide
    20749, # Death Fire
    20751, # Snipe
    20753, # Dark Lord
    20755, # Talakin
    20758, # Dragon Bearer Chief
    20761, # Pytan
    20767, # Timak Orc Troop Leader
    20773, # Conjurer Bat Lord
    20939, # Tanor Silenos Warrior
    20941, # Tanor Silenos Chieftain
    20944, # Nightmare Lord
    20956, # Past Knight
    20959, # Dark Guard
    20963, # Bloody Lord
    20974, # Spiteful Soul Leader
    20977, # Elmoradan's Lady
    20980, # Hallate's Follower Mul
    20983, # Binder
    20986, # Sairon
    20991, # Swamp Tribe
    20994, # Garden Guard Leader
    21075, # Slaughter Bathin
    21078, # Magus Valac
    21081, # Power Angel Amon
    21090, # Bloody Guardian
    21312, # Eye of Ruler
    21343, # Ketra Commander
    21345, # Ketra's Head Shaman
    21347, # Ketra Prophet
    21369, # Varka's Commander
    21371, # Varka's Head Magus
    21373, # Varka's Prophet
    21432, # Chakram Beetle
    21434, # Seer of Blood
    21512, # Splinter Stakato Drone
    21517, # Needle Stakato Drone
    21541, # Pilgrim of Splendor
    21544, # Judge of Splendor
    21596, # Requiem Lord
    21599, # Requiem Priest
    21652, # Scarlet Stakato Noble
    21653, # Assassin Beetle
    21654, # Necromancer of Destruction
    21655, # Arimanes of Destruction
    21656, # Ashuras of Destruction
    21657, # Magma Drake
    22028, # Vagabond of the Ruins
    22080, # Massive Lost Bandersnatch
    22084, # Panthera
    22092, # Frost Iron Golem
    22096, # Ursus
    22100, # Freya's Gardener
    22102, # Freya's Servant
    22104, # Freya's Dog
    22155, # Triol's High Priest
    22159, # Triol's High Priest
    22163, # Triol's High Priest
    22167, # Triol's High Priest
    22171, # Triol's High Priest
    22188, # Andreas' Captain of the Royal Guard
    22196, # Velociraptor
    22198, # Velociraptor
    22202, # Ornithomimus
    22205, # Deinonychus
    22210, # Pachycephalosaurus
    22213, # Wild Strider
    22223, # Velociraptor
    22224, # Ornithomimus
    22225, # Deinonychus
    22275, # Gatekeeper Lohan
    22277, # Gatekeeper Provo
    22305, # Kechi's Captain
    22306, # Kechi's Captain
    22307, # Kechi's Captain
    22320, # Junior Watchman
    22321, # Junior Summoner
    22346, # Quarry Foreman
    22363, # Body Destroyer
    22370, # Passageway Captain
    22377, # Master Zelos
    22390, # Foundry Foreman
    22416, # Kechi's Captain
    22423, # Original Sin Warden
    22431, # Original Sin Warden
    22448, # Leodas
    22449, # Amaskari
    22621, # Male Spiked Stakato
    22625, # Cannibalistic Stakato Leader
    22630, # Spiked Stakato Nurse
    22666, # Barif
    22670, # Cursed Lord
    22742, # Ornithomimus
    22743, # Deinonychus
    25001, # Greyclaw Kutus
    25004, # Turek Mercenary Captain
    25007, # Retreat Spider Cletu
    25010, # Furious Thieles
    25013, # Ghost of Peasant Leader
    25016, # The 3rd Underwater Guardian
    25020, # Breka Warlock Pastu
    25023, # Stakato Queen Zyrnna
    25026, # Ketra Commander Atis
    25029, # Atraiban
    25032, # Eva's Guardian Millenu
    25035, # Shilen's Messenger Cabrio
    25038, # Tirak
    25041, # Remmel
    25044, # Barion
    25047, # Karte
    25051, # Rahha
    25054, # Kernon
    25057, # Beacon of Blue Sky
    25060, # Unrequited Kael
    25064, # Wizard of Storm Teruk
    25067, # Captain of Red Flag Shaka
    25070, # Enchanted Forest Watcher Ruell
    25073, # Bloody Priest Rudelto
    25076, # Princess Molrang
    25079, # Cat's Eye Bandit
    25082, # Leader of Cat Gang
    25085, # Timak Orc Chief Ranger
    25089, # Soulless Wild Boar
    25092, # Korim
    25095, # Elf Renoa
    25099, # Rotting Tree Repiro
    25103, # Sorcerer Isirr
    25106, # Ghost of the Well Lidia
    25109, # Antharas Priest Cloe
    25112, # Beleth's Agent, Meana
    25115, # Icarus Sample 1
    25119, # Messenger of Fairy Queen Berun
    25122, # Refugee Applicant Leo
    25128, # Vuku Grand Seer Gharmash
    25131, # Carnage Lord Gato
    25134, # Leto Chief Talkin
    25137, # Beleth's Seer, Sephia
    25140, # Hekaton Prime
    25143, # Fire of Wrath Shuriel
    25146, # Serpent Demon Bifrons
    25149, # Zombie Lord Crowl
    25152, # Flame Lord Shadar
    25155, # Shaman King Selu
    25159, # Paniel the Unicorn
    25166, # Ikuntai
    25170, # Lizardmen Leader Hellion
    25173, # Tiger King Karuta
    25176, # Black Lily
    25179, # Guardian of the Statue of Giant Karum
    25182, # Demon Kuri
    25185, # Tasaba Patriarch Hellena
    25189, # Cronos's Servitor Mumu
    25192, # Earth Protector Panathen
    25199, # Water Dragon Seer Sheshark
    25202, # Krokian Padisha Sobekk
    25205, # Ocean Flame Ashakiel
    25208, # Water Couatle Ateka
    25211, # Sebek
    25214, # Fafurion's Page Sika
    25217, # Cursed Clara
    25220, # Death Lord Hallate
    25223, # Soul Collector Acheron
    25226, # Roaring Lord Kastor
    25230, # Timak Seer Ragoth
    25235, # Vanor Chief Kandra
    25238, # Abyss Brukunt
    25241, # Harit Hero Tamash
    25245, # Last Lesser Giant Glaki
    25249, # Menacing Palatanos
    25252, # Palibati Queen Themis
    25256, # Taik High Prefect Arak
    25260, # Iron Giant Totem
    25263, # Kernon's Faithful Servant Kelone
    25266, # Bloody Empress Decarbia
    25269, # Beast Lord Behemoth
    25273, # Carnamakos
    25277, # Lilith's Witch Marilion
    25283, # Lilith
    25286, # Anakim
    25290, # Daimon the White-Eyed
    25293, # Hesti Guardian Deity of the Hot Springs
    25296, # Icicle Emperor Bumbalump
    25299, # Ketra's Hero Hekaton
    25302, # Ketra's Commander Tayr
    25306, # Soul of Fire Nastron
    25309, # Varka's Hero Shadith
    25312, # Varka's Commander Mos
    25316, # Soul of Water Ashutar
    25319, # Ember
    25322, # Demon's Agent Falston
    25325, # Flame of Splendor Barakiel
    25328, # Eilhalder von Hellmann
    25352, # Giant Wasteland Basilisk
    25354, # Gargoyle Lord Sirocco
    25357, # Sukar Wererat Chief
    25360, # Tiger Hornet
    25362, # Tracker Leader Sharuk
    25366, # Kuroboros' Priest
    25369, # Soul Scavenger
    25373, # Malex Herald of Dagoniel
    25375, # Zombie Lord Ferkel
    25378, # Madness Beast
    25380, # Kaysha Herald of Icarus
    25383, # Revenant of Sir Calibus
    25385, # Evil Spirit Tempest
    25388, # Red Eye Captain Trakia
    25392, # Captain of Queen's Royal Guards
    25395, # Archon Suscepter
    25398, # Beleth's Eye
    25401, # Skyla
    25404, # Corsair Captain Kylon
    25407, # Lord Ishka
    25410, # Road Scavenger Leader
    25412, # Necrosentinel Royal Guard
    25415, # Nakondas
    25418, # Dread Avenger Kraven
    25420, # Orfen's Handmaiden
    25423, # Fairy Queen Timiniel
    25426, # Betrayer of Urutu Freki
    25429, # Mammon Collector Talos
    25431, # Flamestone Golem
    25434, # Bandit Leader Barda
    25438, # Thief Kelbar
    25441, # Evil Spirit Cyrion
    25444, # Enmity Ghost Ramdal
    25447, # Immortal Savior Mardil
    25450, # Cherub Galaxia
    25453, # Meanas Anor
    25456, # Mirror of Oblivion
    25460, # Deadman Ereve
    25463, # Harit Guardian Garangky
    25467, # Gorgolos
    25470, # Last Titan Utenus
    25473, # Grave Robber Kim
    25475, # Ghost Knight Kabed
    25478, # Shilen's Priest Hisilrome
    25481, # Magus Kenishee
    25484, # Zaken's Chief Mate Tillion
    25487, # Water Spirit Lian
    25490, # Gwindorr
    25493, # Eva's Spirit Niniel
    25496, # Fafurion's Envoy Pingolpin
    25498, # Fafurion's Henchman Istary
    25501, # Boss Akata
    25504, # Nellis' Vengeful Spirit
    25506, # Rayito the Looter
    25509, # Dark Shaman Varangka
    25514, # Queen Shyeed
    25524, # Flamestone Giant
    25528, # Tiberias
    25536, # Hannibal
    25546, # Rhianna the Traitor
    25549, # Tesla the Deceiver
    25554, # Brutus the Obstinate
    25557, # Ranger Karankawa
    25560, # Sargon the Mad
    25563, # Beautiful Atrielle
    25566, # Nagen the Tomboy
    25569, # Jax the Destroyer
    25572, # Hager the Outlaw
    25575, # All-Seeing Rango
    25579, # Helsing
    25582, # Gillien
    25585, # Medici
    25589, # Brand the Exile
    25593, # Gerg the Hunter
    25600, # Temenir
    25601, # Draksius
    25602, # Kiretcenah
    25671, # Queen Shyeed
    25674, # Gwindorr
    25677, # Water Spirit Lian
    25681, # Gorgolos
    25684, # Last Titan Utenus
    25687, # Hekaton Prime
    25703, # Gigantic Golem
    25710, # Lost Captain
    25735, # Greyclaw Kutus
    25738, # Lead Tracker Sharuk
    25741, # Sukar Wererat Chief
    25744, # Ikuntai
    25747, # Zombie Lord Crowl
    25750, # Zombie Lord Ferkel
    25754, # Fire Lord Shadar
    25757, # Soul Collector Acheron
    25760, # Lord Ishka
    25763, # Demon Kuri
    25767, # Carnage Lord Gato
    25770, # Ketra Commander Atis
    25773, # Beacon of Blue Sky
    25776, # Earth Protector Panathen
    25779, # Betrayer of Urutu Freki
    25782, # Nellis' Vengeful Spirit
    25784, # Rayito the Looter
    25787, # Ketra's Hero Hekaton
    25790, # Varka's Hero Shadith
    25794, # Kernon
    25797, # Meanas Anor
    25800, # Mammon Collector Talos
    27036, # Calpico
    27041, # Varangka's Messenger
    27062, # Tanukia
    27065, # Roko
    27068, # Murtika
    27093, # Delu Chief Kalkis
    27108, # Stenoa Gorgon Queen
    27110, # Shyslassys
    27112, # Gorr
    27113, # Baraham
    27114, # Succubus Queen
    27185, # Fairy Tree of Wind
    27186, # Fairy Tree of Star
    27187, # Fairy Tree of Twilight
    27188, # Fairy Tree of Abyss
    27259, # Archangel Iconoclasis
    27260, # Archangel Iconoclasis
    27266, # Fallen Angel Haures
    27267, # Fallen Angel Haures
    27290, # White Wing Commander
    29001, # Queen Ant
    29030, # Fenril Hound Kerinne
    29033, # Fenril Hound Freki
    29037, # Fenril Hound Kinaz
    29040, # Wings of Flame, Ixion
    29056, # Ice Fairy Sirra
    29062, # Andreas Van Halter
    29096, # Anais
    29129, # Lost Captain
    29132, # Lost Captain
    29135, # Lost Captain
    29138, # Lost Captain
    29141, # Lost Captain
    29144, # Lost Captain
    29147  # Lost Captain
  ]

  private ON_ATTACK_MSG = {
    NpcString::COME_OUT_YOU_CHILDREN_OF_DARKNESS,
    NpcString::SHOW_YOURSELVES,
    NpcString::DESTROY_THE_ENEMY_MY_BROTHERS,
    NpcString::FORCES_OF_DARKNESS_FOLLOW_ME
  }

  private ON_ATTACK_NPC = {
    20767 # Timak Orc Troop Leader
  }

  def initialize
    super(self.class.simple_name, "ai/group_template")

    add_spawn_id(NPC)
    add_attack_id(ON_ATTACK_NPC)
  end

  def on_spawn(npc)
    npc = npc.as(L2MonsterInstance)
    if npc.template.parameters["SummonPrivateRate"]?.nil?
      npc.minion_list.spawn_minions(npc.template.parameters.get_minion_list("Privates"))
      npc.script_value = 1
    else
      npc.script_value = 0
    end

    super
  end

  def on_attack(npc, attacker, damage, is_summon)
    if npc.is_a?(L2MonsterInstance) && !npc.teleporting?
      if Rnd.rand(1..100) <= npc.template.parameters.get_i32("SummonPrivateRate", 0)
        if npc.script_value?(0)
          # p npc.template.parameters.get_minion_list("Privates")
          npc.template.parameters.get_minion_list("Privates").each do |is|
            add_minion(npc, is.id)
          end

          broadcast_npc_say(npc, Say2::NPC_ALL, ON_ATTACK_MSG.sample(random: Rnd))
          npc.script_value = 1
        end
      end
    end

    super
  end
end
