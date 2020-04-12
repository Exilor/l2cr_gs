task default: :run

commands = ["crystal build"]
name_parts = ["l2cr_gs"]

if ARGV.delete("mt")
  commands << "-Dpreview_mt"
  name_parts << "_mt"
end

commands << "src/game_server.cr"

if ARGV.delete("debug")
  commands << "--debug"
  name_parts << "_debug"
end

if ARGV.delete("sm")
  commands << "--single-module"
  name_parts << "_sm"
end

if ARGV.delete("release")
  commands << "--release"
  name_parts << "_release"
end

if ARGV.delete("nodebug")
  commands << "--no-debug"
  name_parts << "_nodebug"
end

EXECUTABLE_NAME = name_parts.join

commands << "--progress" # enable progress output
commands << "--error-trace"
commands << "--threads 4" # remove when i get more ram
commands << "-o" << EXECUTABLE_NAME

BUILD_COMMAND = commands.join(" ")

$build_ok = false

task :run do # build and run
  Rake::Task["build"].execute

  if $build_ok
    run_command = "./#{EXECUTABLE_NAME} #{ARGV.join(' ')}"

    loop do
      system run_command

      case $? &.exitstatus
      when 0
        puts "Game Server terminated"
        break
      when 2
        puts "Game Server restarted"
      else
        puts "Game Server terminated abnormally"
        break
      end
    end
  end
end

task :build do # only build
  puts BUILD_COMMAND

  start_time = Time.new
  puts "Compilation started at #{start_time}."

  system BUILD_COMMAND

  end_time = Time.now - start_time
  min = (end_time / 60).round
  sec = (end_time % 60).round

  case $? &.exitstatus
  when 0
    puts "Compiled in #{min} m. #{sec} s."
    $build_ok = true
  else
    puts "Compilation failed after #{min} m. #{sec} s."
  end
end

task :hierarchy do
  system "crystal tool hierarchy ./src/game_server.cr --no-color >> ./hierarchy.txt"
end
