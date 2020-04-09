require "colorize"

module Loggable
  enum Severity : UInt8
    DEBUG
    INFO
    WARN
    ERROR
    FATAL
    UNKNOWN
  end

  private LOGGABLE_IOS = [] of IO
  private LOGGABLE_MUTEX = Mutex.new

  class_property severity : Severity = Severity::INFO

  def self.add_io(io : IO)
    LOGGABLE_IOS << io
  end

  private def self.to_msg(msg)
    msg.is_a?(Exception) ? msg.inspect_with_backtrace : msg.to_s
  end

  def self.write(subject, severity_name, color)
    return if LOGGABLE_IOS.empty?

    msg = to_msg(yield)
    time = Time.local

    LOGGABLE_MUTEX.synchronize do
      LOGGABLE_IOS.each do |io|
        if io.tty?
          time.to_s("[%H:%M:%S] ", io)
        else
          io << severity_name
          time.to_s(" [%d-%m-%Y %H:%M:%S] ", io)
        end

        io << '['
        subject.to_log(io)
        io << "] "

        if io.tty?
          io.puts(msg.colorize(color))
        else
          io.puts(msg)
        end
      end
    end
  end

  {% for name, color in {debug: :cyan, info: :green, warn: :yellow, error: :red, fatal: :red, unknown: :red} %}
    def self.{{name.id}}(subject)
      if Severity::{{name.stringify.upcase.id}} >= severity
        write(subject, {{name.stringify[0..0].upcase}}, {{color}}) { yield }
      end
    end

    def {{name.id}}
      Loggable.{{name.id}}(self) { yield }
    end

    def {{name.id}}(msg)
      {{name.id}} { msg }
    end
  {% end %}

  def to_log : String
    String.build { |io| to_log(io) }
  end

  def to_log(io : IO)
    if is_a?(Class)
      io << self
      io << ":Class" if responds_to?(:allocate)
    else
      io << self.class
    end
  end
end
