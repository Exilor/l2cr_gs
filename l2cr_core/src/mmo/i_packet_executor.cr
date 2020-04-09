module MMO::IPacketExecutor(T)
  abstract def execute(packet : IncomingPacket(T))
end
