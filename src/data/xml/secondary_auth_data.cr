module SecondaryAuthData
  extend self
  extend XMLReader

  private FORBIDDEN_PASSWORDS = Set(String).new

  class_getter max_attempts = 5
  class_getter ban_time = 480
  class_getter recovery_link = ""
  class_getter? enabled = false

  def load
    debug "Loading..."
    FORBIDDEN_PASSWORDS.clear
    parse_datapack_file("../config/SecondaryAuth.xml")
    info { "Loaded #{FORBIDDEN_PASSWORDS.size} forbidden passwords." }
  end

  private def parse_document(doc, file)
    find_element(doc, "list") do |node|
      each_element(node) do |list_node, list_node_name|
        case list_node_name.casecmp
        when "enabled"
          @@enabled = Bool.new(get_content(list_node))
        when "maxAttempts"
          @@max_attempts = get_content(list_node).to_i
        when "banTime"
          @@ban_time = get_content(list_node).to_i
        when "recoveryLink"
          @@recovery_link = get_content(list_node)
        when "forbiddenPasswords"
          find_element(list_node, "password") do |pass|
            FORBIDDEN_PASSWORDS << get_content(pass)
          end
        else
          # [automatically added else]
        end
      end
    end
  rescue e
    error e
  end

  def forbidden_passwords : Set(String)
    FORBIDDEN_PASSWORDS
  end

  def forbidden_password?(pass : String) : Bool
    FORBIDDEN_PASSWORDS.includes?(pass)
  end
end
