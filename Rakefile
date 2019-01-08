task default: :run

task :run do
  start_time = Time.new
  puts "Compilation started at #{start_time}."

  system "crystal build src/game_server.cr --progress"

  end_time = Time.now - start_time
  min = (end_time / 60).round
  sec = (end_time % 60).round

  case $? &.exitstatus
  when 0
    # ok
    puts "Compiled in #{min} m. #{sec} s."
  else
    puts "Compilation failed after #{min} m. #{sec} s."
    abort
  end

  system "./game_server"

  case $? &.exitstatus
  when 0
    puts "Game Server terminated"
  when 2
    puts "Game Server restarted"
    redo
  else
    puts "Game Server terminated abnormally"
  end
end

task :build do
  start_time = Time.new
  puts "Compilation started at #{start_time}."

  system "crystal build src/game_server.cr --release --progress -o release"

  case $? &.exitstatus
  when 0
    # ok
    end_time = Time.now - start_time
    min = (end_time / 60).round
    sec = (end_time % 60).round
    puts "Compiled in #{min} m. #{sec} s."
  else
    puts "Compilation failed"
  end
end

task :rerun do
  if File.exist?(Dir.getwd + "/game_server")
    system "./game_server"

    case $? &.exitstatus
    when 0
      puts "Game Server terminated"
    when 2
      puts "Game Server restarted"
      redo
    else
      puts "Game Server terminated abnormally"
    end
  else
    puts "No executable found in #{Dir.getwd}"
  end
end
