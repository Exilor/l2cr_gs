module GameDB
  module IDAOFactory
    abstract def friend : FriendDAO
    abstract def henna : HennaDAO
    abstract def item : ItemDAO
    abstract def item_reuse : ItemReuseDAO
    abstract def pet : PetDAO
    abstract def pet_skill_save : PetSkillSaveDAO
    abstract def player : PlayerDAO
    abstract def player_skill_save : PlayerSkillSaveDAO
    abstract def premium_item : PremiumItemDAO
    abstract def recipe_book : RecipeBookDAO
    abstract def recipe_shop_list : RecipeShopListDAO
    abstract def recommendation_bonus : RecommendationBonusDAO
    abstract def servitor_skill_save : ServitorSkillSaveDAO
    abstract def shortcut : ShortcutDAO
    abstract def skill : SkillDAO
    abstract def subclass : SubclassDAO
    abstract def teleport_bookmark : TeleportBookmarkDAO
  end
end
