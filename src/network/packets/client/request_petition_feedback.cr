class Packets::Incoming::RequestPetitionFeedback < GameClientPacket
  private INSERT_FEEDBACK = "INSERT INTO petition_feedback VALUES (?,?,?,?,?)"

  @rate = -1
  @message = ""

  private def read_impl
    d # unknown
    @rate = d
    @message = s
  end

  private def run_impl
    return unless pc = active_char
    return unless gm_name = pc.last_petition_gm_name
    return unless @rate.between?(0, 4)

    begin
      GameDB.exec(INSERT_FEEDBACK, pc.name, gm_name, @rate, @message, Time.ms)
    rescue e
      error e
    end
  end
end
