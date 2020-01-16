require "../../../models/ui_keys_settings"

class Packets::Outgoing::ExUISetting < GameServerPacket
  @buff_size = 0
  @categories = 0
  @ui_settings : UIKeysSettings

  def initialize(pc : L2PcInstance)
    @ui_settings = pc.ui_settings
    calc_size
  end

  private def calc_size
    size = 16
    category = 0
    num_key_ct = @ui_settings.keys.size
    num_key_ct.times do |i|
      size += 1
      if temp = @ui_settings.categories[category]?
        size += temp.size
      end
      category += 1
      size += 1
      if temp = @ui_settings.categories[category]?
        size += temp.size
      end
      category += 1
      size += 4
      if temp = @ui_settings.keys[i]?
        size += temp.size * 20
      end
    end

    @buff_size = size
    @categories = category
  end

  private def write_impl
    c 0xfe
    h 0x70

    d @buff_size
    d @categories

    category = 0
    num_key_ct = @ui_settings.keys.size

    d num_key_ct

    num_key_ct.times do |i|
      if temp = @ui_settings.categories[category]?
        c temp.size
        temp.each { |cmd| c cmd }
      else
        c 0
      end

      category += 1

      if temp = @ui_settings.categories[category]?
        c temp.size
        temp.each { |cmd| c cmd }
      else
        c 0
      end

      category += 1

      if temp = @ui_settings.keys[i]?
        d temp.size
        temp.each do |akey|
          d akey.command_id
          d akey.key_id
          d akey.toggle_key1
          d akey.toggle_key2
          d akey.show_status
        end
      else
        d 0
      end
    end

    d 0x11
    d 0x10
  end
end
