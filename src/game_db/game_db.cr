require "db"
require "mysql"

require "./dao/dao_factory"

module GameDB
  extend self
  extend Loggable

  @@logdb = false
  private class_getter! db : DB::Database

  def load
    DAOFactory.load
    @@db = DB.open(Config.database_url)
    @@logdb = ARGV.includes?("logdb")
  end

  def close
    db.close
  end

  private struct LoggedTransaction
    initializer con : DB::Connection

    macro method_missing(call)
      GameDB.with_debug({{*call.args}}) do
        @con.{{call}}
      end
    end
  end

  def transaction
    # db.transaction { |tr| yield tr.connection }
    db.transaction { |tr| yield LoggedTransaction.new(tr.connection) }
  end

  def query_each(*args)
    with_debug(*args) { db.query_each(*args) { |rs| yield rs } }
  end

  def each(*args)
    query_each(*args) { |rs| yield ResultSetReader.new(rs) }
  end

  def exec(*args)
    with_debug(*args) { db.exec(*args) }
  end

  def scalar(*args)
    with_debug(*args) { db.scalar(*args) }
  end

  def prepare(sql : String)
    db.prepared(sql)
  end

  private def to_debug(sql : String, *args)
    i = -1
    sql.gsub("?") { args[i &+= 1] }
  end

  protected def with_debug(*args)
    if @@logdb
      timer = Timer.new
      ret = yield
      debug String.build { |io|
        io << '('
        io << timer.result(6)
        io << " s) "
        io << to_debug(*args)
      }
      ret
    else
      yield
    end
  end

  # DAO

  def friend : FriendDAO
    DAOFactory.friend
  end

  def henna : HennaDAO
    DAOFactory.henna
  end

  def item : ItemDAO
    DAOFactory.item
  end

  def item_reuse : ItemReuseDAO
    DAOFactory.item_reuse
  end

  def pet : PetDAO
    DAOFactory.pet
  end

  def pet_skill_save : PetSkillSaveDAO
    DAOFactory.pet_skill_save
  end

  def player : PlayerDAO
    DAOFactory.player
  end

  def player_skill_save : PlayerSkillSaveDAO
    DAOFactory.player_skill_save
  end

  def premium_item : PremiumItemDAO
    DAOFactory.premium_item
  end

  def recipe_book : RecipeBookDAO
    DAOFactory.recipe_book
  end

  def recipe_shop_list : RecipeShopListDAO
    DAOFactory.recipe_shop_list
  end

  def recommendation_bonus : RecommendationBonusDAO
    DAOFactory.recommendation_bonus
  end

  def servitor_skill_save : ServitorSkillSaveDAO
    DAOFactory.servitor_skill_save
  end

  def shortcut : ShortcutDAO
    DAOFactory.shortcut
  end

  def skill : SkillDAO
    DAOFactory.skill
  end

  def subclass : SubclassDAO
    DAOFactory.subclass
  end

  def teleport_bookmark : TeleportBookmarkDAO
    DAOFactory.teleport_bookmark
  end
end
