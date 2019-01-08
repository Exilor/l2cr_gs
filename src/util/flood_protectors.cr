require "./flood_protector_action"

class FloodProtectors
  getter use_item, roll_dice, firework, item_pet_summon, hero_voice, manor,
    global_chat, subclass, drop_item, server_bypass, multisell, transaction,
    send_mail, manufacture, character_select, item_auction


  def initialize(client : GameClient)
    @use_item = FloodProtectorAction.new(client, Config.flood_protector_use_item)
    @roll_dice = FloodProtectorAction.new(client, Config.flood_protector_roll_dice)
    @firework = FloodProtectorAction.new(client, Config.flood_protector_firework)
    @item_pet_summon = FloodProtectorAction.new(client, Config.flood_protector_item_pet_summon)
    @hero_voice = FloodProtectorAction.new(client, Config.flood_protector_hero_voice)
    @global_chat = FloodProtectorAction.new(client, Config.flood_protector_global_chat)
    @subclass = FloodProtectorAction.new(client, Config.flood_protector_subclass)
    @drop_item = FloodProtectorAction.new(client, Config.flood_protector_drop_item)
    @server_bypass = FloodProtectorAction.new(client, Config.flood_protector_server_bypass)
    @multisell = FloodProtectorAction.new(client, Config.flood_protector_multisell)
    @transaction = FloodProtectorAction.new(client, Config.flood_protector_transaction)
    @manufacture = FloodProtectorAction.new(client, Config.flood_protector_manufacture)
    @manor = FloodProtectorAction.new(client, Config.flood_protector_manor)
    @send_mail = FloodProtectorAction.new(client, Config.flood_protector_sendmail)
    @character_select = FloodProtectorAction.new(client, Config.flood_protector_character_select)
    @item_auction = FloodProtectorAction.new(client, Config.flood_protector_item_auction)
  end
end
