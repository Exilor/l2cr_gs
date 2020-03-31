require "../../models/date_range"
require "../../models/announcements/event_announcement"

class LongTimeEvent < Quest
  include XMLReader

  private record NpcSpawn, npc_id : Int32, loc : Location

  # NPCs to spawm and their spawn points
  private SPAWN_LIST = [] of NpcSpawn

  # Drop data for event
  private DROP_LIST = [] of GeneralDropItem

  @event_name = ""
  @on_enter_message = "Event is in process"
  @drop_period = DateRange.new

  getter event_period = DateRange.new
  protected getter end_message = "Event ends!"

  def initialize(name, descr)
    super(-1, name, descr)

    # load_config
    begin
      parse_datapack_file("scripts/events/#{name}/config.xml")
    rescue e
      error e
      return
    end

    if @event_period.within_range?(Time.now)
      start_event
      info { "Event #{@event_name} active until #{@event_period.end_date}." }
    elsif @event_period.start_date.after?(Time.now)
      delay = @event_period.start_date.ms - Time.ms
      ThreadPoolManager.schedule_general(ScheduleStart.new(self), delay)
      info { "Starting at #{@event_period.start_date}." }
    else
      info "Event has passed."
    end
  end

  private def parse_document(doc, file)
    doc = doc.first_element_child.not_nil!

    unless doc.name.casecmp?("event")
      raise "Bad config file #{file.path}"
    end

    @event_name = doc["name"]
    period = doc["active"]
    @event_period = DateRange.parse(period, "%d %m %Y")

    if drop_period = doc["dropPeriod"]?
      @drop_period = DateRange.parse(drop_period, "%d %m %Y")
      if !@event_period.within_range?(@drop_period.start_date) || !@event_period.within_range?(@drop_period.end_date)
        @drop_period = @event_period
      end
    else
      @drop_period = @event_period
    end

    today = Time.now

    if @event_period.start_date.after?(today) || @event_period.within_range?(today)
      doc.each_element do |n|
        # Loading droplist
        if n.name.casecmp?("droplist")
          n.each_element do |d|
            if d.name.casecmp?("add")
              begin
                item_id = d["item"].to_i
                min_count = d["min"].to_i64
                max_count = d["max"].to_i64
                chance = d["chance"]
                final_chance = 0.0

                if !chance.empty? && chance.ends_with?("%")
                  final_chance = chance[0...chance.size - 1].to_f * 10000
                end

                unless ItemTable[item_id]?
                  warn { "#{item_id} is wrong item id, item was not added in droplist." }
                  next
                end

                if min_count > max_count
                  warn { "Item #{item_id} - min greater than max, item was not added in droplist." }
                  next
                end

                unless final_chance.between?(10000, 1000000)
                  warn { "Item #{item_id} - incorrect drop chance, item was not added in droplist." }
                  next
                end

                DROP_LIST << DropListScope::STATIC.new_drop_item(item_id, min_count, max_count, final_chance).as(GeneralDropItem)
              rescue e
                warn { "Wrong number format in config.xml droplist block for #{name} event." }
              end
            end
          end
        elsif n.name.casecmp?("spawnlist")
          # Loading spawnlist
          n.each_element do |d|
            if d.name.casecmp?("add")
              begin
                npc_id = d["npc"].to_i
                x = d["x"].to_i
                y = d["y"].to_i
                z = d["z"].to_i
                heading = d["heading"]?.try &.to_i || 0

                unless NpcData[npc_id]?
                  warn { "NPC id #{npc_id} is wrong. NPC was not added in spawnlist" }
                  next
                end

                SPAWN_LIST << NpcSpawn.new(npc_id, Location.new(x, y, z, heading))
              rescue
                warn { "Wrong number format in config.xml spawnlist block for #{name} event." }
              end
            end
          end
        elsif n.name.casecmp?("messages")
          # Loading Messages
          n.each_element do |d|
            if d.name.casecmp?("add")
              if (msg_type = d["type"]?) && (msg_text = d["text"]?)
                if msg_type.casecmp?("onEnd")
                  @end_message = msg_text
                elsif msg_type.casecmp?("onEnter")
                  @on_enter_message = msg_text
                end
              end
            end
          end
        end
      end
    end
  end

  protected def start_event
    time = Time.ms
    # Add drop
    if time < @drop_period.end_date.ms
      DROP_LIST.each do |drop|
        EventDroplist.add_global_drop(
          drop.item_id,
          drop.min,
          drop.max,
          drop.chance.to_i,
          @drop_period
        )
      end
    end

    # Add spawns
    ms_to_end = @event_period.end_date.ms - time
    SPAWN_LIST.each do |sp|
      add_spawn(sp.npc_id, *sp.loc.xyz, sp.loc.heading, false, ms_to_end, false)
    end

    # Send message on begin
    Broadcast.to_all_online_players(@on_enter_message)

    # Add announce for entering players
    AnnouncementsTable.add_announcement(EventAnnouncement.new(@event_period, @on_enter_message))

    # Schedule event end (now only for message sending)
    ThreadPoolManager.schedule_general(ScheduleEnd.new(self), ms_to_end)
  end

  def is_event_period? : Bool
    @event_period.within_range?(Time.now)
  end

  def is_drop_period? : Bool
    @drop_period.within_range?(Time.now)
  end

  private struct ScheduleStart
    initializer event : LongTimeEvent

    def call
      @event.start_event
    end
  end

  private struct ScheduleEnd
    initializer event : LongTimeEvent

    def call
      Broadcast.to_all_online_players(@event.end_message)
    end
  end
end
