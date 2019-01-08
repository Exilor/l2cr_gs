class Packets::Incoming::EndScenePlayer < GameClientPacket
  @movie_id = 0

  def read_impl
    @movie_id = d
  end

  def run_impl
    return if @movie_id == 0
    return unless pc = active_char

    if pc.movie_id != @movie_id
      warn "Player #{pc} requested to end wrong movie id #{@movie_id}."
      return
    end

    pc.movie_id = 0
    pc.set_teleporting(true, false)
    pc.decay_me
    pc.spawn_me(*pc.xyz)
    pc.set_teleporting(false, false)
  end
end
