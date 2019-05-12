class Q00734_PierceThroughAShield < TerritoryWarSuperClass
  def initialize
    super(734, self.class.simple_name, "Pierce through a Shield")

    @class_ids = [
      6,
      91,
      5,
      90,
      20,
      99,
      33,
      106
    ]
    @random_min = 10
    @random_max = 15
    @npc_string = [
      NpcString::YOU_HAVE_DEFEATED_S2_OF_S1_KNIGHTS,
      NpcString::YOU_WEAKENED_THE_ENEMYS_DEFENSE
    ]
  end
end
