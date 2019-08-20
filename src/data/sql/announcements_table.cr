require "../../models/announcements/i_announcement"
require "../../models/announcements/announcement"
require "../../models/announcements/auto_announcement"

module AnnouncementsTable
  extend self
  extend Loggable

  private alias CreatureSay = Packets::Outgoing::CreatureSay
  private alias Say2 = Packets::Incoming::Say2

  private DATA = Hash(Int32, IAnnouncement).new

  def load
    DATA.clear

    GameDB.each("SELECT * FROM announcements") do |rs|
      type_id = rs.get_i32("type")
      type = AnnouncementType[type_id]
      case type
      when .normal?, .critical?
        announce = Announcement.new(rs)
      when .auto_normal?, .auto_critical?
        announce = AutoAnnouncement.new(rs)
      else
        next
      end

      DATA[announce.id] = announce
    end

    info { "Loaded #{DATA.size} announcements." }
  rescue e
    error e
  end

  def show_announcements(pc : L2PcInstance)
    send_announcements(pc, AnnouncementType::NORMAL)
    send_announcements(pc, AnnouncementType::CRITICAL)
    send_announcements(pc, AnnouncementType::EVENT)
  end

  def send_announcements(pc : L2PcInstance, type : AnnouncementType)
    DATA.each_value do |announce|
      if announce.valid? && announce.type == type
        if type.critical?
          say = Say2::CRITICAL_ANNOUNCE
        else
          say = Say2::ANNOUNCEMENT
        end

        pc.send_packet(CreatureSay.new(0, say, pc.name, announce.content))
      end
    end
  end

  def add_announcement(announce : IAnnouncement)
    if announce.store_me
      DATA[announce.id] = announce
    end
  end

  def delete_announcement(id : Int) : Bool
    announce = DATA.delete(id)
    !!announce && announce.delete_me
  end

  def get_announce(id : Int) : IAnnouncement?
    DATA[id]?
  end

  def all_announcements : Enumerable(IAnnouncement)
    DATA.local_each_value
  end
end
