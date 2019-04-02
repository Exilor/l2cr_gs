require "html"

struct ClassInfo
  getter_initializer class_id: ClassId, class_name: String,
    parent_class_id: ClassId?

  def client_code : String
    "&$#{class_client_id};"
  end

  def client_code(io : IO)
    io << "&$" << class_client_id << ';'
  end

  def escaped_client_code : String
    HTML.escape(client_code)
  end

  private def class_client_id : Int32
    id = @class_id.to_i
    case id
    when 0..57
      247
    when 88..118
      1071
    when 123..136
      1438
    else
      0
    end + id
  end
end
