#!/bin/sh
echo "Please enter cmd you want，Run is to run app ， Cmd is to operation 。"

read cmd

case  "$cmd" in
	Run)
	#rm -R /Nop
        if [ -d /Nop ]
	then
	echo "cp App"
	cd /Nop
	if [ -e App ]
	then
	   rm /Nop/App
	fi
	cp -R /mnt/RootFs/Nop/App /Nop
	else
	echo "creator Nop"
	cp -R /mnt/RootFs/Nop /
	cd /Nop
	fi
		#支持中文字体
		#echo "use zhonghejian"
		#cp /mnt/zhonghejian.ttf /usr/share/fonts/turetype	
	echo "App is starting ..." 
	./App

	;;
	Cmd)
	./Files/rootfscmd.sh
	;;
	*)
	echo "cmd is not supported"
	;;
esac

