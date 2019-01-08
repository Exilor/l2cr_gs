module IAudio
  abstract def sound_name : String
  abstract def packet : Packets::Outgoing::PlaySound
end
