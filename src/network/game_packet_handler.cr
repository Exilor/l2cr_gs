require "./packets/game_client_packet"
require "./packets/client/*"

module GamePacketHandler
  extend self
  extend MMO::IPacketHandler(GameClient)
  extend MMO::IPacketExecutor(GameClient)
  extend MMO::IClientFactory(GameClient)
  extend Loggable
  include Packets::Incoming

  def handle(buffer : ByteBuffer, client : GameClient) : MMO::IncomingPacket(GameClient)?
    if client.drop_packet
      debug { "Packet dropped (#{client})." }
      return
    end

    opcode = buffer.read_bytes(UInt8)
    state = client.state

    case state
    when .connected?
      case opcode
      when 0x0e then ProtocolVersion.new
      when 0x2b then AuthLogin.new
      else
        print_debug(opcode, buffer, state, client)
        nil
      end
    when .authed?
      case opcode
      when 0x00 then Logout.new
      when 0x0c then CharacterCreate.new
      when 0x0d then CharacterDelete.new
      when 0x12 then CharacterSelect.new
      when 0x13 then NewCharacter.new
      when 0x7b then CharacterRestore.new
      when 0xd0
        if buffer.remaining < 2
          warn { "#{client} sent a 0xd0 without the second opcode." }
          nil
        end
        case op2 = buffer.read_bytes(UInt16)
        when 0x36 then RequestGoToLobby.new
        when 0x93 then RequestEx2ndPasswordCheck.new
        when 0x94 then RequestEx2ndPasswordVerify.new
        when 0x95 then RequestEx2ndPasswordReq.new
        else
          print_debug_double_opcode(opcode, op2, buffer, state, client)
          nil
        end
      else
        print_debug(opcode, buffer, state, client)
        nil
      end
    when .joining?
      case opcode
      when 0x11 then EnterWorld.new
      when 0x12 # CharacterSelect
      when 0xcb # GameGuardReply
      when 0xd0
        if buffer.remaining < 2
          warn { "#{client} sent a 0xd0 without the second opcode." }
          nil
        end
        case op2 = buffer.read_bytes(UInt16)
        when 0x01 then RequestManorList.new
        when 0x21 then RequestKeyMapping.new # L2J forgot about this one
        when 0x3d then RequestAllFortressInfo.new # L2J forgot about this one
        else
          print_debug_double_opcode(opcode, op2, buffer, state, client)
          nil
        end
      else
        print_debug(opcode, buffer, state, client)
        nil
      end
    when .in_game?
      case opcode
      when 0x00 then Logout.new
      when 0x01 then Attack.new
      when 0x03 then RequestStartPledgeWar.new
      when 0x04 then RequestReplyStartPledgeWar.new
      when 0x05 then RequestStopPledgeWar.new
      when 0x06 then RequestReplyStopPledgeWar.new
      when 0x07 then RequestSurrenderPledgeWar.new
      when 0x08 then RequestReplySurrenderPledgeWar.new
      when 0x09 then RequestSetPledgeCrest.new
      when 0x0b then RequestGiveNickName.new
      when 0x0f then MoveBackwardToLocation.new
      when 0x10 # Say
      when 0x12 # CharacterSelect ("Start" was spammed when AUTHED)
        debug "Ignoring duplicate CharacterSelect packet."
        nil
      when 0x14 then RequestItemList.new
      when 0x15 # RequestEquipItem
        warn { "Received obsolete RequestEquipItem packet from #{client}." }
        client.handle_cheat("used obsolete RequestEquipItem packet")
        nil
      when 0x16 then RequestUnEquipItem.new
      when 0x17 then RequestDropItem.new
      when 0x19 then UseItem.new
      when 0x1a then TradeRequest.new
      when 0x1b then AddTradeItem.new
      when 0x1c then TradeDone.new
      when 0x1f then Action.new
      when 0x22 then RequestLinkHtml.new
      when 0x23 then RequestBypassToServer.new
      when 0x24 then RequestBBSwrite.new
      when 0x25 # RequestCreatePledge
      when 0x26 then RequestJoinPledge.new
      when 0x27 then RequestAnswerJoinPledge.new
      when 0x28 then RequestWithdrawalPledge.new
      when 0x29 then RequestOustPledgeMember.new
      when 0x2c then RequestGetItemFromPet.new
      when 0x2e then RequestAllyInfo.new
      when 0x2f then RequestCrystallizeItem.new
      when 0x30 then RequestPrivateStoreManageSell.new
      when 0x31 then SetPrivateStoreListSell.new
      when 0x32 then AttackRequest.new
      when 0x33 # RequestTeleportPacket
      when 0x34 # RequestSocialAction
        warn { "Received obsolete RequestSocialAction packet from #{client}." }
        client.handle_cheat("used obsolete RequestSocialAction packet")
        nil
      when 0x35 # ChangeMoveType2
        warn { "Received obsolete ChangeMoveType packet from #{client}." }
        client.handle_cheat("used obsolete ChangeMoveType packet")
        nil
      when 0x36 # ChangeWaitType2
        warn { "Received obsolete ChangeWaitType packet from #{client}." }
        client.handle_cheat("used obsolete ChangeWaitType packet")
        nil
      when 0x37 then RequestSellItem.new
      when 0x38 # RequestMagicSkillList
      when 0x39 then RequestMagicSkillUse.new
      when 0x3a then Appearing.new
      when 0x3b
        if Config.allow_warehouse
          SendWareHouseDepositList.new
        end
      when 0x3c then SendWareHouseWithDrawList.new
      when 0x3d then RequestShortcutRegister.new
      when 0x3f then RequestShortcutDelete.new
      when 0x40 then RequestBuyItem.new
      when 0x41 # RequestDismissPledge
      when 0x42 then RequestJoinParty.new
      when 0x43 then RequestAnswerJoinParty.new
      when 0x44 then RequestWithdrawalParty.new
      when 0x45 then RequestOustPartyMember.new
      when 0x46 # RequestDismissParty
      when 0x47 then CannotMoveAnymore.new
      when 0x48 then RequestTargetCancel.new
      when 0x49 then Say2.new
      when 0x4a
        if buffer.remaining < 2
          warn { "#{client} sent a 0x4a without the second opcode." }
          nil
        end
        case op2 = buffer.read_bytes(UInt16)
        when 0x00 # SuperCmdCharacterInfo
        when 0x01 # SuperCmdSummonCmd
        when 0x02 # SuperCmdServerStatus
        when 0x03 # SendL2ParamSetting
        else
          print_debug_double_opcode(opcode, op2, buffer, state, client)
          nil
        end
      when 0x4d then RequestPledgeMemberList.new
      when 0x4f # RequestMagicList
      when 0x50 then RequestSkillList.new
      when 0x52 then MoveWithDelta.new
      when 0x53 then RequestGetOnVehicle.new
      when 0x54 then RequestGetOffVehicle.new
      when 0x55 then AnswerTradeRequest.new
      when 0x56 then RequestActionUse.new
      when 0x57 then RequestRestart.new
      when 0x58 then RequestSiegeInfo.new
      when 0x59 then ValidatePosition.new
      when 0x5a # RequestSEKCustom
      when 0x5b then StartRotating.new
      when 0x5c then FinishRotating.new
      when 0x5e then RequestShowBoard.new
      when 0x5f then RequestEnchantItem.new
      when 0x60 then RequestDestroyItem.new
      when 0x62 then RequestQuestList.new
      when 0x63 then RequestQuestAbort.new # RequestDestroyQuest
      when 0x65 then RequestPledgeInfo.new
      when 0x66 then RequestPledgeExtendedInfo.new
      when 0x67 then RequestPledgeCrest.new
      when 0x6b then RequestSendFriendMsg.new # RequestSendL2FriendSay
      when 0x6c then RequestShowMiniMap.new
      when 0x6d # RequestSendMsnChatLog
      when 0x6e then RequestRecordInfo.new # RequestReload
      when 0x6f then RequestHennaEquip.new
      when 0x70 then RequestHennaRemoveList.new
      when 0x71 then RequestHennaItemRemoveInfo.new
      when 0x72 then RequestHennaRemove.new
      when 0x73 then RequestAcquireSkillInfo.new
      when 0x74 then SendBypassBuildCMD.new
      when 0x75 then RequestMoveToLocationInVehicle.new
      when 0x76 then CannotMoveAnymoreInVehicle.new
      when 0x77 then RequestFriendInvite.new
      when 0x78 then RequestAnswerFriendInvite.new # RequestFriendAddReply
      when 0x79 then RequestFriendList.new
      when 0x7a then RequestFriendDel.new
      when 0x7c then RequestAcquireSkill.new
      when 0x7d then RequestRestartPoint.new
      when 0x7e then RequestGMCommand.new
      when 0x7f then RequestPartyMatchConfig.new
      when 0x80 then RequestPartyMatchList.new
      when 0x81 then RequestPartyMatchDetail.new
      when 0x83 then RequestPrivateStoreBuy.new # SendPrivateStoreBuyList
      when 0x85 then RequestTutorialLinkHtml.new
      when 0x86 then RequestTutorialPassCmdToServer.new
      when 0x87 then RequestTutorialQuestionMark.new
      when 0x88 then RequestTutorialClientEvent.new
      when 0x89 then RequestPetition.new
      when 0x8a then RequestPetitionCancel.new
      when 0x8b then RequestGmList.new
      when 0x8c then RequestJoinAlly.new
      when 0x8d then RequestAnswerJoinAlly.new
      when 0x8e then AllyLeave.new # RequestWithdrawAlly
      when 0x8f then AllyDismiss.new # RequestOustAlly
      when 0x90 then RequestDismissAlly.new
      when 0x91 then RequestSetAllyCrest.new
      when 0x92 then RequestAllyCrest.new
      when 0x93 then RequestChangePetName.new
      when 0x94 then RequestPetUseItem.new
      when 0x95 then RequestGiveItemToPet.new
      when 0x96 then RequestPrivateStoreQuitSell.new
      when 0x97 then SetPrivateStoreMsgSell.new
      when 0x98 then RequestPetGetItem.new
      when 0x99 then RequestPrivateStoreManageBuy.new
      when 0x9a then SetPrivateStoreListBuy.new # SetPrivateStoreList
      when 0x9c then RequestPrivateStoreQuitBuy.new
      when 0x9d then SetPrivateStoreMsgBuy.new
      when 0x9f then RequestPrivateStoreSell.new # SendPrivateStoreBuyList
      when 0xa0 # SendTimeCheckPacket
      when 0xa6 # RequestSkillCoolTime
      when 0xa7 then RequestPackageSendableItemList.new
      when 0xa8 then RequestPackageSend.new
      when 0xa9 then RequestBlock.new
      when 0xaa then RequestSiegeInfo.new
      when 0xab then RequestSiegeAttackerList.new # RequestCastleSiegeAttackerList
      when 0xac then RequestSiegeDefenderList.new
      when 0xad then RequestJoinSiege.new # RequestJoinCastleSiege
      when 0xae then RequestConfirmSiegeWaitingList.new # RequestConfirmCastleSiegeWaitingList
      when 0xAF then RequestSetCastleSiegeTime.new
      when 0xb0 then MultisellChoose.new
      when 0xb1 # NetPing
      when 0xb2 # RequestRemainTime
      when 0xb3 then BypassUserCmd.new
      when 0xb4 then SnoopQuit.new
      when 0xb5 then RequestRecipeBookOpen.new
      when 0xb6 then RequestRecipeBookDestroy.new # RequestRecipeItemDelete
      when 0xb7 then RequestRecipeItemMakeInfo.new
      when 0xb8 then RequestRecipeItemMakeSelf.new
      when 0xb9 # RequestRecipeShopManageList
      when 0xba then RequestRecipeShopMessageSet.new
      when 0xbb then RequestRecipeShopListSet.new
      when 0xbc then RequestRecipeShopManageQuit.new
      when 0xbd # RequestRecipeShopManageCancel
      when 0xbe then RequestRecipeShopMakeInfo.new
      when 0xbf then RequestRecipeShopMakeItem.new # RequestRecipeShopMakeDo
      when 0xc0 then RequestRecipeShopManagePrev.new # RequestRecipeShopSellList
      when 0xc1 then ObserverReturn.new # RequestObserverEndPacket
      when 0xc2                                  # Unused (RequestEvaluate/VoteSociality)
      when 0xc3 then RequestHennaItemList.new
      when 0xc4 then RequestHennaItemInfo.new
      when 0xc5 then RequestBuySeed.new
      when 0xc6 then DlgAnswer.new # ConfirmDlg
      when 0xc7 then RequestPreviewItem.new
      when 0xc8 then RequestSSQStatus.new
      when 0xc9 then RequestPetitionFeedback.new
      when 0xcb then GameGuardReply.new
      when 0xcc then RequestPledgePower.new
      when 0xcd then RequestMakeMacro.new
      when 0xce then RequestDeleteMacro.new
      when 0xcf # RequestProcureCrop -> RequestBuyProcure
      when 0xd0
        if buffer.remaining < 2
          warn { "#{client} sent a 0xd0 without the second opcode." }
          nil
        end
        case op2 = buffer.read_bytes(UInt16)
        when 0x01 then RequestManorList.new
        when 0x02 then RequestProcureCropList.new
        when 0x03 then RequestSetSeed.new
        when 0x04 then RequestSetCrop.new
        when 0x05 then RequestWriteHeroWords.new
        when 0x5F
          # Server Packets: ExMpccRoomInfo FE:9B ExListMpccWaiting FE:9C ExDissmissMpccRoom FE:9D ExManageMpccRoomMember FE:9E ExMpccRoomMember FE:9F
          # TODO: RequestJoinMpccRoom chdd
        when 0x5D # TODO: RequestListMpccWaiting chddd
        when 0x5E # TODO: RequestManageMpccRoom chdddddS
        when 0x06 then RequestExAskJoinMPCC.new
        when 0x07 then RequestExAcceptJoinMPCC.new
        when 0x08 then RequestExOustFromMPCC.new
        when 0x09 then RequestOustFromPartyRoom.new
        when 0x0a then RequestDismissPartyRoom.new
        when 0x0b then RequestWithdrawPartyRoom.new
        when 0x0c then RequestChangePartyLeader.new
        when 0x0d then RequestAutoSoulShot.new
        when 0x0e then RequestExEnchantSkillInfo.new
        when 0x0f then RequestExEnchantSkill.new
        when 0x10 then RequestExPledgeCrestLarge.new
        when 0x11 then RequestExSetPledgeCrestLarge.new
        when 0x12 then RequestPledgeSetAcademyMaster.new
        when 0x13 then RequestPledgePowerGradeList.new
        when 0x14 then RequestPledgeMemberPowerInfo.new
        when 0x15 then RequestPledgeSetMemberPowerGrade.new
        when 0x16 then RequestPledgeMemberInfo.new
        when 0x17 then RequestPledgeWarList.new
        when 0x18 then RequestExFishRanking.new
        when 0x19 then RequestPCCafeCouponUse.new
        when 0x1b then RequestDuelStart.new
        when 0x1c then RequestDuelAnswerStart.new
        when 0x1d # RequestExSetTutorial
        when 0x1e then RequestExRqItemLink.new
        when 0x1f # CanNotMoveAnymoreAirship
        when 0x20 then MoveToLocationInAirship.new
        when 0x21 then RequestKeyMapping.new
        when 0x22 then RequestSaveKeyMapping.new
        when 0x23 then RequestExRemoveItemAttribute.new
        when 0x24 then RequestSaveInventoryOrder.new
        when 0x25 then RequestExitPartyMatchingWaitingRoom.new
        when 0x26 then RequestConfirmTargetItem.new
        when 0x27 then RequestConfirmRefinerItem.new
        when 0x28 then RequestConfirmGemStone.new
        when 0x29 then RequestOlympiadObserverEnd.new
        when 0x2a then RequestCursedWeaponList.new
        when 0x2b then RequestCursedWeaponLocation.new
        when 0x2c then RequestPledgeReorganizeMember.new
        when 0x2d then RequestExMPCCShowPartyMembersInfo.new
        when 0x2e then RequestOlympiadMatchList.new
        when 0x2f then RequestAskJoinPartyRoom.new
        when 0x30 then AnswerJoinPartyRoom.new
        when 0x31 then RequestListPartyMatchingWaitingRoom.new
        when 0x32 then RequestExEnchantSkillSafe.new
        when 0x33 then RequestExEnchantSkillUntrain.new
        when 0x34 then RequestExEnchantSkillRouteChange.new
        when 0x35 then RequestExEnchantItemAttribute.new
        when 0x36 then ExGetOnAirship.new
        when 0x38 then MoveToLocationAirship.new
        when 0x39 then RequestBidItemAuction.new
        when 0x3a then RequestInfoItemAuction.new
        when 0x3b then RequestExChangeName.new
        when 0x3c then RequestAllCastleInfo.new
        when 0x3d then RequestAllFortressInfo.new
        when 0x3e then RequestAllAgitInfo.new
        when 0x3f then RequestFortressSiegeInfo.new
        when 0x40 then RequestGetBossRecord.new
        when 0x41 then RequestRefine.new
        when 0x42 then RequestConfirmCancelItem.new
        when 0x43 then RequestRefineCancel.new
        when 0x44 then RequestExMagicSkillUseGround.new
        when 0x45 then RequestDuelSurrender.new
        when 0x46 then RequestExEnchantSkillInfoDetail.new
        when 0x48 then RequestFortressMapInfo.new
        when 0x49 # RequestPVPMatchRecord
        when 0x4a then SetPrivateStoreWholeMsg.new
        when 0x4b then RequestDispel.new
        when 0x4c then RequestExTryToPutEnchantTargetItem.new
        when 0x4d then RequestExTryToPutEnchantSupportItem.new
        when 0x4e then RequestExCancelEnchantItem.new
        when 0x4f then RequestChangeNicknameColor.new
        when 0x50 then RequestResetNickname.new
        when 0x51
          if buffer.remaining < 2
            warn { "#{client} sent a 0xd0:0x51 without the third opcode." }
            nil
          end
          case op3 = buffer.read_bytes(UInt16)
          when 0x00 then RequestBookMarkSlotInfo.new
          when 0x01 then RequestSaveBookMarkSlot.new
          when 0x02 then RequestModifyBookMarkSlot.new
          when 0x03 then RequestDeleteBookMarkSlot.new
          when 0x04 then RequestTeleportBookMark.new
          when 0x05 # RequestChangeBookMarkSlot
          else
            print_debug_double_opcode(opcode, op3, buffer, state, client)
            nil
          end
        when 0x52 then RequestWithDrawPremiumItem.new
        when 0x53 # RequestJump
        when 0x54 # RequestStartShowCrataeCubeRank
        when 0x55 # RequestStopShowCrataeCubeRank
        when 0x56 # NotifyStartMiniGame
        when 0x57 then RequestJoinDominionWar.new
        when 0x58 then RequestDominionInfo.new
        when 0x59 # RequestExCleftEnter
        when 0x5a then RequestExCubeGameChangeTeam.new
        when 0x5b then EndScenePlayer.new
        when 0x5c then RequestExCubeGameReadyAnswer.new
        when 0x63 then RequestSeedPhase.new
        when 0x65 then RequestPostItemList.new
        when 0x66 then RequestSendPost.new
        when 0x67 then RequestReceivedPostList.new
        when 0x68 then RequestDeleteReceivedPost.new
        when 0x69 then RequestReceivedPost.new
        when 0x6a then RequestPostAttachment.new
        when 0x6b then RequestRejectPostAttachment.new
        when 0x6c then RequestSentPostList.new
        when 0x6d then RequestDeleteSentPost.new
        when 0x6e then RequestSentPost.new
        when 0x6f then RequestCancelPostAttachment.new
        when 0x70 # RequestShowNewUserPetition
        when 0x71 # RequestShowStepThree
        when 0x72 # RequestShowStepTwo
        when 0x73 # ExRaidReserveResult
        when 0x75 then RequestRefundItem.new
        when 0x76 then RequestBuySellUIClose.new
        when 0x77 # RequestEventMatchObserverEnd
        when 0x78 then RequestPartyLootModification.new
        when 0x79 then AnswerPartyLootModification.new
        when 0x7a then AnswerCoupleAction.new
        when 0x7b then BrEventRankerList.new
        when 0x7c # AskMembership
        when 0x7d # RequestAddExpandQuestAlarm
        when 0x7e then RequestVoteNew.new
        when 0x84 then RequestExAddContactToContactList.new
        when 0x85 then RequestExDeleteContactFromContactList.new
        when 0x86 then RequestExShowContactList.new
        when 0x87 then RequestExFriendListExtended.new
        when 0x88 then RequestExOlympiadMatchListRefresh.new
        when 0x89 # RequestBRGamePoint
        when 0x8a # RequestBRProductList
        when 0x8b # RequestBRProductInfo
        when 0x8c # RequestBRBuyProduct
        when 0x8d # RequestBRRecentProductList
        when 0x8e # BrMinigameLoadScores
        when 0x8f # BrMinigameInsertScore
        when 0x90 # BrLectureMark
        when 0x91 # RequestGoodsInventoryInfo
        when 0x92 # RequestUseGoodsInventoryItem
        else
          print_debug_double_opcode(opcode, op2, buffer, state, client)
          nil
        end
      else
        print_debug(opcode, buffer, state, client)
        nil
      end
    end
  end

  private def print_debug(opcode, buf, state, client)
    client.on_unknown_packet
    return unless Config.packet_handler_debug
    warn { "Unknown packet 0x#{opcode.to_s(16)} on state #{state} of client #{client}." }
  end

  private def print_debug_double_opcode(op1, op2, buf, state, client)
    client.on_unknown_packet
    return unless Config.packet_handler_debug
    warn { "Unknown packet 0x#{op1.to_s(16)}:0x#{op2.to_s(16)} on state #{state} of client #{client}." }
  end

  def execute(gcp : MMO::IncomingPacket(GameClient))
    gcp.client.execute(gcp)
  end

  def create(con : MMO::Connection(GameClient)) : GameClient
    GameClient.new(con)
  end
end
