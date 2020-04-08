class L2SignsPriestInstance < L2Npc
  def instance_type : InstanceType
    InstanceType::L2SignsPriestInstance
  end

  def on_bypass_feedback(pc : L2PcInstance, command : String)
    last_npc = pc.last_folk_npc
    if last_npc.nil? || last_npc.l2id != l2id
      return
    end

    if command.starts_with?("SevenSignsDesc")
      val = command.from(15).to_i
      show_chat_window(pc, val, nil, true)
    elsif command.starts_with?("SevenSigns")
      cabal = SevenSigns::CABAL_NULL
      stone_type = 0
      ancient_adena_amount = pc.ancient_adena

      val = command[11].to_i

      if command.size > 12
        val = command[11..12].strip.to_i
      end

      if command.size > 13
        begin
          cabal = command[14].to_i
        rescue
          begin
            cabal = command[13].to_i
          rescue
            begin
              st = command.strip.split
              st.shift
              cabal = st.shift.to_i
            rescue e
              error e
              warn { "Failed to retrieve cabal from bypass command. Npc ID: #{id}, command: \"#{command}\"." }
            end
          end
        end
      end

      case val
      when 2 # purchase 7s record
        unless pc.inventory.validate_capacity(1)
          pc.send_packet(SystemMessageId::SLOTS_FULL)
          return
        end
        cost = SevenSigns::RECORD_SEVEN_SIGNS_COST
        unless pc.reduce_adena("SevenSigns", cost, self, true)
          pc.send_packet(SystemMessageId::YOU_NOT_ENOUGH_ADENA)
          return
        end
        item_id = SevenSigns::RECORD_SEVEN_SIGNS_ID
        pc.inventory.add_item("SevenSigns", item_id, 1, pc, self)
      when 33 # participate request
        old_cabal = SevenSigns.get_player_cabal(pc.l2id)

        if old_cabal != SevenSigns::CABAL_NULL
          if is_a?(L2DawnPriestInstance)
            show_chat_window(pc, val, "dawn_member", false)
          else
            show_chat_window(pc, val, "dusk_member", false)
          end

          return
        elsif pc.class_id.level == 0
          if is_a?(L2DawnPriestInstance)
            show_chat_window(pc, val, "dawn_firstclass", false)
          else
            show_chat_window(pc, val, "dusk_firstclass", false)
          end

          return
        elsif cabal == SevenSigns::CABAL_DUSK && Config.alt_game_castle_dusk
          clan = pc.clan
          if clan && clan.castle_id > 0
            show_chat_window(pc, SevenSigns::SEVEN_SIGNS_HTML_PATH + "signs_33_dusk_no.htm")
            return # L2J uses break but there's no more code after when expr.
          end
        elsif cabal == SevenSigns::CABAL_DAWN && Config.alt_game_castle_dawn
          clan = pc.clan
          if clan.nil? || clan.castle_id == 0
            show_chat_window(pc, SevenSigns::SEVEN_SIGNS_HTML_PATH + "signs_33_dawn_fee.htm")
            return # L2J uses break but there's no more code after when expr.
          end
        end

        if is_a?(L2DawnPriestInstance)
          show_chat_window(pc, val, "dawn", false)
        else
          show_chat_window(pc, val, "dusk", false)
        end
      when 34 # pay participation fee request
        if pc.class_id.level > 0 && (pc.adena >= Config.ssq_join_dawn_adena_fee || pc.inventory.get_inventory_item_count(Config.ssq_manors_agreement_id, -1) > 0)
          show_chat_window(pc, SevenSigns::SEVEN_SIGNS_HTML_PATH + "signs_33_dawn.htm")
        else
          show_chat_window(pc, SevenSigns::SEVEN_SIGNS_HTML_PATH + "signs_33_dawn_no.htm")
        end
      when 3, 8 # join cabal intro 1, festival of darkness intro
        show_chat_window(pc, val, SevenSigns.get_cabal_short_name(cabal), false)
      when 4 # join a cabal
        new_seal = command.from(15).to_i

        if pc.class_id.level >= 1
          if cabal == SevenSigns::CABAL_DUSK && Config.alt_game_castle_dusk
            clan = pc.clan
            if clan && clan.castle_id > 0
              show_chat_window(pc, SevenSigns::SEVEN_SIGNS_HTML_PATH + "signs_33_dusk_no.htm")
              return
            end
          end

          if Config.alt_game_castle_dawn && cabal == SevenSigns::CABAL_DAWN
            allow_join_dawn = false

            if (clan = pc.clan) && clan.castle_id > 0
              allow_join_dawn = true
            elsif pc.destroy_item_by_item_id("SevenSigns", Config.ssq_manors_agreement_id, 1, self, true)
              allow_join_dawn = true
            elsif pc.reduce_adena("SevenSigns", Config.ssq_join_dawn_adena_fee, self, true)
              allow_join_dawn = true
            end

            unless allow_join_dawn
              show_chat_window(pc, SevenSigns::SEVEN_SIGNS_HTML_PATH + "signs_33_dawn_fee.htm")
              return
            end
          end
        end

        SevenSigns.set_player_info(pc.l2id, cabal, new_seal)

        if cabal == SevenSigns::CABAL_DAWN
          pc.send_packet(SystemMessageId::SEVENSIGNS_PARTECIPATION_DAWN)
        else
          pc.send_packet(SystemMessageId::SEVENSIGNS_PARTECIPATION_DUSK)
        end

        case new_seal
        when SevenSigns::SEAL_AVARICE
          pc.send_packet(SystemMessageId::FIGHT_FOR_AVARICE)
        when SevenSigns::SEAL_GNOSIS
          pc.send_packet(SystemMessageId::FIGHT_FOR_GNOSIS)
        when SevenSigns::SEAL_STRIFE
          pc.send_packet(SystemMessageId::FIGHT_FOR_STRIFE)
        else
          # automatically added
        end


        show_chat_window(pc, 4, SevenSigns.get_cabal_short_name(cabal), false)
      when 5
        if is_a?(L2DawnPriestInstance)
          if SevenSigns.get_player_cabal(pc.l2id) == SevenSigns::CABAL_NULL
            show_chat_window(pc, val, "dawn_no", false)
          else
            show_chat_window(pc, val, "dawn", false)
          end
        else
          if SevenSigns.get_player_cabal(pc.l2id) == SevenSigns::CABAL_NULL
            show_chat_window(pc, val, "dusk_no", false)
          else
            show_chat_window(pc, val, "dusk", false)
          end
        end
      when 21
        contrib_stone_id = command[14...18].to_i

        contrib_blue_stones = pc.inventory.get_item_by_item_id(SevenSigns::SEAL_STONE_BLUE_ID)
        contrib_green_stones = pc.inventory.get_item_by_item_id(SevenSigns::SEAL_STONE_GREEN_ID)
        contrib_red_stones = pc.inventory.get_item_by_item_id(SevenSigns::SEAL_STONE_RED_ID)

        contrib_blue_stone_count = contrib_blue_stones.try &.count || 0i64
        contrib_green_stone_count = contrib_green_stones.try &.count || 0i64
        contrib_red_stone_count = contrib_red_stones.try &.count || 0i64

        score = SevenSigns.get_player_contrib_score(pc.l2id)
        contribution_count = 0i64

        contrib_stones_found = false

        red_contrib = 0i64
        green_contrib = 0i64
        blue_contrib = 0i64

        begin
          contribution_count = command.from(19).to_i64
        rescue e
          error e

          if is_a?(L2DawnPriestInstance)
            show_chat_window(pc, 6, "dawn_failure", false)
          else
            show_chat_window(pc, 6, "dusk_failure", false)
          end

          return
        end

        case contrib_stone_id
        when SevenSigns::SEAL_STONE_BLUE_ID
          blue_contrib = (Config.alt_maximum_player_contrib - score) // SevenSigns::BLUE_CONTRIB_POINTS
          if blue_contrib > contrib_blue_stone_count
            blue_contrib = contribution_count
          end
        when SevenSigns::SEAL_STONE_GREEN_ID
          green_contrib = (Config.alt_maximum_player_contrib - score) // SevenSigns::GREEN_CONTRIB_POINTS
          if green_contrib > contrib_green_stone_count
            green_contrib = contribution_count
          end
        when SevenSigns::SEAL_STONE_RED_ID
          red_contrib = (Config.alt_maximum_player_contrib - score) // SevenSigns::RED_CONTRIB_POINTS
          if red_contrib > contrib_red_stone_count
            red_contrib = contribution_count
          end
        else
          # automatically added
        end


        if red_contrib > 0
          if pc.destroy_item_by_item_id("SevenSigns", SevenSigns::SEAL_STONE_RED_ID, red_contrib, self, false)
            contrib_stones_found = true
            sm = SystemMessage.s2_s1_disappeared
            sm.add_item_name(SevenSigns::SEAL_STONE_RED_ID)
            sm.add_long(red_contrib)
            pc.send_packet(sm)
          end
        end

        if green_contrib > 0
          if pc.destroy_item_by_item_id("SevenSigns", SevenSigns::SEAL_STONE_GREEN_ID, green_contrib, self, false)
            contrib_stones_found = true
            sm = SystemMessage.s2_s1_disappeared
            sm.add_item_name(SevenSigns::SEAL_STONE_GREEN_ID)
            sm.add_long(green_contrib)
            pc.send_packet(sm)
          end
        end

        if blue_contrib > 0
          if pc.destroy_item_by_item_id("SevenSigns", SevenSigns::SEAL_STONE_BLUE_ID, blue_contrib, self, false)
            contrib_stones_found = true
            sm = SystemMessage.s2_s1_disappeared
            sm.add_item_name(SevenSigns::SEAL_STONE_BLUE_ID)
            sm.add_long(blue_contrib)
            pc.send_packet(sm)
          end
        end

        if !contrib_stones_found
          if is_a?(L2DawnPriestInstance)
            show_chat_window(pc, 6, "dawn_low_stones", false)
          else
            show_chat_window(pc, 6, "dusk_low_stones", false)
          end
        else
          score = SevenSigns.add_player_stone_contrib(pc.l2id, blue_contrib, green_contrib, red_contrib)
          sm = SystemMessage.contrib_score_increased_s1
          sm.add_long(score)
          pc.send_packet(sm)

          if is_a?(L2DawnPriestInstance)
            show_chat_window(pc, 6, "dawn", false)
          else
            show_chat_window(pc, 6, "dusk", false)
          end
        end
      when 6 # contribute seal stones
        stone_type = command.from(13).to_i

        blue_stones = pc.inventory.get_item_by_item_id(SevenSigns::SEAL_STONE_BLUE_ID)
        green_stones = pc.inventory.get_item_by_item_id(SevenSigns::SEAL_STONE_GREEN_ID)
        red_stones = pc.inventory.get_item_by_item_id(SevenSigns::SEAL_STONE_RED_ID)

        blue_stone_count = blue_stones.try &.count || 0i64
        green_stone_count = green_stones.try &.count || 0i64
        red_stone_count = red_stones.try &.count || 0i64

        contrib_score = SevenSigns.get_player_contrib_score(pc.l2id)
        stones_found = false

        if contrib_score == Config.alt_maximum_player_contrib
          pc.send_packet(SystemMessageId::CONTRIB_SCORE_EXCEEDED)
          return
        end

        red_contrib_count = 0i64
        green_contrib_count = 0i64
        blue_contrib_count = 0i64

        stone_count_contr = 0i64
        stone_id_contr = 0

        case stone_type
        when 1
          contrib_stone_color = "Blue"
          stone_color_contr = "blue"
          stone_id_contr = SevenSigns::SEAL_STONE_BLUE_ID
          stone_count_contr = blue_stone_count
        when 2
          contrib_stone_color = "Green"
          stone_color_contr = "green"
          stone_id_contr = SevenSigns::SEAL_STONE_GREEN_ID
          stone_count_contr = green_stone_count
        when 3
          contrib_stone_color = "Red"
          stone_color_contr = "red"
          stone_id_contr = SevenSigns::SEAL_STONE_RED_ID
          stone_count_contr = red_stone_count
        when 4
          temp_contrib_count = contrib_score
          red_contrib_count = (Config.alt_maximum_player_contrib - temp_contrib_count) // SevenSigns::RED_CONTRIB_POINTS
          if red_contrib_count > red_stone_count
            red_contrib_count = red_stone_count
          end

          temp_contrib_count += red_contrib_count * SevenSigns::RED_CONTRIB_POINTS
          green_contrib_count = (Config.alt_maximum_player_contrib - temp_contrib_count) // SevenSigns::GREEN_CONTRIB_POINTS
          if green_contrib_count > green_stone_count
            green_contrib_count = green_stone_count
          end

          temp_contrib_count += green_contrib_count * SevenSigns::GREEN_CONTRIB_POINTS
          blue_contrib_count = (Config.alt_maximum_player_contrib - temp_contrib_count) // SevenSigns::BLUE_CONTRIB_POINTS
          if blue_contrib_count > blue_stone_count
            blue_contrib_count = blue_stone_count
          end

          if red_contrib_count > 0
            if pc.destroy_item_by_item_id("SevenSigns", SevenSigns::SEAL_STONE_RED_ID, red_contrib_count, self, false)
              stones_found = true
              sm = SystemMessage.s2_s1_disappeared
              sm.add_item_name(SevenSigns::SEAL_STONE_RED_ID)
              sm.add_long(red_contrib_count)
              pc.send_packet(sm)
            end
          end
          if green_contrib_count > 0
            if pc.destroy_item_by_item_id("SevenSigns", SevenSigns::SEAL_STONE_GREEN_ID, green_contrib_count, self, false)
              stones_found = true
              sm = SystemMessage.s2_s1_disappeared
              sm.add_item_name(SevenSigns::SEAL_STONE_GREEN_ID)
              sm.add_long(green_contrib_count)
              pc.send_packet(sm)
            end
          end
          if blue_contrib_count > 0
            if pc.destroy_item_by_item_id("SevenSigns", SevenSigns::SEAL_STONE_BLUE_ID, blue_contrib_count, self, false)
              stones_found = true
              sm = SystemMessage.s2_s1_disappeared
              sm.add_item_name(SevenSigns::SEAL_STONE_BLUE_ID)
              sm.add_long(blue_contrib_count)
              pc.send_packet(sm)
            end
          end

          if !stones_found
            if is_a?(L2DawnPriestInstance)
              show_chat_window(pc, val, "dawn_no_stones", false)
            else
              show_chat_window(pc, val, "dusk_no_stones", false)
            end
          else
            contrib_score = SevenSigns.add_player_stone_contrib(pc.l2id, blue_contrib_count, green_contrib_count, red_contrib_count)
            sm = SystemMessage.contrib_score_increased_s1
            sm.add_long(contrib_score)
            pc.send_packet(sm)

            if is_a?(L2DawnPriestInstance)
              show_chat_window(pc, 6, "dawn", false)
            else
              show_chat_window(pc, 6, "dusk", false)
            end
          end

          return
        else
          # automatically added
        end


        if is_a?(L2DawnPriestInstance)
          path = SevenSigns::SEVEN_SIGNS_HTML_PATH + "signs_6_dawn_contribute.htm"
        else
          path = SevenSigns::SEVEN_SIGNS_HTML_PATH + "signs_6_dusk_contribute.htm"
        end

        text = HtmCache.get_htm(pc, path)

        if text
          text = text.gsub("%contrib_stone_color%", contrib_stone_color)
          text = text.gsub("%stoneColor%", stone_color_contr)
          text = text.gsub("%stoneCount%", stone_count_contr)
          text = text.gsub("%stoneItemId%", stone_id_contr)
          text = text.gsub("%objectId%", l2id)

          html = NpcHtmlMessage.new(l2id)
          html.html = text
          pc.send_packet(html)
        else
          warn { "Problem with HTML text \"#{path}\"." }
        end
      when 7 # exchange ancient adena for adena
        ancient_adena = 0i64

        begin
          ancient_adena = command.from(13).strip.to_i64
        rescue e : ArgumentError
          show_chat_window(pc, SevenSigns::SEVEN_SIGNS_HTML_PATH + "blkmrkt_3.htm")
        rescue e : IndexError
          show_chat_window(pc, SevenSigns::SEVEN_SIGNS_HTML_PATH + "blkmrkt_3.htm")
        end

        if ancient_adena < 1
          show_chat_window(pc, SevenSigns::SEVEN_SIGNS_HTML_PATH + "blkmrkt_3.htm")
        end
        if ancient_adena_amount < ancient_adena
          show_chat_window(pc, SevenSigns::SEVEN_SIGNS_HTML_PATH + "blkmrkt_4.htm")
        end

        pc.reduce_ancient_adena("SevenSigns", ancient_adena, self, true)
        pc.add_adena("SevenSigns", ancient_adena, self, true)

        show_chat_window(pc, SevenSigns::SEVEN_SIGNS_HTML_PATH + "blkmrkt_5.htm")
      when 9 # receive contribution rewards
        return unless SevenSigns.seal_validation_period?

        player_cabal = SevenSigns.get_player_cabal(pc.l2id)
        winning_cabal = SevenSigns.cabal_highest_score

        return unless player_cabal == winning_cabal

        reward = SevenSigns.get_ancient_adena_reward(pc.l2id, true)
        if reward < 3
          if is_a?(L2DawnPriestInstance)
            show_chat_window(pc, 9, "dawn_b", false)
          else
            show_chat_window(pc, 9, "dusk_b", false)
          end

          return
        end

        pc.add_ancient_adena("SevenSigns", reward.to_i64, self, true)

        if is_a?(L2DawnPriestInstance)
          show_chat_window(pc, 9, "dawn_a", false)
        else
          show_chat_window(pc, 9, "dusk_a", false)
        end
      when 11 # teleport to hunting grounds
        begin
          port_info = command.from(14).strip
          st = port_info.split

          x = st.shift.to_i
          y = st.shift.to_i
          z = st.shift.to_i

          cost = st.shift.to_i64
          if cost > 0
            unless pc.reduce_ancient_adena("SevenSigns", cost, self, true)
              debug "#{pc} doesn't have enough Ancient Adena to teleport."
              return
            end
          end
          pc.tele_to_location(x, y, z)
        rescue e
          error e
        end
      when 16
        if is_a?(L2DawnPriestInstance)
          show_chat_window(pc, val, "dawn", false)
        else
          show_chat_window(pc, val, "dusk", false)
        end
      when 17 # exchange seal stones for ancient adena (type choice)
        stone_type = command.from(14).to_i

        stone_id = 0
        stone_count = 0i64
        stone_value = 0

        stone_color = nil

        case stone_type
        when 1
          stone_color = "blue"
          stone_id = SevenSigns::SEAL_STONE_BLUE_ID
          stone_value = SevenSigns::SEAL_STONE_BLUE_VALUE
        when 2
          stone_color = "green"
          stone_id = SevenSigns::SEAL_STONE_GREEN_ID
          stone_value = SevenSigns::SEAL_STONE_GREEN_VALUE
        when 3
          stone_color = "red"
          stone_id = SevenSigns::SEAL_STONE_RED_ID
          stone_value = SevenSigns::SEAL_STONE_RED_VALUE
        when 4
          blue_stones_all = pc.inventory.get_item_by_item_id(SevenSigns::SEAL_STONE_BLUE_ID)
          green_stones_all = pc.inventory.get_item_by_item_id(SevenSigns::SEAL_STONE_GREEN_ID)
          red_stones_all = pc.inventory.get_item_by_item_id(SevenSigns::SEAL_STONE_RED_ID)

          blue_stone_count_all = blue_stones_all.try &.count || 0i64
          green_stone_count_all = green_stones_all.try &.count || 0i64
          red_stone_count_all = red_stones_all.try &.count || 0i64

          ancient_adena_reward_all = SevenSigns.calc_ancient_adena_reward(blue_stone_count_all, green_stone_count_all, red_stone_count_all)

          if ancient_adena_reward_all == 0
            if is_a?(L2DawnPriestInstance)
              show_chat_window(pc, 18, "dawn_no_stones", false)
            else
              show_chat_window(pc, 18, "dusk_no_stones", false)
            end
          end

          if blue_stone_count_all > 0
            pc.destroy_item_by_item_id("SevenSigns", SevenSigns::SEAL_STONE_BLUE_ID, blue_stone_count_all, self, true)
          end

          if green_stone_count_all > 0
            pc.destroy_item_by_item_id("SevenSigns", SevenSigns::SEAL_STONE_GREEN_ID, green_stone_count_all, self, true)
          end

          if red_stone_count_all > 0
            pc.destroy_item_by_item_id("SevenSigns", SevenSigns::SEAL_STONE_RED_ID, red_stone_count_all, self, true)
          end

          pc.add_ancient_adena("SevenSigns", ancient_adena_reward_all, self, true)

          if is_a?(L2DawnPriestInstance)
            show_chat_window(pc, 18, "dawn", false)
          else
            show_chat_window(pc, 18, "dusk", false)
          end

          return
        else
          # automatically added
        end


        if stone_instance = pc.inventory.get_item_by_item_id(stone_id)
          stone_count = stone_instance.count
        end

        if is_a?(L2DawnPriestInstance)
          path = SevenSigns::SEVEN_SIGNS_HTML_PATH + "signs_17_dawn.htm"
        else
          path = SevenSigns::SEVEN_SIGNS_HTML_PATH + "signs_17_dusk.htm"
        end

        if content = HtmCache.get_htm(pc, path)
          content = content.gsub("%stoneColor%", stone_color)
          content = content.gsub("%stoneValue%", stone_value.to_s)
          content = content.gsub("%stoneCount%", stone_count.to_s)
          content = content.gsub("%stoneItemId%", stone_id.to_s)
          content = content.gsub("%objectId%", l2id.to_s)

          html = NpcHtmlMessage.new(l2id.to_s)
          html.html = content
          pc.send_packet(html)
        else
          warn { "Problem with HTML text #{SevenSigns::SEVEN_SIGNS_HTML_PATH} signs_17.htm: #{path}." }
        end
      when 18 # exchange seal stones for ancient adena
        convert_stone_id = command[14...18].to_i
        convert_count = 0i64

        begin
          convert_count = command.from(19).strip.to_i64
        rescue e : ArgumentError
          if is_a?(L2DawnPriestInstance)
            show_chat_window(pc, 18, "dawn_failed", false)
          else
            show_chat_window(pc, 18, "dusk_failed", false)
          end
        end

        convert_item = pc.inventory.get_item_by_item_id(convert_stone_id)

        if convert_item
          ancient_adena_reward = 0i64
          total_count = convert_item.count

          if convert_count <= total_count && convert_count > 0
            case convert_stone_id
            when SevenSigns::SEAL_STONE_BLUE_ID
              ancient_adena_reward = SevenSigns.calc_ancient_adena_reward(convert_count, 0, 0)
            when SevenSigns::SEAL_STONE_GREEN_ID
              ancient_adena_reward = SevenSigns.calc_ancient_adena_reward(0, convert_count, 0)
            when SevenSigns::SEAL_STONE_RED_ID
              ancient_adena_reward = SevenSigns.calc_ancient_adena_reward(0, 0, convert_count)
            else
              # automatically added
            end


            if pc.destroy_item_by_item_id("SevenSigns", convert_stone_id, convert_count, self, true)
              pc.add_ancient_adena("SevenSigns", ancient_adena_reward, self, true)

              if is_a?(L2DawnPriestInstance)
                show_chat_window(pc, 18, "dawn", false)
              else
                show_chat_window(pc, 18, "dusk", false)
              end
            end
          else
            if is_a?(L2DawnPriestInstance)
              show_chat_window(pc, 18, "dawn_low_stones", false)
            else
              show_chat_window(pc, 18, "dusk_low_stones", false)
            end
          end
        else
          if is_a?(L2DawnPriestInstance)
            show_chat_window(pc, 18, "dawn_no_stones", false)
          else
            show_chat_window(pc, 18, "dusk_no_stones", false)
          end
        end
      when 19 # choose seal (when joining a cabal)
        chosen_seal = command.from(16).to_i
        file_suffix = "#{SevenSigns.get_seal_name(chosen_seal, true)}_#{SevenSigns.get_cabal_short_name(cabal)}"
        show_chat_window(pc, val, file_suffix, false)
      when 20 # seal status (when joining a cabal)
        content = String.build do |io|
          if is_a?(L2DawnPriestInstance)
            io << "<html><body>Priest of Dawn:<br><font color=\"LEVEL\">[ Seal Status ]</font><br>"
          else
            io << "<html><body>Dusk Priestess:<br><font color=\"LEVEL\">[ Status of the Seals ]</font><br>"
          end

          1.upto(3) do |i|
            seal_owner = SevenSigns.get_seal_owner(i)
            if seal_owner != SevenSigns::CABAL_NULL
              io << '[' << SevenSigns.get_seal_name(i, false) << ": "
              io << SevenSigns.get_cabal_name(seal_owner) << "]<br>"
            else
              io << '[' << SevenSigns.get_seal_name(i, false)
              io << ": Nothingness]<br>"
            end
          end

          io << "<a action=\"bypass -h npc_"
          io << l2id
          io << "_Chat 0\">Go back.</a></body></html>"
        end

        html = NpcHtmlMessage.new(l2id)
        html.html = content
        pc.send_packet(html)
      else
        show_chat_window(pc, val, nil, false)
      end
    else
      super
    end
  end

  def show_chat_window(pc : L2PcInstance, val : Int32, suffix : String?, is_description : Bool)
    file_name = SevenSigns::SEVEN_SIGNS_HTML_PATH
    file_name += (is_description ? "desc_#{val}"    : "signs_#{val}")
    file_name += (suffix         ? "_#{suffix}.htm" : ".htm")

    super(pc, file_name)
  end
end