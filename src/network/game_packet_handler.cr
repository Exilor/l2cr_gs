require "./packets/game_client_packet"
require "./packets/client/*"

module GamePacketHandler
  extend self
  extend MMO::IPacketHandler(GameClient)
  extend MMO::IPacketExecutor(GameClient)
  extend MMO::IClientFactory(GameClient)
  extend Loggable
  include Packets::Incoming

  def self.handle(buffer : ByteBuffer, client : GameClient) : MMO::IncomingPacket(GameClient)?
    if client.drop_packet
      debug { "Packet dropped (#{client})." }
      return
    end

    opcode = buffer.read_bytes(UInt8)
    state = client.state

    packet_type =
    case state
    when .connected?
      case opcode
      when 0x0e then ProtocolVersion
      when 0x2b then AuthLogin
      else
        print_debug(opcode, buffer, state, client)
      end
    when .authed?
      case opcode
      when 0x00 then Logout
      when 0x0c then CharacterCreate
      when 0x0d then CharacterDelete
      when 0x12 then CharacterSelect
      when 0x13 then NewCharacter
      when 0x7b then CharacterRestore
      when 0xd0
        if buffer.remaining < 2
          warn { "#{client} sent a 0xd0 without the second opcode." }
          return
        end
        case op2 = buffer.read_bytes(UInt16)
        when 0x36 then RequestGoToLobby
        when 0x93 then RequestEx2ndPasswordCheck
        when 0x94 then RequestEx2ndPasswordVerify
        when 0x95 then RequestEx2ndPasswordReq
        else
          print_debug_double_opcode(opcode, op2, buffer, state, client)
        end
      else
        print_debug(opcode, buffer, state, client)
      end
    when .joining?
      case opcode
      when 0x11 then EnterWorld
      when 0x12 # CharacterSelect
      when 0xd0
        if buffer.remaining < 2
          warn { "#{client} sent a 0xd0 without the second opcode." }
          return
        end
        case op2 = buffer.read_bytes(UInt16)
        when 0x01 then RequestManorList
        when 0x21 then RequestKeyMapping      # L2J forgot about this one
        when 0x3d then RequestAllFortressInfo # L2J forgot about this one
        else
          print_debug_double_opcode(opcode, op2, buffer, state, client)
        end
      else
        print_debug(opcode, buffer, state, client)
      end
    when .in_game?
      case opcode
      when 0x00 then Logout
      when 0x01 then Attack
      when 0x03 then RequestStartPledgeWar
      when 0x04 then RequestReplyStartPledgeWar
      when 0x05 then RequestStopPledgeWar
      when 0x06 then RequestReplyStopPledgeWar
      when 0x07 then RequestSurrenderPledgeWar
      when 0x08 then RequestReplySurrenderPledgeWar
      when 0x09 then RequestSetPledgeCrest
      when 0x0b then RequestGiveNickName
      when 0x0f then MoveBackwardToLocation
      when 0x10 # Say
      when 0x12 # CharacterSelect ("Start" was spammed when AUTHED)
        debug "Ignoring duplicate CharacterSelect packet."
      when 0x14 then RequestItemList
      when 0x15 # RequestEquipItem
        warn "Received obsolete RequestEquipItem packet."
        client.handle_cheat("used obsolete RequestEquipItem packet")
      when 0x16 then RequestUnEquipItem
      when 0x17 then RequestDropItem
      when 0x19 then UseItem
      when 0x1a then TradeRequest
      when 0x1b then AddTradeItem
      when 0x1c then TradeDone # l2j: "TradeDone"
      when 0x1f then Action
      when 0x22 then RequestLinkHtml
      when 0x23 then RequestBypassToServer
      when 0x24 then RequestBBSwrite
      when 0x25 # RequestCreatePledge
      when 0x26 then RequestJoinPledge
      when 0x27 then RequestAnswerJoinPledge
      when 0x28 then RequestWithdrawalPledge
      when 0x29 then RequestOustPledgeMember
      when 0x2c then RequestGetItemFromPet
      when 0x2e then RequestAllyInfo
      when 0x2f then RequestCrystallizeItem
      when 0x30 then RequestPrivateStoreManageSell
      when 0x31 then SetPrivateStoreListSell
      when 0x32 then AttackRequest
      when 0x33 # RequestTeleportPacket
      when 0x34 # RequestSocialAction
        warn "Received obsolete RequestSocialAction packet."
        client.handle_cheat("used obsolete RequestSocialAction packet")
      when 0x35 # ChangeMoveType2
        warn "Received obsolete ChangeMoveType packet."
        client.handle_cheat("used obsolete ChangeMoveType packet")
      when 0x36 # ChangeWaitType2
        warn "Received obsolete ChangeWaitType packet."
        client.handle_cheat("used obsolete ChangeWaitType packet")
      when 0x37 then RequestSellItem
      when 0x38 # RequestMagicSkillList
      when 0x39 then RequestMagicSkillUse
      when 0x3a then Appearing
      when 0x3b
        if Config.allow_warehouse
          SendWareHouseDepositList
        end
      when 0x3c then SendWareHouseWithDrawList
      when 0x3d then RequestShortcutRegister
      when 0x3f then RequestShortcutDelete
      when 0x40 then RequestBuyItem
      when 0x41 # RequestDismissPledge
      when 0x42 then RequestJoinParty
      when 0x43 then RequestAnswerJoinParty
      when 0x44 then RequestWithdrawalParty
      when 0x45 then RequestOustPartyMember
      when 0x46 # RequestDismissParty
      when 0x47 then CannotMoveAnymore
      when 0x48 then RequestTargetCancel
      when 0x49 then Say2
      when 0x4a
        if buffer.remaining < 2
          warn { "#{client} sent a 0x4a without the second opcode." }
          return
        end
        case op2 = buffer.read_bytes(UInt16)
        when 0x00 # SuperCmdCharacterInfo
        when 0x01 # SuperCmdSummonCmd
        when 0x02 # SuperCmdServerStatus
        when 0x03 # SendL2ParamSetting
        else
          print_debug_double_opcode(opcode, op2, buffer, state, client)
        end
      when 0x4d then RequestPledgeMemberList
      when 0x4f # RequestMagicList
      when 0x50 then RequestSkillList
      when 0x52 then MoveWithDelta
      when 0x53 then RequestGetOnVehicle
      when 0x54 then RequestGetOffVehicle
      when 0x55 then AnswerTradeRequest
      when 0x56 then RequestActionUse
      when 0x57 then RequestRestart
      when 0x58 then RequestSiegeInfo
      when 0x59 then ValidatePosition
      when 0x5a # RequestSEKCustom
      when 0x5b then StartRotating
      when 0x5c then FinishRotating
      when 0x5e then RequestShowBoard
      when 0x5f then RequestEnchantItem
      when 0x60 then RequestDestroyItem
      when 0x62 then RequestQuestList
      when 0x63 then RequestQuestAbort # RequestDestroyQuest
      when 0x65 then RequestPledgeInfo
      when 0x66 then RequestPledgeExtendedInfo
      when 0x67 then RequestPledgeCrest
      when 0x6b then RequestSendFriendMsg # RequestSendL2FriendSay
      when 0x6c then RequestShowMiniMap
      when 0x6d                        # RequestSendMsnChatLog
      when 0x6e then RequestRecordInfo # RequestReload
      when 0x6f then RequestHennaEquip
      when 0x70 then RequestHennaRemoveList
      when 0x71 then RequestHennaItemRemoveInfo
      when 0x72 then RequestHennaRemove
      when 0x73 then RequestAcquireSkillInfo
      when 0x74 then SendBypassBuildCMD
      when 0x75 then RequestMoveToLocationInVehicle
      when 0x76 then CannotMoveAnymoreInVehicle
      when 0x77 then RequestFriendInvite
      when 0x78 then RequestAnswerFriendInvite # RequestFriendAddReply
      when 0x79 then RequestFriendList
      when 0x7a then RequestFriendDel
      when 0x7c then RequestAcquireSkill
      when 0x7d then RequestRestartPoint
      when 0x7e then RequestGMCommand
      when 0x7f then RequestPartyMatchConfig
      when 0x80 then RequestPartyMatchList
      when 0x81 then RequestPartyMatchDetail
      when 0x83 then RequestPrivateStoreBuy # SendPrivateStoreBuyList
      when 0x85 then RequestTutorialLinkHtml
      when 0x86 then RequestTutorialPassCmdToServer
      when 0x87 then RequestTutorialQuestionMark
      when 0x88 then RequestTutorialClientEvent
      when 0x89 then RequestPetition
      when 0x8a then RequestPetitionCancel
      when 0x8b then RequestGmList
      when 0x8c then RequestJoinAlly
      when 0x8d then RequestAnswerJoinAlly
      when 0x8e then AllyLeave   # RequestWithdrawAlly
      when 0x8f then AllyDismiss # RequestOustAlly
      when 0x90 then RequestDismissAlly
      when 0x91 then RequestSetAllyCrest
      when 0x92 then RequestAllyCrest
      when 0x93 then RequestChangePetName
      when 0x94 then RequestPetUseItem
      when 0x95 then RequestGiveItemToPet
      when 0x96 then RequestPrivateStoreQuitSell
      when 0x97 then SetPrivateStoreMsgSell
      when 0x98 then RequestPetGetItem
      when 0x99 then RequestPrivateStoreManageBuy
      when 0x9a then SetPrivateStoreListBuy # SetPrivateStoreList
      when 0x9c then RequestPrivateStoreQuitBuy
      when 0x9d then SetPrivateStoreMsgBuy
      when 0x9f then RequestPrivateStoreSell # SendPrivateStoreBuyList
      when 0xa0                              # SendTimeCheckPacket
      when 0xa6                              # RequestSkillCoolTime
      when 0xa7 then RequestPackageSendableItemList
      when 0xa8 then RequestPackageSend
      when 0xa9 then RequestBlock
      when 0xaa then RequestSiegeInfo
      when 0xab then RequestSiegeAttackerList # RequestCastleSiegeAttackerList
      when 0xac then RequestSiegeDefenderList
      when 0xad then RequestJoinSiege               # RequestJoinCastleSiege
      when 0xae then RequestConfirmSiegeWaitingList # RequestConfirmCastleSiegeWaitingList
      when 0xAF then RequestSetCastleSiegeTime
      when 0xb0 then MultisellChoose
      when 0xb1 # NetPing
      when 0xb2 # RequestRemainTime
      when 0xb3 then BypassUserCmd
      when 0xb4 then SnoopQuit
      when 0xb5 then RequestRecipeBookOpen
      when 0xb6 then RequestRecipeBookDestroy # RequestRecipeItemDelete
      when 0xb7 then RequestRecipeItemMakeInfo
      when 0xb8 then RequestRecipeItemMakeSelf
      when 0xb9 # RequestRecipeShopManageList
      when 0xba then RequestRecipeShopMessageSet
      when 0xbb then RequestRecipeShopListSet
      when 0xbc then RequestRecipeShopManageQuit
      when 0xbd # RequestRecipeShopManageCancel
      when 0xbe then RequestRecipeShopMakeInfo
      when 0xbf then RequestRecipeShopMakeItem   # RequestRecipeShopMakeDo
      when 0xc0 then RequestRecipeShopManagePrev # RequestRecipeShopSellList
      when 0xc1 then ObserverReturn              # RequestObserverEndPacket
      when 0xc2                                  # Unused (RequestEvaluate/VoteSociality)
      when 0xc3 then RequestHennaItemList
      when 0xc4 then RequestHennaItemInfo
      when 0xc5 then RequestBuySeed
      when 0xc6 then DlgAnswer          # ConfirmDlg
      when 0xc7 then RequestPreviewItem # RequestPreviewItem
      when 0xc8 then RequestSSQStatus
      when 0xc9 then RequestPetitionFeedback
      when 0xcb then GameGuardReply
      when 0xcc then RequestPledgePower
      when 0xcd then RequestMakeMacro
      when 0xce then RequestDeleteMacro
      when 0xcf # RequestProcureCrop -> RequestBuyProcure
      when 0xd0
        if buffer.remaining < 2
          warn { "#{client} sent a 0xd0 without the second opcode." }
          return
        end
        case op2 = buffer.read_bytes(UInt16)
        when 0x01 then RequestManorList
        when 0x02 then RequestProcureCropList
        when 0x03 then RequestSetSeed
        when 0x04 then RequestSetCrop
        when 0x05 then RequestWriteHeroWords
        when 0x5F
          # Server Packets: ExMpccRoomInfo FE:9B ExListMpccWaiting FE:9C ExDissmissMpccRoom FE:9D ExManageMpccRoomMember FE:9E ExMpccRoomMember FE:9F
          # TODO: RequestJoinMpccRoom chdd
        when 0x5D # TODO: RequestListMpccWaiting chddd
        when 0x5E # TODO: RequestManageMpccRoom chdddddS
        when 0x06 then RequestExAskJoinMPCC
        when 0x07 then RequestExAcceptJoinMPCC
        when 0x08 then RequestExOustFromMPCC
        when 0x09 then RequestOustFromPartyRoom
        when 0x0a then RequestDismissPartyRoom
        when 0x0b then RequestWithdrawPartyRoom
        when 0x0c then RequestChangePartyLeader
        when 0x0d then RequestAutoSoulShot
        when 0x0e then RequestExEnchantSkillInfo
        when 0x0f then RequestExEnchantSkill
        when 0x10 then RequestExPledgeCrestLarge
        when 0x11 then RequestExSetPledgeCrestLarge
        when 0x12 then RequestPledgeSetAcademyMaster
        when 0x13 then RequestPledgePowerGradeList
        when 0x14 then RequestPledgeMemberPowerInfo
        when 0x15 then RequestPledgeSetMemberPowerGrade
        when 0x16 then RequestPledgeMemberInfo
        when 0x17 then RequestPledgeWarList
        when 0x18 then RequestExFishRanking
        when 0x19 then RequestPCCafeCouponUse
        when 0x1b then RequestDuelStart
        when 0x1c then RequestDuelAnswerStart
        when 0x1d # RequestExSetTutorial
        when 0x1e then RequestExRqItemLink
        when 0x1f # CanNotMoveAnymoreAirship
        when 0x20 then MoveToLocationInAirship
        when 0x21 then RequestKeyMapping
        when 0x22 then RequestSaveKeyMapping
        when 0x23 then RequestExRemoveItemAttribute
        when 0x24 then RequestSaveInventoryOrder
        when 0x25 then RequestExitPartyMatchingWaitingRoom
        when 0x26 then RequestConfirmTargetItem
        when 0x27 then RequestConfirmRefinerItem
        when 0x28 then RequestConfirmGemStone
        when 0x29 then RequestOlympiadObserverEnd
        when 0x2a then RequestCursedWeaponList
        when 0x2b then RequestCursedWeaponLocation
        when 0x2c then RequestPledgeReorganizeMember
        when 0x2d then RequestExMPCCShowPartyMembersInfo
        when 0x2e then RequestOlympiadMatchList
        when 0x2f then RequestAskJoinPartyRoom
        when 0x30 then AnswerJoinPartyRoom
        when 0x31 then RequestListPartyMatchingWaitingRoom
        when 0x32 then RequestExEnchantSkillSafe
        when 0x33 then RequestExEnchantSkillUntrain
        when 0x34 then RequestExEnchantSkillRouteChange
        when 0x35 then RequestExEnchantItemAttribute
        when 0x36 then ExGetOnAirship
        when 0x38 then MoveToLocationAirship
        when 0x39 then RequestBidItemAuction
        when 0x3a then RequestInfoItemAuction
        when 0x3b then RequestExChangeName
        when 0x3c then RequestAllCastleInfo
        when 0x3d then RequestAllFortressInfo
        when 0x3e then RequestAllAgitInfo
        when 0x3f then RequestFortressSiegeInfo
        when 0x40 then RequestGetBossRecord
        when 0x41 then RequestRefine
        when 0x42 then RequestConfirmCancelItem
        when 0x43 then RequestRefineCancel
        when 0x44 then RequestExMagicSkillUseGround
        when 0x45 then RequestDuelSurrender
        when 0x46 then RequestExEnchantSkillInfoDetail
        when 0x48 then RequestFortressMapInfo
        when 0x49 # RequestPVPMatchRecord
        when 0x4a then SetPrivateStoreWholeMsg
        when 0x4b then RequestDispel
        when 0x4c then RequestExTryToPutEnchantTargetItem
        when 0x4d then RequestExTryToPutEnchantSupportItem
        when 0x4e then RequestExCancelEnchantItem
        when 0x4f then RequestChangeNicknameColor
        when 0x50 then RequestResetNickname
        when 0x51
          if buffer.remaining < 2
            warn { "#{client} sent a 0xd0:0x51 without the third opcode." }
            return
          end
          case op3 = buffer.read_bytes(UInt16)
          when 0x00 then RequestBookMarkSlotInfo
          when 0x01 then RequestSaveBookMarkSlot
          when 0x02 then RequestModifyBookMarkSlot
          when 0x03 then RequestDeleteBookMarkSlot
          when 0x04 then RequestTeleportBookMark
          when 0x05 # RequestChangeBookMarkSlot
          else
            print_debug_double_opcode(opcode, op3, buffer, state, client)
          end
        when 0x52 then RequestWithDrawPremiumItem
        when 0x53 # RequestJump
        when 0x54 # RequestStartShowCrataeCubeRank
        when 0x55 # RequestStopShowCrataeCubeRank
        when 0x56 # NotifyStartMiniGame
        when 0x57 then RequestJoinDominionWar
        when 0x58 then RequestDominionInfo
        when 0x59 # RequestExCleftEnter
        when 0x5a then RequestExCubeGameChangeTeam
        when 0x5b then EndScenePlayer
        when 0x5c then RequestExCubeGameReadyAnswer
        when 0x63 then RequestSeedPhase
        when 0x65 then RequestPostItemList
        when 0x66 then RequestSendPost
        when 0x67 then RequestReceivedPostList
        when 0x68 then RequestDeleteReceivedPost
        when 0x69 then RequestReceivedPost
        when 0x6a then RequestPostAttachment
        when 0x6b then RequestRejectPostAttachment
        when 0x6c then RequestSentPostList
        when 0x6d then RequestDeleteSentPost
        when 0x6e then RequestSentPost
        when 0x6f then RequestCancelPostAttachment
        when 0x70 # RequestShowNewUserPetition
        when 0x71 # RequestShowStepThree
        when 0x72 # RequestShowStepTwo
        when 0x73 # ExRaidReserveResult
        when 0x75 then RequestRefundItem
        when 0x76 then RequestBuySellUIClose
        when 0x77 # RequestEventMatchObserverEnd
        when 0x78 then RequestPartyLootModification
        when 0x79 then AnswerPartyLootModification
        when 0x7a then AnswerCoupleAction
        when 0x7b then BrEventRankerList
        when 0x7c # AskMembership
        when 0x7d # RequestAddExpandQuestAlarm
        when 0x7e then RequestVoteNew
        when 0x84 then RequestExAddContactToContactList
        when 0x85 then RequestExDeleteContactFromContactList
        when 0x86 then RequestExShowContactList
        when 0x87 then RequestExFriendListExtended
        when 0x88 then RequestExOlympiadMatchListRefresh
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
        end
      else
        print_debug(opcode, buffer, state, client)
      end
    end

    if packet_type.is_a?(GameClientPacket.class)
      packet_type.new
    end
  end

  private def print_debug(opcode, buf, state, client)
    client.on_unknown_packet
    return unless Config.packet_handler_debug
    size = buf.remaining
    warn { "Unknown packet 0x#{opcode.to_s(16)} on state #{state} of client #{client}." }
  end

  private def print_debug_double_opcode(op1, op2, buf, state, client)
    client.on_unknown_packet
    return unless Config.packet_handler_debug
    size = buf.remaining
    warn { "Unknown packet 0x#{op1.to_s(16)}:0x#{op2.to_s(16)} on state #{state} of client #{client}." }
  end

  def self.execute(gcp : MMO::IncomingPacket(GameClient))
    gcp.client.execute(gcp)
  end

  def self.create(con : MMO::Connection(GameClient)) : GameClient
    GameClient.new(con)
  end
end
