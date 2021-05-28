require "../../models/date_range"
require "../../models/announcements/event_announcement"

class LongTimeEvent < Quest
  include XMLReader

  private record NpcSpawn, npc_id : Int32, loc : Location

  @event_name = ""
  @on_enter_message = "Event is in process"
  @drop_period = DateRange.new
  @spawn_list = [] of NpcSpawn
  @drop_list = [] of GeneralDropItem

  getter event_period = DateRange.new
  protected getter end_message = "Event ends!"

  def initialize(name, description)
    super(-1, name, description)

    begin
      parse_datapack_file("events/#{name}.xml")
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

  private def parse_document(doc : XML::Node, file : File)
    first_node = get_first_element_child(doc).not_nil!

    unless get_node_name(first_node).casecmp?("event")
      raise "Bad event config file " + file.path
    end

    @event_name = parse_string(first_node, "name")
    period = parse_string(first_node, "active")
    @event_period = DateRange.parse(period, "%d %m %Y")

    if drop_period = parse_string(first_node, "dropPeriod", nil)
      @drop_period = DateRange.parse(drop_period, "%d %m %Y")
      if !@event_period.within_range?(@drop_period.start_date) || !@event_period.within_range?(@drop_period.end_date)
        @drop_period = @event_period
      end
    else
      @drop_period = @event_period
    end

    today = Time.now

    if @event_period.start_date.after?(today) || @event_period.within_range?(today)
      each_element(first_node) do |n, n_name|
        if n_name.casecmp?("droplist")
          find_element(n, "add") do |d|
            begin
              item_id = parse_int(d, "item")
              min_count = parse_long(d, "min")
              max_count = parse_long(d, "max")
              chance = parse_string(d, "chance")
              final_chance = 0.0

              if !chance.empty? && chance.ends_with?("%")
                final_chance = chance[0...chance.size - 1].to_f * 10_000
              end

              unless ItemTable[item_id]?
                warn { "#{item_id} is wrong item id, item was not added in droplist." }
                next
              end

              if min_count > max_count
                warn { "Item #{item_id} - min greater than max, item was not added in droplist." }
                next
              end

              unless final_chance.between?(10_000, 1_000_000)
                warn { "Item #{item_id} - incorrect drop chance, item was not added in droplist." }
                next
              end

              @drop_list << DropListScope::STATIC.new_drop_item(item_id, min_count, max_count, final_chance).as(GeneralDropItem)
            rescue e
              warn { "Wrong number format in config.xml droplist block for #{name} event." }
            end
          end
        elsif n_name.casecmp?("spawnlist")
          find_element(n, "add") do |d|
            begin
              npc_id = parse_int(d, "npc")
              x = parse_int(d, "x")
              y = parse_int(d, "y")
              z = parse_int(d, "z")
              heading = parse_int(d, "heading", 0)

              unless NpcData[npc_id]?
                warn { "NPC id #{npc_id} is wrong. NPC was not added in spawnlist" }
                next
              end

              @spawn_list << NpcSpawn.new(npc_id, Location.new(x, y, z, heading))
            rescue
              warn { "Wrong number format in config.xml spawnlist block for #{name} event." }
            end
          end
        elsif n_name.casecmp?("messages")
          find_element(n, "add") do |d|
            msg_type = parse_string(d, "type", nil)
            msg_text = parse_string(d, "text", nil)
            if msg_type && msg_text
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

  protected def start_event
    time = Time.ms
    if time < @drop_period.end_date.ms
      @drop_list.each do |drop|
        EventDroplist.add_global_drop(
          drop.item_id,
          drop.min,
          drop.max,
          drop.chance.to_i,
          @drop_period
        )
      end
    end

    ms_to_end = @event_period.end_date.ms - time
    @spawn_list.each do |sp|
      add_spawn(sp.npc_id, *sp.loc.xyz, sp.loc.heading, false, ms_to_end, false)
    end

    Broadcast.to_all_online_players(@on_enter_message)
    AnnouncementsTable.add_announcement(EventAnnouncement.new(@event_period, @on_enter_message))
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
