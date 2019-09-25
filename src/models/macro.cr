require "./macro_cmd"

class Macro
  property_initializer id : Int32, icon : Int32, name : String,
    description : String, acronym : String, commands : Array(MacroCMD)
end
