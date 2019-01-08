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
      # info "Using #{@@factory}."
    end

    def friend
      factory.friend
    end

    def henna
      factory.henna
    end

    def item
      factory.item
    end

    def item_reuse
      factory.item_reuse
    end

    def pet
      factory.pet
    end

    def pet_skill_save
      factory.pet_skill_save
    end

    def player
      factory.player
    end

    def player_skill_save
      factory.player_skill_save
    end

    def premium_item
      factory.premium_item
    end

    def recipe_book
      factory.recipe_book
    end

    def recipe_shop_list
      factory.recipe_shop_list
    end

    def recommendation_bonus
      factory.recommendation_bonus
    end

    def servitor_skill_save
      factory.servitor_skill_save
    end

    def shortcut
      factory.shortcut
    end

    def skill
      factory.skill
    end

    def subclass
      factory.subclass
    end

    def teleport_bookmark
      factory.teleport_bookmark
    end
  end
end

require "./interfaces/*"
require "./impl/**"
