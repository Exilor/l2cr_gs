module MMO::IAcceptFilter
  abstract def accept?(socket : TCPSocket) : Bool
end
