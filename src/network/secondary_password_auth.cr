require "digest/sha1"

class SecondaryPasswordAuth
  include Packets::Outgoing
  include Loggable

  private VAR_PWD = "secauth_pwd"
  private VAR_WTE = "secauth_wte"

  private SELECT_PASSWORD = "SELECT var, value FROM account_gsdata WHERE account_name=? AND var LIKE 'secauth_%'"
  private INSERT_PASSWORD = "INSERT INTO account_gsdata VALUES (?, ?, ?)"
  private UPDATE_PASSWORD = "UPDATE account_gsdata SET value=? WHERE account_name=? AND var=?"

  private INSERT_ATTEMPT = "INSERT INTO account_gsdata VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE value=?"

  @password : String?

  property? authed : Bool

  def initialize(client : GameClient)
    @client = client
    @wrong_attempts = 0
    @authed = false
    load_password
  end

  private def load_password
    GameDB.each(SELECT_PASSWORD, @client.account_name) do |rs|
      var = rs.get_string(:"var")
      value = rs.get_string(:"value")

      if var == VAR_PWD
        @password = value
      elsif var == VAR_WTE
        @wrong_attempts = value.to_i
      end
    end
  rescue e
    error e
  end

  def save_password(password : String) : Bool
    if password_exist?
      warn { "#{@client} tried to save a password when already having one." }
      @client.close_now
      return false
    end

    unless validate_password(password)
      @client.send_packet(Ex2ndPasswordAck::WRONG)
      return false
    end

    password = encrypt_password(password)

    begin
      GameDB.exec(INSERT_PASSWORD, @client.account_name, VAR_PWD, password)
    rescue e
      error e
      return false
    end

    @password = password

    true
  end

  def insert_wrong_attempt(attempts : Int32) : Bool
    GameDB.exec(
      INSERT_ATTEMPT,
      @client.account_name,
      VAR_WTE,
      attempts.to_s,
      attempts.to_s
    )
    true
  rescue e
    error e
    false
  end

  def change_password(old_password : String, new_password : String) : Bool
    unless password_exist?
      warn { "#{@client} tried to change a password that doesn't exist." }
      @client.close_now
      return false
    end

    unless check_password(old_password, true)
      return false
    end

    unless validate_password(new_password)
      @client.send_packet(Ex2ndPasswordAck::WRONG)
      return false
    end

    new_password = encrypt_password(new_password)

    begin
      GameDB.exec(UPDATE_PASSWORD, new_password, @client.account_name, VAR_PWD)
    rescue e
      error e
      return false
    end

    @password = new_password
    @authed = false

    true
  end

  def check_password(password : String, skip_auth : Bool) : Bool
    password = encrypt_password(password)

    unless password == @password
      @wrong_attempts += 1
      if @wrong_attempts < SecondaryAuthData.max_attempts
        @client.send_packet(Ex2ndPasswordVerify.wrong(@wrong_attempts))
        insert_wrong_attempt(@wrong_attempts)
      else
        LoginServerThread.instance.send_temp_ban(
          @client.account_name,
          @client.connection.ip,
          SecondaryAuthData.ban_time
        )
        LoginServerThread.instance.send_mail(
          @client.account_name,
          "SATempBan",
          @client.connection.ip,
          SecondaryAuthData.max_attempts.to_s,
          SecondaryAuthData.ban_time.to_s,
          SecondaryAuthData.recovery_link
        )
        warn { "#{@client} has entered a wrong password #{@wrong_attempts} times in a row." }
        insert_wrong_attempt(0)
        @client.close(Ex2ndPasswordVerify.ban(SecondaryAuthData.max_attempts))
      end

      return false
    end

    unless skip_auth
      @authed = true
      @client.send_packet(Ex2ndPasswordVerify.ok(@wrong_attempts))
    end

    insert_wrong_attempt(0)

    true
  end

  def password_exist? : Bool
    !!@password
  end

  def open_dialog
    if password_exist?
      @client.send_packet(Ex2ndPasswordCheck::PROMPT)
    else
      @client.send_packet(Ex2ndPasswordCheck::NEW)
    end
  end

  private def encrypt_password(password : String)
    sha = Digest::SHA1.new
    sha.update(password)
    Base64.strict_encode(String.new(sha.final))
  end

  private def validate_password(password : String) : Bool
    return false unless password.number? && password.size.in?(6..8)
    !SecondaryAuthData.forbidden_password?(password)
  end
end
