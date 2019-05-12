class Q00737_DenyBlessings < TerritoryWarSuperClass
  def initialize
    super(737, self.class.simple_name, "Deny Blessings")

    @class_ids = [
      43,
      112,
      30,
      105,
      16,
      97,
      17,
      98,
      52,
      116
    ]
    @random_min = 3
    @random_max = 8
    @npc_string = [
      NpcString::YOU_HAVE_DEFEATED_S2_OF_S1_HEALERS_AND_BUFFERS,
      NpcString::YOU_WEAKENED_THE_ENEMYS_ATTACK
    ]
  end
end
