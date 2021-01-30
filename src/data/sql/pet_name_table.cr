module PetNameTable
  extend self
  extend Loggable

  def includes?(name : String) : Bool
    begin
      GameDB.query_each("SELECT name FROM pets WHERE name=?", name) do
        return true
      end
    rescue e
      error e
    end

    false
  end

  def valid?(name : String) : Bool
    name.matches?(Config.pet_name_template)
  end
end
