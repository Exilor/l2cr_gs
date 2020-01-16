require "./i_audio"

class Music < EnumClass
  include IAudio

  getter packet : PlaySound

  protected def initialize(name, delay = 0)
    @packet = PlaySound.create_music(name, delay)
  end

  def sound_name : String
    @packet.sound_name
  end

  add(B03_D_10000, "B03_D", 10000)
  add(B03_F, "B03_F")
  add(B04_S01, "B04_S01")
  add(B06_F_2000, "B06_F", 2000)
  add(B06_S01_2000, "B06_S01", 2000)
  add(B07_S01_2000, "B07_S01", 2000)
  add(BS01_A_10000, "BS01_A", 10000)
  add(BS01_A_7000, "BS01_A", 7000)
  add(BS01_D_10000, "BS01_D", 10000)
  add(BS01_D_6000, "BS01_D", 6000)
  add(BS02_A_10000, "BS02_A", 10000)
  add(BS02_A_6000, "BS02_A", 6000)
  add(BS02_D_10000, "BS02_D", 10000)
  add(BS02_D_7000, "BS02_D", 7000)
  add(BS03_A_10000, "BS03_A", 10000)
  add(BS04_A_6000, "BS04_A", 6000)
  add(BS04_A_3000, "BS04_A", 3000)
  add(BS05_D_5000, "BS05_D", 5000)
  add(BS05_D_6000, "BS05_D", 6000)
  add(BS06_A_5000, "BS06_A", 5000)
  add(BS07_A_10000, "BS07_A", 10000)
  add(BS07_D_10000, "BS07_D", 10000)
  add(BS08_A_10000, "BS08_A", 10000)
  add(EV_01_10000, "EV_01", 10000)
  add(EV_02_10000, "EV_02", 10000)
  add(EV_03_200, "EV_03", 200)
  add(EV_04_200, "EV_04", 200)
  add(HB01_10000, "HB01", 10000)
  add(NS01_F_5000, "ns01_f", 5000)
  add(NS22_F_5000, "ns22_f", 5000)
  add(RM01_A_4000, "Rm01_A", 4000)
  add(RM01_A_8000, "Rm01_A", 8000)
  add(RM01_S_4000, "RM01_S", 4000)
  add(SSQ_Dawn_01, "SSQ_Dawn_01")
  add(SSQ_Dusk_01, "SSQ_Dusk_01")
  add(SSQ_Neutral_01, "SSQ_Neutral_01")
  add(TP01_F_3000, "TP01_F", 3000)
  add(TP02_F_3000, "TP02_F", 3000)
  add(TP03_F_3000, "TP03_F", 3000)
  add(TP04_F_3000, "TP04_F", 3000)
  add(TP05_F, "TP05_F")
  add(TP05_F_5000, "TP05_F", 5000)
  add(SF_S_01, "SF_S_01")
  add(NS22_F, "NS22_F")
  add(S_RACE, "S_Race")
  add(SF_P_01, "SF_P_01")
  add(SIEGE_VICTORY, "Siege_Victory")
end
