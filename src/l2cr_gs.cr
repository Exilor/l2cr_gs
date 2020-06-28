if ARGV.delete("build")
  build
  exit(0)
end

executable = "game_server"

unless File.exists?("./#{executable}")
  puts "./#{File.expand_path(executable)} not found. Run the 'build' command first."
  exit(0)
end

run(executable)

def run(executable)
  loop do
    puts "Starting l2cr game server"

    start_time = Time.local

    system("./#{executable} #{ARGV.join(' ')}")

    min, sec = (Time.local - start_time).to_i.divmod(60)

    case $?.exit_code
    when 0
      puts "Game Server terminated after #{min} m. #{sec} s."
      break
    when 2
      puts "Game Server restarted after #{min} m. #{sec} s."
    else
      puts "Game Server terminated abnormally after #{min} m. #{sec} s."
      break
    end
  end
end

def build
  start_time = Time.local
  puts "Compilation started at #{start_time}"

  build_cmd = "crystal build ./src/game_server.cr #{ARGV.join(' ')}"
  puts build_cmd

  system(build_cmd)

  min, sec = (Time.local - start_time).to_i.divmod(60)

  case $?.exit_code
  when 0
    puts "Compiled in #{min} m. #{sec} s."
  else
    puts "Compilation failed after #{min} m. #{sec} s."
    exit($?.exit_code)
  end
end
