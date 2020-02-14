class Condition
  class CategoryType < Condition
    @categories : Slice(::CategoryType)

    def initialize(categories)
      @categories = categories.uniq.to_slice
    end

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      @categories.any? { |type| effector.in_category?(type) }
    end
  end
end
