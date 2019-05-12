class Q00738_DestroyKeyTargets < TerritoryWarSuperClass
  def initialize
    super(738, self.class.simple_name, "Destroy Key Targets")

    @class_ids = [
      51,
      115,
      57,
      118
    ]
    @random_min = 3
    @random_max = 8
    @npc_string = [
      NpcString::YOU_HAVE_DEFEATED_S2_OF_S1_WARSMITHS_AND_OVERLORDS,
      NpcString::YOU_DESTROYED_THE_ENEMYS_PROFESSIONALS
    ]
  end
end
