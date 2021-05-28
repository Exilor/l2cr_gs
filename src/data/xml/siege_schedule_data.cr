require "../../models/siege_schedule_date"

module SiegeScheduleData
  extend self
  extend XMLReader

  private DATES = [] of SiegeScheduleDate

  def load
    DATES.clear
    parse_datapack_file("../config/SiegeSchedule.xml")
    info { "Loaded #{DATES.size} siege schedules." }
    if DATES.empty?
      DATES << SiegeScheduleDate.new(StatsSet::EMPTY)
    end
  end

  def schedule_dates : Array(SiegeScheduleDate)
    DATES
  end

  private def parse_document(doc : XML::Node, file : File)
    find_element(doc, "list") do |n|
      find_element(n, "schedule") do |cd|
        set = StatsSet.new
        each_attribute(cd) do |key, val|
          if key == "day"
            val = get_value_for_field(val)
          end
          set[key] = val
        end

        DATES << SiegeScheduleDate.new(set)
      end
    end
  end

  private def get_value_for_field(field) : Int32
    case field.casecmp
    when "SUNDAY" then 1
    when "MONDAY" then 2
    when "TUESDAY" then 3
    when "WEDNESDAY" then 4
    when "THURSDAY" then 5
    when "FRIDAY" then 6
    when "SATURDAY" then 7
    else -1
    end
  end
end
