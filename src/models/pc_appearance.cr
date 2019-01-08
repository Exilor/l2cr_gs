class PcAppearance
  DEFAULT_TITLE_COLOR = 0xECF9A2

  setter visible_name : String?
  setter visible_title : String?
  property title_color : Int32 = 0xFFFFFF
  property name_color : Int32 = DEFAULT_TITLE_COLOR
  property! owner : L2PcInstance
  property? ghost : Bool = false

  property_initializer face: Int8, hair_color: Int8, hair_style: Int8,
    sex: Bool

  def visible_name : String
    @visible_name || owner.name
  end

  def visible_title : String
    @visible_title || owner.title
  end

  def set_name_color(red : Int32, green : Int32, blue : Int32)
    @name_color = (red & 0xff) + ((green & 0xff) << 8) + ((blue & 0xff) << 16)
  end
end
