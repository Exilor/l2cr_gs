struct ItemFlags < AbstractFlags
  flags(
    # L2Item
    "stackable",
    "sellable",
    "droppable",
    "destroyable",
    "tradeable",
    "depositable",
    "elementable",
    "quest_item",
    "freightable",
    "hero_item",
    "for_npc",
    "common",
    "pvp_item",
    "allows_self_resurrection",
    "has_immediate_effect",
    "has_ex_immediate_effect",
    "oly_restricted_item",

    # L2Weapon
    "magic_weapon",
    "force_equip",
    "attack_weapon",
    "use_weapon_skills_only",

    # L2EtcItem
    "blessed"
  )
end
