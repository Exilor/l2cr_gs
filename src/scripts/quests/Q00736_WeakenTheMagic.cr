class Q00736_WeakenTheMagic < TerritoryWarSuperClass
  def initialize
    super(736, self.class.simple_name, "Weaken the magic")

    @class_ids = [
      40,
      110,
      27,
      103,
      13,
      95,
      12,
      94,
      41,
      111,
      28,
      104,
      14,
      96
    ]
    @random_min = 10
    @random_max = 15
    @npc_string = [
      NpcString::YOU_HAVE_DEFEATED_S2_OF_S1_ENEMIES,
      NpcString::YOU_WEAKENED_THE_ENEMYS_MAGIC
    ]
  end
end
