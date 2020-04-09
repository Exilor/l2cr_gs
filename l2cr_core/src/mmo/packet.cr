abstract class MMO::Packet(T)
  property! buffer : ByteBuffer?
  property! client : T?
end
