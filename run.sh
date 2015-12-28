#!/bin/sh
echo "Please enter cmd you want，Run is to run app ， Cmd is to operation 。"

read cmd

case  "$cmd" in
	Run)
	rm -R /Nop
	echo "cp Nop."
	cp -R /mnt/RootFs/Nop /
		#支持中文字体
		#echo "use zhonghejian"
		#cp /mnt/zhonghejian.ttf /usr/share/fonts/turetype	
	echo "App is starting ..." 
	cd /Nop
	./App
	;;
	Cmd)
	./Files/rootfscmd.sh
	;;
	*)
	echo "cmd is not supported"
	;;
esac

