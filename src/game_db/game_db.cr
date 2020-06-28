require "db"
require "mysql"

module GameDB
  extend self
  extend Loggable

  private class_getter! db : DBConnector(self.class)
  private class_getter! dao_factory : IDAOFactory

  def load
    @@db = DBConnector.new(DB.open(Config.database_url), self)
    db.log = ARGV.includes?("logdb")

    case engine = Config.database_engine
    when "MSSQL", "OracleDB", "PostgreSQL", "H2", "HSQLDB"
      raise engine + " not supported"
    when "MySQL"
      @@dao_factory = MySQLDAOFactory
    else
      raise "Unknown database engine " + engine
    end

    info { "Using #{Config.database_engine}." }
  end

  delegate transaction, query_each, each, exec, scalar, prepare, close,
    "log=", to: db

  delegate friend, henna, item, item_reuse, pet, pet_skill_save, player, skill,
    player_skill_save, premium_item, recipe_book, recipe_shop_list, shortcut,
    servitor_skill_save, recommendation_bonus, subclass, teleport_bookmark,
    to: dao_factory
end

require "./dao/interfaces/*"
require "./dao/impl/**"
