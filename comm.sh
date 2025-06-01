#!/bin/sh
verStr='comm.sh 1
https://github.com/jacre8/shmisc'
unset h1 h2 h3
t1=\\t
t2=\\t
invOption ()
{
	echo "Invalid option: -$1$OPTARG" >&2
	exit 64
}
infoArg ()
{
	[ "${1#"$OPTARG"}" = $1 ] || {
		echo "$2"
		exit
	}
}
while getopts ":123-:" opt; do
	case $opt in
		1 ) h1=1 t1=;;
		2 ) h2=1 t2=;;
		3 ) h3=1;;
		- )
			infoArg help "Usage: comm [-1] [-2] [-3] FILE1 FILE2"
			infoArg version "$verStr"
			invOption -;;
		\? )
			invOption;;
	esac
done
shift $((OPTIND - 1))
[ $# -ge 2 ] || {
	echo File argument missing >&2
	exit 64
}
if [ "$1" = '-' ];then
	exec 4<&0
else
	exec 4<"$1"
fi &&
if [ "$2" = '-' ];then
	exec 5<&0
else
	exec 5<"$2"
fi || exit
read1 ()
{
	read l1 <&4
	rc1=$?
}
read2 ()
{
	read l2 <&5
	rc2=$?
}
oc1 ()
{
	printf %s\\n "$l1"
}
oc2 ()
{
	printf $t1%s\\n "$l2"
}
read1
read2
while [ $rc1 = 0 ] && [ $rc2 = 0 ];do
	if [ "$l1" = "$l2" ];then
		[ "$h3" ] || printf $t1$t2%s\\n "$l1"
		read1
		read2
	elif [ "$l1" \< "$l2" ];then
		[ "$h1" ] || oc1
		read1
	else
		[ "$h2" ] || oc2
		read2
	fi
done
[ "$h1" ] || while [ $rc1 = 0 ];do
	oc1
	read1
done
[ "$h2" ] || while [ $rc2 = 0 ];do
	oc2
	read2
done
