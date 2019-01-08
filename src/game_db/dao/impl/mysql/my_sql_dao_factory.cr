module GameDB
  module MySQLDAOFactory
    extend self
    extend IDAOFactory

    def friend
      FriendDAOMySQLImpl
    end

    def henna
      HennaDAOMySQLImpl
    end

    def item
      ItemDAOMySQLImpl
    end

    def item_reuse
      ItemReuseDAOMySQLImpl
    end

    def pet
      PetDAOMySQLImpl
    end

    def pet_skill_save
      PetSkillSaveDAOMySQLImpl
    end

    def player
      PlayerDAOMySQLImpl
    end

    def player_skill_save
      PlayerSkillSaveDAOMySQLImpl
    end

    def premium_item
      PremiumItemDAOMySQLImpl
    end

    def recipe_book
      RecipeBookDAOMySQLImpl
    end

    def recipe_shop_list
      RecipeShopListDAOMySQLImpl
    end

    def recommendation_bonus
      RecommendationBonusDAOMySQLImpl
    end

    def servitor_skill_save
      ServitorSkillSaveDAOMySQLImpl
    end

    def shortcut
      ShortcutDAOMySQLImpl
    end

    def skill
      SkillDAOMySQLImpl
    end

    def subclass
      SubclassDAOMySQLImpl
    end

    def teleport_bookmark
      TeleportBookmarkDAOMySQLImpl
    end
  end
end
