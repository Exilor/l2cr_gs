module SecondaryAuthData
  extend self
  extend XMLReader

  private FORBIDDEN_PASSWORDS = Set(String).new

  class_getter max_attempts = 5
  class_getter ban_time = 480
  class_getter recovery_link = ""
  class_getter? enabled = false

  def load
    FORBIDDEN_PASSWORDS.clear
    parse_datapack_file("../config/SecondaryAuth.xml")
    info { "Loaded #{FORBIDDEN_PASSWORDS.size} forbidden passwords." }
  end

  private def parse_document(doc, file)
    doc.find_element("list") do |node|
      node.each_element do |list_node|
        case list_node.name.casecmp
        when "enabled"
          @@enabled = Bool.new(list_node.text)
        when "maxAttempts"
          @@max_attempts = list_node.text.to_i
        when "banTime"
          @@ban_time = list_node.text.to_i
        when "recoveryLink"
          @@recovery_link = list_node.text
        when "forbiddenPasswords"
          list_node.find_element("password") do |pass|
            FORBIDDEN_PASSWORDS << pass.text
          end
        end
      end
    end
  rescue e
    error e
  end

  def forbidden_passwords
    FORBIDDEN_PASSWORDS
  end

  def forbidden_password?(pass : String) : Bool
    FORBIDDEN_PASSWORDS.includes?(pass)
  end
end
