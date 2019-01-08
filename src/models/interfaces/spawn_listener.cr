module SpawnListener
  # def npc_spawned(npc : L2Npc)
  #   # no-op
  # end
  abstract def npc_spawned(npc : L2Npc) : Nil
end
