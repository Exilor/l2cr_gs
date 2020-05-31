module MonsterRace
  extend self
  extend Loggable

  private MONSTERS = Array(L2Npc).new(8)
  private SPEEDS   = Slice.new(8) { Slice.new(20, 0) }
  private FIRST    = Slice.new(2, 0)
  private SECOND   = Slice.new(2, 0)

  def new_race
    random = 0
    8.times do |i|
      id = 31003
      random = Rnd.rand(24)
      loop do
        (i &- 1).downto(0) do |j|
          if MONSTERS[j].template.id == id + random
            random = Rnd.rand(24)
            next
          end
        end
        break
      end


      begin
        template = NpcData[id + random]
        constructor = nil
        {% begin %}
          constructor =
          case "#{template.type}Instance"
          {% for sub in L2Npc.all_subclasses.reject &.abstract? %}
            when {{sub.stringify}}
              {{sub}}
          {% end %}
          else
            raise "No constructor for '#{template.type}' found."
          end
        {% end %}

        MONSTERS << constructor.new(template)
      rescue e
        error e
      end
    end

    new_speeds
  end

  def new_speeds
    total = 0
    FIRST[1] = 0
    SECOND[1] = 0
    8.times do |i|
      total = 0
      20.times do |j|
        total &+= SPEEDS[i][j] = j == 19 ? 100 : Rnd.rand(60) &+ 65
      end
      if total >= FIRST[1]
        SECOND[0] = FIRST[0]
        SECOND[1] = FIRST[1]
        FIRST[0] = 8 &- i
        FIRST[1] = total
      elsif total >= SECOND[1]
        SECOND[0] = 8 &- i
        SECOND[1] = total
      end
    end
  end

  def first_place : Int32
    FIRST.first
  end

  def second_place : Int32
    SECOND.first
  end

  def monsters : Array(L2Npc)
    MONSTERS
  end

  def speeds : Slice(Slice(Int32))
    SPEEDS
  end
end
