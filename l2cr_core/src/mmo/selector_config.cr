class SelectorConfig
  property read_buffer_size : Int32 = 64 * 1024
  property write_buffer_size : Int32 = 64 * 1024
  property helper_buffer_count : Int32 = 20
  property helper_buffer_size : Int32 = 64 * 1024
  property max_send_per_pass : Int32 = 10
  property max_read_per_pass : Int32 = 10
  property select_sleep_time : Time::Span = 20.milliseconds
  property tcp_no_delay : Bool = false
end
