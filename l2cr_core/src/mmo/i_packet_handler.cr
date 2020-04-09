module MMO::IPacketHandler(T)
  abstract def handle(io : ByteBuffer, client : T) : IncomingPacket(T)?
end
