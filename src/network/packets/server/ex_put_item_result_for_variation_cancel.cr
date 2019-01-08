class Packets::Outgoing::ExPutItemResultForVariationCancel < GameServerPacket
  @item_id : Int32
  @item_obj_id : Int32
  @item_aug_1 : Int32
  @item_aug_2 : Int32

  def initialize(item : L2ItemInstance, @price : Int32)
    @item_obj_id = item.l2id
    @item_id = item.display_id
    @item_aug_1 = item.augmentation.augmentation_id
    @item_aug_2 = item.augmentation.augmentation_id >> 16
  end

  def write_impl
    c 0xfe
    h 0x57

    d @item_obj_id
    d @item_id
    d @item_aug_1
    d @item_aug_2
    q @price
    d 0x01
  end
end
