module SecondaryAuthData
  extend self
  extend XMLReader

  private FORBIDDEN_PASSWORDS = Set(String).new

  class_getter max_attempts = 5
  class_getter ban_time = 480i64
  class_getter recovery_link = ""
  class_getter? enabled = false

  def load
    debug "Loading..."
    FORBIDDEN_PASSWORDS.clear
    path = Dir.current + "/config/SecondaryAuth.xml"
    XMLReader.parse_file(path) { |doc, file| parse_document(doc, file) }
    info { "Loaded #{FORBIDDEN_PASSWORDS.size} forbidden passwords." }
  end

  private def parse_document(doc : XML::Node, file : File)
    find_element(doc, "list") do |node|
      each_element(node) do |list_node, list_node_name|
        case list_node_name.casecmp
        when "enabled"
          @@enabled = get_content(list_node).to_b
        when "maxAttempts"
          @@max_attempts = get_content(list_node).to_i
        when "banTime"
          @@ban_time = get_content(list_node).to_i64
        when "recoveryLink"
          @@recovery_link = get_content(list_node)
        when "forbiddenPasswords"
          find_element(list_node, "password") do |pass|
            FORBIDDEN_PASSWORDS << get_content(pass)
          end
        end
      end
    end
  rescue e
    error e
  end

  def forbidden_password?(pass : String) : Bool
    FORBIDDEN_PASSWORDS.includes?(pass)
  end
end
