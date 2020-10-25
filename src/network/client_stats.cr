class ClientStats
  include Synchronizable

  @flood_detected = false
  @queue_overflow_detected = false

  getter processed_packets = 0
  getter dropped_packets = 0
  getter unknown_packets = 0
  getter buffer_size : Int32
  getter head : Int32
  getter total_queue_size = 0
  getter max_queue_size = 0
  getter total_bursts = 0
  getter max_burst_size = 0
  getter short_floods = 0
  getter long_floods = 0
  getter total_queue_overflows = 0
  getter total_count = 0
  getter total_underflow_exceptions = 0
  getter floods_in_min = 0
  getter flood_start_tick = 0i64
  getter unknown_packets_in_min = 0
  getter unknown_packets_start_tick = 0i64
  getter overflows_in_min = 0
  getter overflow_start_tick = 0i64
  getter underflow_reads_in_min = 0
  getter underflow_reads_start_tick = 0i64
  getter packet_count_start_tick = 0i64
  getter packets_in_second

  def initialize
    @buffer_size = Config.client_packet_queue_measure_interval
    @packets_in_second = Slice(Int32).new(@buffer_size)
    @head = @buffer_size &- 1
  end

  def drop_packet : Bool
    result = @flood_detected || @queue_overflow_detected
    if result
      @dropped_packets &+= 1
    end
    result
  end

  def count_unknown_packet : Bool
    @unknown_packets &+= 1
    tick = Time.ms
    if tick - @unknown_packets_start_tick > 60_000
      @unknown_packets_start_tick = tick
      @unknown_packets_in_min = 1
      return false
    end
    @unknown_packets_in_min &+= 1
    @unknown_packets_in_min > Config.client_packet_queue_max_unknown_per_min
  end

  def count_burst(count : Int32) : Bool
    if count > @max_burst_size
      @max_burst_size = count
    end

    if count < Config.client_packet_queue_max_burst_size
      return false
    end

    @total_bursts &+= 1
    true
  end

  def count_queue_overflow : Bool
    @queue_overflow_detected = true
    @total_queue_overflows &+= 1

    tick = Time.ms
    if tick - @overflow_start_tick > 60_000
      @overflow_start_tick = tick
      @overflows_in_min = 1
      return false
    end

    @overflows_in_min &+= 1
    @overflows_in_min > Config.client_packet_queue_max_overflows_per_min
  end

  def count_underflow_exception : Bool
    @total_underflow_exceptions &+= 1

    tick = Time.ms
    if tick - @underflow_reads_start_tick > 60_000
      @underflow_reads_start_tick = tick
      @underflow_reads_in_min = 1
      return false
    end

    @underflow_reads_in_min &+= 1
    @underflow_reads_in_min > Config.client_packet_queue_max_underflows_per_min
  end

  def count_floods : Bool
    @floods_in_min > Config.client_packet_queue_max_floods_per_min
  end

  def long_flood_detected : Bool
    @total_count / @buffer_size > Config.client_packet_queue_max_average_packets_per_second
  end

  def count_packet(queue_size : Int32)
    @processed_packets &+= 1
    @total_queue_size &+= queue_size
    if @max_queue_size < queue_size
      @max_queue_size = queue_size
    end
    if @queue_overflow_detected && queue_size < 2
      @queue_overflow_detected = false
    end
  end

  def count_packet : Bool
    sync do
      @total_count &+= 1
      tick = Time.ms
      if tick - @packet_count_start_tick > 1000
        @packet_count_start_tick = tick
        if @flood_detected && !long_flood_detected
          if @packets_in_second[@head] < Config.client_packet_queue_max_packets_per_second / 2
            @flood_detected = false
          end
        end

        if @head <= 0
          @head = @buffer_size
        end
        @head &-= 1
        @total_count &-= @packets_in_second[@head]
        @packets_in_second[@head] = 1
        return @flood_detected
      end

      count = @packets_in_second[@head] &+= 1
      unless @flood_detected
        if count > Config.client_packet_queue_max_packets_per_second
          @short_floods &+= 1
        elsif long_flood_detected
          @long_floods &+= 1
        else
          return false
        end

        @flood_detected = true
        if tick - @flood_start_tick > 60_000
          @flood_start_tick = tick
          @floods_in_min = 1
        else
          @floods_in_min &+= 1
        end

        true
      end

      false
    end
  end
end
