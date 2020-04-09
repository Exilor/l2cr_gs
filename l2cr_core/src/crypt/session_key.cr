struct SessionKey
  getter_initializer login_ok_1 : Int32, login_ok_2 : Int32, play_ok_1 : Int32,
    play_ok_2 : Int32

  def ==(other : self) : Bool
    return false unless @play_ok_1 == other.play_ok_1
    return false unless @play_ok_2 == other.play_ok_2
    if Config.show_licence
      return false unless @login_ok_1 == other.login_ok_1
      return false unless @login_ok_2 == other.login_ok_2
    end
    true
  end
end
