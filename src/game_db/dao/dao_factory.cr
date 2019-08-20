module GameDB
  module DAOFactory
    extend self
    extend Loggable

    private class_getter! factory : IDAOFactory

    def load
      # case Config.database_engine
      # when "MSSQL", "OracleDB", "PostgreSQL", "H2", "HSQLDB"
      #   raise "#{Config.database_engine} not supported"
      # end
      @@factory = MySQLDAOFactory
      # info { "Using #{@@factory}." }
    end

    def friend : FriendDAO
      factory.friend
    end

    def henna : HennaDAO
      factory.henna
    end

    def item : ItemDAO
      factory.item
    end

    def item_reuse : ItemReuseDAO
      factory.item_reuse
    end

    def pet : PetDAO
      factory.pet
    end

    def pet_skill_save : PetSkillSaveDAO
      factory.pet_skill_save
    end

    def player : PlayerDAO
      factory.player
    end

    def player_skill_save : PlayerSkillSaveDAO
      factory.player_skill_save
    end

    def premium_item : PremiumItemDAO
      factory.premium_item
    end

    def recipe_book : RecipeBookDAO
      factory.recipe_book
    end

    def recipe_shop_list : RecipeShopListDAO
      factory.recipe_shop_list
    end

    def recommendation_bonus : RecommendationBonusDAO
      factory.recommendation_bonus
    end

    def servitor_skill_save : ServitorSkillSaveDAO
      factory.servitor_skill_save
    end

    def shortcut : ShortcutDAO
      factory.shortcut
    end

    def skill : SkillDAO
      factory.skill
    end

    def subclass : SubclassDAO
      factory.subclass
    end

    def teleport_bookmark : TeleportBookmarkDAO
      factory.teleport_bookmark
    end
  end
end

require "./interfaces/*"
require "./impl/**"
