class Packets::Outgoing::ShowBoard < GameServerPacket
  def initialize(html_code : String?, id : String)
    @content = "#{id}\u0008#{html_code}"
  end

  def initialize(args : Enumerable)
    @content = String.build(200) do |io|
      io << "1002\u0008"
      args.join("\u0008", io)
      io << "\u0008"
    end
  end

  def write_impl
    c 0x7b

    c 0x01 # 0 hide, 1 show
    # debug @content
    s "bypass _bbshome" # top
    s "bypass _bbsgetfav" # favorite
    s "bypass _bbsloc" # region
    s "bypass _bbsclan" # clan
    s "bypass _bbsmemo" # memo
    s "bypass _bbsmail" # mail
    s "bypass _bbsfriends" # friends
    s "bypass bbs_add_fav" # add fav.
    s @content
  end
end
