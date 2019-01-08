# unused

# struct OnKillNotifyTask
#   include Runnable

#   initializer attackable: L2Attackable?, quest: Quest?, killer: L2PcInstance?,
#     is_summon: Bool

#   def run
#     if @quest && @attackable && @killer
#       @quest.notify_kill(@attackable.not_nil!, @killer.not_nil!, @is_summon)
#     end
#   end
# end
