require "./action_handler"
require "./action_shift_handler"
require "./effect_handler"
require "./target_handler"
require "./item_handler"
require "./bypass_handler"
require "./chat_handler"
require "./user_command_handler"
require "./admin_command_handler"
require "./community_board_handler"
require "./punishment_handler"

module MasterHandler
  def self.load
    ActionHandler.load
    ActionShiftHandler.load
    EffectHandler.load
    TargetHandler.load
    ItemHandler.load
    BypassHandler.load
    ChatHandler.load
    UserCommandHandler.load
    AdminCommandHandler.load
    CommunityBoardHandler.load
    PunishmentHandler.load
  end
end
