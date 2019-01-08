class L2Henna
  @wear_class = [] of ClassId
  getter str : Int32
  getter con : Int32
  getter dex : Int32
  getter int : Int32
  getter men : Int32
  getter wit : Int32
  getter wear_fee : Int32
  getter wear_count : Int32
  getter cancel_fee : Int32
  getter cancel_count : Int32
  getter dye_id : Int32
  getter dye_name : String
  getter dye_item_id : Int32

  def initialize(set : StatsSet)
    @dye_id = set.get_i32("dyeId")
    @dye_name = set.get_string("dyeName")
    @dye_item_id = set.get_i32("dyeItemId")
    @str = set.get_i32("str")
		@con = set.get_i32("con")
		@dex = set.get_i32("dex")
		@int = set.get_i32("int")
		@men = set.get_i32("men")
		@wit = set.get_i32("wit")
		@wear_fee = set.get_i32("wear_fee")
		@wear_count = set.get_i32("wear_count")
		@cancel_fee = set.get_i32("cancel_fee")
		@cancel_count = set.get_i32("cancel_count")
  end

  def allowed_class?(class_id : ClassId) : Bool
    @wear_class.includes?(class_id)
  end

  def wear_class=(ary : Enumerable(ClassId))
    @wear_class.concat(ary)
  end
end
