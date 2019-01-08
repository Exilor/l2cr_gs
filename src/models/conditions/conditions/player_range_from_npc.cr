class Condition
  class PlayerRangeFromNpc < Condition
    initializer npc_ids: Array(Int32), radius: Int32, val: Bool

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      exist = false

      if !@npc_ids.empty? && @radius > 0
        effector.known_list.each_character(@radius) do |char|
          if char.npc? && @npc_ids.includes?(char.id)
            exist = true
            break
          end
        end
      end

      exist == @val
    end
  end
end
