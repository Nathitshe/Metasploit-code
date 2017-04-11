# Made by Nathan Rabet
require "time"

info = "Usage: run loop -x [THE METERPRETER COMMAND]... -d [RE-LOOP DELAY] -t [LOOP TIME] | -n [NUMBER OF TIMES]

Simple script for looping every meterpreter commands.

Time Conversion Table:
+-----------------------------------+
| (xSec => min) = 60 * xSec         |
| (xSec => hour) = 3600 * xSec      |
| (xSec => day) = 86400 * xSec      |
| (xSec => month) = 2628000 * xSec  |
| (xSec => year) = 31557600 * xSsec |
+-----------------------------------+
(Please insert the direct result)"

# Options
exec_opts = Rex::Parser::Arguments.new(
'-h' => 
    [false,
    "Show this help menu ! How to loop a meterpreter command."],
'-H' => 
    [false,
    "Show advanced help menu ! With time conversion table and usage."],
'-x' =>
    [true,
    "Meterpreter commands to loop. Must be enclosed in double quotes and separated by a comma."],
'-t' =>
    [true,
    "The time (in second) for the looping. {Default: 0, Infinite} [Can't be used if '-n' is enable !]"],
'-d' =>
    [true,
    "The delay (in millisecond) for reloop commands. {Default: 1000}"],
'-n' => 
    [true,
    "The number of times you want to execute the program. [Can't be used if '-t' is enable !]"]
)

# Default parameters
commands = nil
number = 0
time = 0
delay =  1000

check = 0
startAt = Time.now
@client = client

# Option parsing
exec_opts.parse(args) do |opt, idx, val|
    case opt
		when '-h'
			print_line(exec_opts.usage)
			raise Rex::Script::Completed
		when '-H'
			print_line(info)
			print_line(exec_opts.usage)
			raise Rex::Script::Completed
		when '-x'
			commands = val.to_s
			check = 1
		when '-t'
			time = val.to_i
			check = 1
		when '-d'
			delay = val.to_i
			check = 1
		when '-n'
			number = val.to_i
			check = 1
    end
end

# Errors
if check != 1
	print_error("You must enter an argument !")
	print_status("For more information, please type: run loop -h")
	print_line(exec_opts.usage)
	raise Rex::Script::Completed

elsif (number != 0) and (time != 0)
	print_error("You can't use '-t' and '-n' at the same time !")
	print_status("For more information, please type: run loop -h ")
	raise Rex::Script::Completed

elsif commands == nil
	print_error("You must enter at least one command ! ('-x')")
	print_status("For more information, please type: run loop -h")
	raise Rex::Script::Completed
end

# Execution !
if number == 0
	time != 0 ? print_status("The execution ends at \n <"+ (startAt + time).to_s + "> \n"):print_status("Infinite loop ! \n")
		while (Time.now <=> (startAt + time)) == -1 or time == 0
			@client.console.run_single(commands)
			sleep(delay / 1000)
			print_status("Re-executing commands... \n")
		end
	print_status("Time's up ! Process stopped.")
else
	1.upto(number) do |i|
		print_status("Step " + i.to_s + "/" + number.to_s + ". More than " + (number - i).to_s + " step(s) !")
		@client.console.run_single(commands)
		sleep(delay / 1000)
	end
print_status("Ended successfully !")
end	
raise Rex::Script::Completed
