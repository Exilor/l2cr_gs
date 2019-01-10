# System messages
Java:

  ```player.sendPacket(SystemMessageId.TARGET_IN_PEACEZONE)```
  
  ```SystemMessage sm = SystemMessage.getSystemMessage(SystemMessageId.C1_EVADED_C2_ATTACK)```
  
  ```ConfirmDlg dlg = new ConfirmDlg(SystemMessageId.RESURRECT_USING_CHARM_OF_COURAGE.getId())```
  
  ```SystemMessage sm = SystemMessage.getSystemMessage(134)```
  
Crystal:

  ```player.send_packet(SystemMessageId::TARGET_IN_PEACEZONE)```
  
  ```sm = SystemMessage.c1_evaded_c2_attack```
  
  ```dlg = ConfirmDlg.resurrect_using_charm_of_courage```
  
  ```sm = SystemMessage[134]```
  
# Config
Java:

  ```Config.GM_SKILL_RESTRICTION```
  
Crystal:

  ```Config.gm_skill_restriction```
  
# Methods with ```!``` and ```?```

The general rule is that a method ending with ```?``` can return nil and the other can raise. The rule is broken when there's a method with the same name that returns a boolean, in which case the method that can return nil doesn't end with ```?``` and the method that can raise ends with ```!```.

Examples:

| Java (nilable) | Java (predicate) | Crystal (nilable) | Crystal (raises) | Crystal (predicate) |
| --- | --- | --- | --- | --- |
| ```getActingPlayer``` | ```isPlayer``` | ```acting_player?``` | ```acting_player``` | ```player?``` |
| ```getSummon``` | ```isSummon``` | ```summon``` | ```summon!``` | ```summon?``` |
| ```getVehicle``` | ```isVehicle``` | ```vehicle``` | ```vehicle!``` | ```vehicle?``` |
| ```getTransformation``` | ```isTransformed``` | ```transformation?``` | ```transformation``` | ```transformed?``` |
| ```getWorldRegion``` | --- | ```world_region?``` | ```world_region``` | --- |

# Convenience methods

| Java | Crystal 1 | Crystal 2 |
| --- | --- | --- |
| ```isInsideZone?(ZoneId.PVP)``` | ```inside_zone?(ZoneId::PVP)``` | ```inside_pvp_zone?``` |
| ```canOverrideCond(PcCondOverride.DEATH_PENALTY)``` | ```override_cond?(PcCondOverride::DEATH_PENALTY)``` | ```override_death_penalty?``` |
| ```!player.isDead?``` | ```!player.dead?``` | ```player.alive?``` |
| ```player.setCurrentHp(player.getMaxHp())``` | ```player.current_hp = player.max_hp``` | ```player.max_hp!``` |
| ```inv.getPaperdollItem(L2Item.PAPERDOLL_LHAND)``` | ```inv.get_paperdoll_item(L2Item::LHAND)``` | ```inv.lhand_slot``` |
| ```inv.setPaperdollItem(L2Item.PAPERDOLL_LHAND, item)``` | ```inv.set_paperdoll_item(L2Item::LHAND, item)``` | ```inv.lhand_slot = item``` |
| ```inv.getPaperdollItem(slot)``` | ```inv.get_paperdoll_item(slot)``` | ```inv[slot]``` |
| ```inv.isPaperdollSlotEmpty(L2Item.PAPERDOLL_LHAND)``` | ```inv.slot_empty?(L2Item::LHAND)``` | ```inv.lhand_slot_empty?``` |
| ```getQuestState(questName, true).isCompleted()``` | ```get_quest_state(quest_name, true).not_nil!.completed?``` | ```get_quest_state!(quest_name).completed?``` |
