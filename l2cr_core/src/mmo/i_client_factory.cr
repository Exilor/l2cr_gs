module MMO::IClientFactory(T)
  abstract def create(con : Connection(T)) : T
end
