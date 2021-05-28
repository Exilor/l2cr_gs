module GameDB
  module ServitorSkillSaveDAO
    include Loggable

    abstract def insert(servitor : L2ServitorInstance, store_effects : Bool)
    abstract def load(servitor : L2ServitorInstance)
  end
end
