class Condition
  class ItemId < Condition
    initializer item_id : Int32

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless item
      item.id == @item_id
    end
  end
end
