class Packets::Outgoing::SSQStatus < GameServerPacket
  initializer l2id : Int32, page : Int32

  private def write_impl
    winning_cabal = SevenSigns.instance.cabal_highest_score
    total_dawn_members = SevenSigns.instance.get_total_members(SevenSigns::CABAL_DAWN)
    total_dusk_members = SevenSigns.instance.get_total_members(SevenSigns::CABAL_DUSK)

    c 0xfb

    c @page
    c SevenSigns.instance.current_period

    dawn_percent = 0
    dusk_percent = 0

    case @page
    when 1
      d SevenSigns.instance.current_cycle

      current_period = SevenSigns.instance.current_period

      case current_period
      when SevenSigns::PERIOD_COMP_RECRUITING
        d SystemMessageId::INITIAL_PERIOD.id
      when SevenSigns::PERIOD_COMPETITION
        d SystemMessageId::SSQ_COMPETITION_UNDERWAY.id
      when SevenSigns::PERIOD_COMP_RESULTS
        d SystemMessageId::RESULTS_PERIOD.id
      when SevenSigns::PERIOD_SEAL_VALIDATION
        d SystemMessageId::VALIDATION_PERIOD.id
      else
        # [automatically added else]
      end


      case current_period
      when SevenSigns::PERIOD_COMP_RECRUITING, SevenSigns::PERIOD_COMP_RESULTS
        d SystemMessageId::UNTIL_TODAY_6PM.id
      when SevenSigns::PERIOD_COMPETITION, SevenSigns::PERIOD_SEAL_VALIDATION
        d SystemMessageId::UNTIL_MONDAY_6PM.id
      else
        # [automatically added else]
      end


      c SevenSigns.instance.get_player_cabal(@l2id)
      c SevenSigns.instance.get_player_seal(@l2id)
      q SevenSigns.instance.get_player_stone_contrib(@l2id)
      q SevenSigns.instance.get_player_adena_collect(@l2id)

      dawn_stone_score = SevenSigns.instance.get_current_stone_score(SevenSigns::CABAL_DAWN).to_f
      dawn_festival_score = SevenSigns.instance.get_current_festival_score(SevenSigns::CABAL_DAWN)
      dusk_stone_score = SevenSigns.instance.get_current_stone_score(SevenSigns::CABAL_DUSK).to_f
      dusk_festival_score = SevenSigns.instance.get_current_festival_score(SevenSigns::CABAL_DUSK)

      total_stone_score = dusk_stone_score + dawn_stone_score

      dusk_stone_score_prop = 0
      dawn_stone_score_prop = 0

      if total_stone_score != 0
        dusk_stone_score_prop = (dusk_stone_score.fdiv(total_stone_score) * 500).round.to_i
        dawn_stone_score_prop = (dawn_stone_score.fdiv(total_stone_score) * 500).round.to_i
      end

      dusk_total_score = SevenSigns.instance.get_current_score(SevenSigns::CABAL_DUSK)
      dawn_total_score = SevenSigns.instance.get_current_score(SevenSigns::CABAL_DAWN)

      total_overall_score = dusk_total_score + dawn_total_score

      if total_overall_score != 0
        dawn_percent = (dawn_total_score.fdiv(total_overall_score) * 100).to_i
        dusk_percent = (dusk_total_score.fdiv(total_overall_score) * 100).to_i
      end

      q dusk_stone_score_prop
      q dusk_festival_score
      q dusk_total_score

      c dusk_percent

      q dawn_stone_score_prop
      q dawn_festival_score
      q dawn_total_score

      c dawn_percent
    when 2
      h 1
      c 5 # nº of festivals

      5.times do |i|
        c i + 1 # festival id
        d SevenSignsFestival::FESTIVAL_LEVEL_SCORES[i]

        dusk_score = SevenSignsFestival.instance.get_highest_score(SevenSigns::CABAL_DUSK, i)
        dawn_score = SevenSignsFestival.instance.get_highest_score(SevenSigns::CABAL_DAWN, i)

        q dusk_score

        high_score_data = SevenSignsFestival.instance.get_highest_score_data(SevenSigns::CABAL_DUSK, i)
        party_members = high_score_data.get_string("members").split(',')

        if party_members.size > 0
          c party_members.size
          party_members.each { |m| s m }
        else
          c 0
        end

        q dawn_score

        high_score_data = SevenSignsFestival.instance.get_highest_score_data(SevenSigns::CABAL_DAWN, i)
        party_members = high_score_data.get_string("members").split(',')

        c party_members.size
        party_members.each { |m| s m }
      end
    when 3
      c 10 # Minimum limit for winning cabal to retain their seal
      c 35 # Minimum limit for winning cabal to claim a seal
      c 3  # Total number of seals

      1.upto(3) do |i|
        dawn_proportion = SevenSigns.instance.get_seal_proportion(i, SevenSigns::CABAL_DAWN)
        dusk_proportion = SevenSigns.instance.get_seal_proportion(i, SevenSigns::CABAL_DUSK)

        c i
        c SevenSigns.instance.get_seal_owner(i)

        if total_dusk_members == 0
          if total_dawn_members == 0
            c 0
            c 0
          else
            c 0
            c (dawn_proportion.fdiv(total_dawn_members) * 100).round.to_i
          end
        else
          if total_dawn_members == 0
            c (dusk_proportion.fdiv(total_dusk_members) * 100).round.to_i
            c 0
          else
            c (dusk_proportion.fdiv(total_dusk_members) * 100).round.to_i
            c (dawn_proportion.fdiv(total_dawn_members) * 100).round.to_i
          end
        end
      end
    when 4
      c winning_cabal # overall predicted winner
      c 3 # total number of seals

      1.upto(3) do |i|
        dawn_proportion = SevenSigns.instance.get_seal_proportion(i, SevenSigns::CABAL_DAWN)
        dusk_proportion = SevenSigns.instance.get_seal_proportion(i, SevenSigns::CABAL_DUSK)
        dawn_percent = dawn_proportion.fdiv(total_dawn_members == 0 ? 1 : total_dawn_members) * 100
        dusk_percent = dusk_proportion.fdiv(total_dusk_members == 0 ? 1 : total_dusk_members) * 100
        seal_owner = SevenSigns.instance.get_seal_owner(i)

        c i

        case seal_owner
        when SevenSigns::CABAL_NULL
          case winning_cabal
          when SevenSigns::CABAL_NULL
            c SevenSigns::CABAL_NULL
            d SystemMessageId::COMPETITION_TIE_SEAL_NOT_AWARDED.id
          when SevenSigns::CABAL_DAWN
            if dawn_percent >= 35
              c SevenSigns::CABAL_DAWN
              d SystemMessageId::SEAL_NOT_OWNED_35_MORE_VOTED.id
            else
              c SevenSigns::CABAL_NULL
              d SystemMessageId::SEAL_NOT_OWNED_35_LESS_VOTED.id
            end
          when SevenSigns::CABAL_DUSK
            if dusk_percent >= 35
              c SevenSigns::CABAL_DUSK
              d SystemMessageId::SEAL_NOT_OWNED_35_MORE_VOTED.id
            else
              c SevenSigns::CABAL_NULL
              d SystemMessageId::SEAL_NOT_OWNED_35_LESS_VOTED.id
            end
          else
            # [automatically added else]
          end

        when SevenSigns::CABAL_DAWN
          case winning_cabal
          when SevenSigns::CABAL_NULL
            if dawn_percent >= 10
              c SevenSigns::CABAL_DAWN
              d SystemMessageId::SEAL_OWNED_10_MORE_VOTED.id
            else
              c SevenSigns::CABAL_NULL
              d SystemMessageId::COMPETITION_TIE_SEAL_NOT_AWARDED.id
            end
          when SevenSigns::CABAL_DAWN
            if dawn_percent >= 10
              c seal_owner
              d SystemMessageId::SEAL_OWNED_10_MORE_VOTED.id
            else
              c SevenSigns::CABAL_NULL
              d SystemMessageId::SEAL_OWNED_10_LESS_VOTED.id
            end
          when SevenSigns::CABAL_DUSK
            if dusk_percent >= 35
              c SevenSigns::CABAL_DUSK
              d SystemMessageId::SEAL_NOT_OWNED_35_MORE_VOTED.id
            elsif dawn_percent >= 10
              c SevenSigns::CABAL_DAWN
              d SystemMessageId::SEAL_OWNED_10_MORE_VOTED.id
            else
              c SevenSigns::CABAL_NULL
              d SystemMessageId::SEAL_OWNED_10_LESS_VOTED.id
            end
          else
            # [automatically added else]
          end

        when SevenSigns::CABAL_DUSK
          case winning_cabal
          when SevenSigns::CABAL_NULL
            if dusk_percent >= 10
              c SevenSigns::CABAL_DUSK
              d SystemMessageId::SEAL_OWNED_10_MORE_VOTED.id
            else
              c SevenSigns::CABAL_NULL
              d SystemMessageId::COMPETITION_TIE_SEAL_NOT_AWARDED.id
            end
          when SevenSigns::CABAL_DAWN
            if dawn_percent >= 35
              c SevenSigns::CABAL_DAWN
              d SystemMessageId::SEAL_NOT_OWNED_35_MORE_VOTED.id
            elsif dusk_percent >= 10
              c seal_owner
              d SystemMessageId::SEAL_OWNED_10_MORE_VOTED.id
            else
              c SevenSigns::CABAL_NULL
              d SystemMessageId::SEAL_OWNED_10_LESS_VOTED.id
            end
          when SevenSigns::CABAL_DUSK
            if dusk_percent >= 10
              c seal_owner
              d SystemMessageId::SEAL_OWNED_10_MORE_VOTED.id
            else
              c SevenSigns::CABAL_NULL
              d SystemMessageId::SEAL_OWNED_10_LESS_VOTED.id
            end
          else
            # [automatically added else]
          end

        else
          # [automatically added else]
        end

      end
    else
      # [automatically added else]
    end

  end
end
