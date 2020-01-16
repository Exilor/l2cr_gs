module IAudio
  private alias PlaySound = Packets::Outgoing::PlaySound

  abstract def sound_name : String
  abstract def packet : PlaySound
end
