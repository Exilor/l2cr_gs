require "../../models/siege_schedule_date"

module SiegeScheduleData
  extend self
  extend XMLReader

  private SCHEDULE_DATA = [] of SiegeScheduleDate

  def load
    SCHEDULE_DATA.clear
    parse_datapack_file("../config/SiegeSchedule.xml")
    info "Loaded #{SCHEDULE_DATA.size} siege schedules."
    if SCHEDULE_DATA.empty?
      SCHEDULE_DATA << SiegeScheduleDate.new(StatsSet::EMPTY)
    end
  end

  def schedule_dates
    SCHEDULE_DATA
  end

  private def parse_document(doc, file)
    doc.find_element("list") do |n|
      n.find_element("schedule") do |cd|
        set = StatsSet.new
        cd.attributes.each do |attr|
          key, val = attr.name, attr.text
          if key == "day"
            val = get_value_for_field(val)
          end
          set[key] = val
        end
        SCHEDULE_DATA << SiegeScheduleDate.new(set)
      end
    end
  end

  private def get_value_for_field(field : String)
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
