module GameDB
  module MySQLDAOFactory
    extend self
    extend IDAOFactory

    def friend : FriendDAO
      FriendDAOMySQLImpl
    end

    def henna : HennaDAO
      HennaDAOMySQLImpl
    end

    def item : ItemDAO
      ItemDAOMySQLImpl
    end

    def item_reuse : ItemReuseDAO
      ItemReuseDAOMySQLImpl
    end

    def pet : PetDAO
      PetDAOMySQLImpl
    end

    def pet_skill_save : PetSkillSaveDAO
      PetSkillSaveDAOMySQLImpl
    end

    def player : PlayerDAO
      PlayerDAOMySQLImpl
    end

    def player_skill_save : PlayerSkillSaveDAO
      PlayerSkillSaveDAOMySQLImpl
    end

    def premium_item : PremiumItemDAO
      PremiumItemDAOMySQLImpl
    end

    def recipe_book : RecipeBookDAO
      RecipeBookDAOMySQLImpl
    end

    def recipe_shop_list : RecipeShopListDAO
      RecipeShopListDAOMySQLImpl
    end

    def recommendation_bonus : RecommendationBonusDAO
      RecommendationBonusDAOMySQLImpl
    end

    def servitor_skill_save : ServitorSkillSaveDAO
      ServitorSkillSaveDAOMySQLImpl
    end

    def shortcut : ShortcutDAO
      ShortcutDAOMySQLImpl
    end

    def skill : SkillDAO
      SkillDAOMySQLImpl
    end

    def subclass : SubclassDAO
      SubclassDAOMySQLImpl
    end

    def teleport_bookmark : TeleportBookmarkDAO
      TeleportBookmarkDAOMySQLImpl
    end

    def couples : CouplesDAO
      CouplesDAOMySQLImpl
    end
  end
end
