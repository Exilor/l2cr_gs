class Class
  def simple_name : String
    {{@type.stringify.split("::").last}}
  end
end
