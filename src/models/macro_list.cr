require "./macro"

class MacroList
  include Synchronizable
  include Loggable

  @macro_id = 1000
  @macros = Concurrent::Map(Int32, Macro).new

  getter revision = 1

  initializer owner : L2PcInstance

  delegate size, to: @macros

  def register_macro(mcr : Macro)
    if mcr.id == 0
      mcr.id = @macro_id &+ 1
      @macro_id += 1
      while @macros.has_key?(mcr.id)
        mcr.id = @macro_id
        @macro_id &+= 1
      end
      @macros[mcr.id] = mcr
    else
      old = @macros[mcr.id]?
      @macros[mcr.id] = mcr
      if old
        delete_macro_from_db(old)
      end
    end
    register_macro_in_db(mcr)
    send_update
  end

  def delete_macro(id : Int32)
    if deleted = @macros.delete(id)
      delete_macro_from_db(deleted)
    end

    @owner.all_shortcuts.each do |sc|
      if sc.id == id && sc.type.macro?
        @owner.delete_shortcut(sc.slot, sc.page)
      end
    end

    send_update
  end

  def send_update
    @revision &+= 1

    size = @macros.size
    if size == 0
      ml = Packets::Outgoing::SendMacroList.new(@revision, 0, nil)
      @owner.send_packet(ml)
    else
      @macros.each_value do |m|
        ml = Packets::Outgoing::SendMacroList.new(@revision, size, m)
        @owner.send_packet(ml)
      end
    end
  end

  private def register_macro_in_db(mcr : Macro)
    cmds = String.build do |io|
      mcr.commands.each do |cmd|
        io << cmd.type.to_i << ',' << cmd.d1 << ',' << cmd.d2
        if cmd2 = cmd.cmd
          if cmd2.size > 0
            io << ',' << cmd2
          end
        end
        io << ';'
        break if io.bytesize > 255
      end

      if io.bytesize > 255
        io.back(io.bytesize &- 255)
      end
    end

    sql = "INSERT INTO character_macroses (charId,id,icon,name,descr,acronym,commands) values(?,?,?,?,?,?,?)"
    GameDB.exec(
      sql,
      @owner.l2id,
      mcr.id,
      mcr.icon,
      mcr.name,
      mcr.description,
      mcr.acronym,
      cmds
    )
  rescue e
    error e
  end

  private def delete_macro_from_db(mcr : Macro)
    sql = "DELETE FROM character_macroses WHERE charId=? AND id=?"
    GameDB.exec(sql, @owner.l2id, mcr.id)
  rescue e
    error e
  end

  def restore_me : Bool
    @macros.clear

    sql = "SELECT charId, id, icon, name, descr, acronym, commands FROM character_macroses WHERE charId=?"
    GameDB.each(sql, @owner.l2id) do |rs|
      id = rs.get_i32(:"id")
      icon = rs.get_i32(:"icon")
      name = rs.get_string(:"name")
      descr = rs.get_string(:"descr")
      acronym = rs.get_string(:"acronym")
      commands = [] of MacroCMD

      st1 = rs.get_string(:"commands").split(';')
      until st1.empty?
        st = st1.shift.split(',')
        if st.size < 3
          next
        end
        type = MacroType[st.shift.to_i]
        d1 = st.shift.to_i
        d2 = st.shift.to_i
        cmd = ""
        unless st.empty?
          cmd = st.shift
        end
        commands << MacroCMD.new(commands.size, type, d1, d2, cmd)
      end
      @macros[id] = Macro.new(id, icon, name, descr, acronym, commands)
    end

    true
  rescue e
    error e
    false
  end
end
