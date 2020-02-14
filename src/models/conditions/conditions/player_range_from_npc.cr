class Condition
  class PlayerRangeFromNpc < Condition
    @npc_ids : Slice(Int32)

    def initialize(npc_ids, radius : Int32, val : Bool)
      @npc_ids = npc_ids.sort.to_slice
      @radius = radius
      @val = val
    end

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      exist = false

      if !@npc_ids.empty? && @radius > 0
        effector.known_list.each_character(@radius) do |char|
          if char.npc? && @npc_ids.bincludes?(char.id)
            exist = true
            break
          end
        end
      end

      exist == @val
    end
  end
end
