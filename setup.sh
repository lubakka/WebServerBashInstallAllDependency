#!/bin/bash

if [ -r include/functions.sh ]
 then
	. include/functions.sh
else
	echo "Cannot open include file include/functions.sh">&2
	   exit 1
fi
if [ -r include/variable.sh ]
 then
	. include/variable.sh
else
	echo "Cannot open include file include/variable.sh">&2
	   exit 1
fi

DIR=$( pwd )

args=("$@")

# Проврява потребителя дали е "root", ако не е го принуждава да стане
[ "$(whoami)" != "root" ] && exec sudo -- "$0" "$@"

verbose=0
while [ "$#" -gt 0 ]; do
   case $1 in
	-a|--auto) 
		echo "Try to config all...." >&2
		installpgk
		if (( ! -n "${args[1]}" )) && (( ! -n "${args[2]}" )) && (( ! -n "${args[3]}" )); then
			echo >&2
			echo "NO ARGUMENTS SUPPLIED FOR MYSQL!!!" >&2
			echo >&2
			echo "$usage" >&2
			exit 1
		else
			DATABASE_HOST="${args[1]}"
			DATABASE_USER="${args[2]}"
			DATABASE_PASS="${args[3]}"
			DATABASE_PASS_NEW="${args[4]}"
			DATABASE_NAME="${args[5]}"
			secureMysql
		fi
		exit
		;;
	-c|--createdb)
		echo "Create mysql databases"
		DATABASE_USER_ROOT="${args[1]}"
		DATABASE_PASS_ROOT="${args[2]}"
		DATABASE_HOST="${args[3]}"
		DATABASE_USER="${args[4]}"
		DATABASE_PASS="${args[5]}"
		DATABASE_NAME="${args[6]}"
		create_databases
		exit
		;;
	-i|--packeg) 
		installpgk
		exit
		;;
	-h|--help|-\?) 
		show_help
		exit
		;;
	-m|--mysql_secure)
		echo "Try to config mysql...." >&2
		if (( ! -n "${args[1]}" )) && (( ! -n "${args[2]}" )) && (( ! -n "${args[3]}" )); then
			echo
			echo "NO ARGUMENTS SUPPLIED!!!" >&2
			echo
			show_help
			exit 1
		else
			DATABASE_USER="${args[1]}"
			DATABASE_PASS="${args[2]}"
			DATABASE_PASS_NEW="${args[3]}"
			secureMysql
		fi
		exit
		;;
	-p|--phantomjs)
		installPhantomjs
		exit
		;;
	-w|--web)
		if [ ! -n "$2" ]; then
			echo 
			echo "NO ARGUMENTS SUPPLIED FOR URL!!!"
			show_help
			exit 1
		else
			apache2config $2
		fi
		exit
		;;
	:)
		printf "missing argument for -%s\n" "$OPTARG" >&2
		show_help
		exit 1
		;;
	\?)
		printf "illegal option: -%s\n" "$OPTARG" >&2
		show_help
		exit 1
		;;
	--)              # End of all options.
		shift
		break
		;;
	*)               # Default case: If no more options then break out of the loop.
		break
	esac
shift
done
