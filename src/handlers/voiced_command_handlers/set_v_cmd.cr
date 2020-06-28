module VoicedCommandHandler::SetVCmd
  extend self
  extend VoicedCommandHandler

  private COMMANDS = {"set name", "set home", "set group"}

  def use_voiced_command(cmd : String, pc : L2PcInstance, params : String) : Bool
    if cmd == "set"
      return false unless clan = pc.clan
      return false unless player = pc.target.as?(L2PcInstance)
      return false unless target_clan = player.clan
      return false unless clan.id == target_clan.id

      if params.starts_with?("privileges")
        val = params.from(11)
        unless val.number?
          return false
        end

        n = val.to_i

        if pc.clan_privileges.bitmask <= n || !pc.clan_leader?
          return false
        end

        pc.clan_privileges.bitmask = n
        pc.send_message("Your clan privileges have been set to #{n} by #{pc.name}.")
      elsif params.starts_with?("title")
        # L2J TODO
      end
    end

    true
  end

  def commands : Indexable(String)
    COMMANDS
  end
end
