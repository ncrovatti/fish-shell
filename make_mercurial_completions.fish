#!/usr/bin/env fish

#
# This file produces command specific completions for either hg or darcs
#

function cap
	set res (echo $argv |cut -c 1|tr a-z A-Z)(echo $argv |cut -c 2-)
	echo $res
end

function esc
	echo $argv | sed -e "s/'/\\\'/g"
end


set cmd $argv[1]; or exit 1

echo '
#
# Completions for the '$cmd' command
# This file was autogenerated by the file make_mercurial_completions.fish
# which is shipped with the fish source code
#

#
# Completions from commandline
#
'
set -e argv[1]

while count $argv >/dev/null
	  echo $argv[1]
	  set -e argv[1]
end


echo '
#
# subcommands
#
'

eval "function cmd; $cmd \$argv; end"

set -l cmd_str

switch $cmd
	case svn

		function list_subcommand 
			set cmd1 '\([^ ]*\)'
			set cmd2 '\([^,)]*\)'
			set cmdn '\(, \([^,)]*\)\|\)'
			set svn_re '^   *'$cmd1'\( ('$cmd2$cmdn$cmdn')\|\).*$'
			cmd help|sed -ne 's/'$svn_re'/\1\n\3\n\5\n\7/p'| grep .
		end


		for i in (list_subcommand)
			set desc (cmd help $i|head -n 1|sed -e 's/[^:]*: *\(.*\)$/\1/')
			set desc (esc $desc)
			set cmd_str $cmd_str "-a $i --description '$desc'"
		end

	case '*'

		function list_subcommand 
		 	cmd help | sed -n -e 's/^  *\([^ ][^ ]*\) .*$/\1/p'
		end
		set cmd_str (cmd help | sed -n -e 's/^  *\([^ ][^ ]*\)[\t ] *\([^ ].*\)$/-a \1 --description \'\2\'/p')

end

printf "complete -c $cmd -n '__fish_use_subcommand' -x %s\n" $cmd_str

for i in (list_subcommand)

	echo '

#
# Completions for the \''$i'\' subcommand
#
'
	set -l cmd_str "complete -c $cmd -n 'contains $i (commandline -poc)' %s\n"

	set short_exp '\(-.\|\)'
	set long_exp '--\([^ =,]*\)'
	set arg_exp '\(\|[= ][^ ][^ ]*\)'
	set desc_exp '\([\t ]*:[\t ]*\|\)\([^ ].*\)'
	set re "^ *$short_exp  *$long_exp$arg_exp  *$desc_exp\$"

	for j in (cmd help $i | sed -n -e 's/'$re'/\1\t\2\t\3\t\5/p')
		set exploded (echo $j|tr \t \n)
		set short $exploded[1]
		set long $exploded[2]
		set arg $exploded[3]
		set desc (cap (esc $exploded[4]))

		set str 

		switch $short
			case '-?'
				set str $str -s (echo $short|cut -c 2)
		end

		switch $long
			case '?*'
				set str $str -l $long
		end

		switch $arg
			case '=DIRECTORY'
				set str $str -x -a "(__fish_complete_directories (commandline -ct))"

			case '=COMMAND'
				set str $str -x -a "(__fish_complete_command)"

			case '=USERNAME'
				set str $str -x -a "(__fish_complete_users)"

			case '=FILENAME' '=FILE'
				set str $str -r 

			case ' arg'
				set str $str -x

			case '?*'
				set str $str -x
				echo "Don't know how to handle arguments of type $arg" >&2
		end

		switch $desc
			case '?*'
				set str $str --description \'$desc\'
		end

		echo complete -c $cmd -n "'contains $i (commandline -poc)'" $str

	end

end

echo \n\n