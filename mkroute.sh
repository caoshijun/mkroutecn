#! /bin/bash
#
#

dir=/dev/shm
tmp_route_file=$dir/routes.txt

cd $dir
declare -i FULL_MASK_INT=4294967295
wget http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest{,.md5}
md5sum -c delegated-apnic-latest.md5  >/dev/null
if [[ $? == 0 ]]
then
  echo "Download apnic file sucessful"
	rm -rf $tmp_route_file
	while read IP MAX_HOSTS
	do
		declare -i N="${FULL_MASK_INT} - ( ${MAX_HOSTS} - 1 )"
		declare -i H1="$N & 0x000000ff"
		declare -i H2="($N & 0x0000ff00) >> 8"
		declare -i L1="($N & 0x00ff0000) >> 16"
		declare -i L2="($N & 0xff000000) >> 24"
		netmask="$L2.$L1.$H2.$H1"
		printf "$IP $netmask\n" >> $tmp_route_file
	done< <(grep CN delegated-apnic-latest |grep ipv4|cut -d'|' -f4,5|sed 's/|/\t/g')
else
	echo "apnic file checksum error"
	exit
fi


rm -rf delegated-apnic-latest{,.md5}
rm -rf route_diff
