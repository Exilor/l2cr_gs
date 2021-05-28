require "./abstract_flags"

struct AttackableFlags < AbstractFlags
  flags(
    "seeded",
    "raid_minion",
    "absorbed",
    "overhit",
    "champion",
    "raid",
    "must_reward_exp_sp",
    "can_return_to_spawn_point",
    "returning_to_spawn_point",
    "can_see_through_silent_move"
  )
end
