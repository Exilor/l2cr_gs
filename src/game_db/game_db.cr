require "db"
require "mysql"

require "./result_set_reader"
require "./dao/dao_factory"

module GameDB
  extend self
  extend Loggable

  private class_getter! db : DB::Database

  def load
    DAOFactory.load
    @@db = DB.open("mysql://root:00137955@localhost/l2gs")
  end

  def close
    db.close
  end

  def transaction
    db.transaction do |tr|
      yield db
   end
  end

  def query_each(*args)
    db.query_each(*args) { |rs| yield rs }
  end

  # def prepare
  #   db.prepare
  # end

  def each(*args)
    db.query_each(*args) { |rs| yield ResultSetReader.new(rs) }
  end

  def exec(*args)
    db.exec(*args)
  end

  def scalar(*args)
    db.scalar(*args)
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
