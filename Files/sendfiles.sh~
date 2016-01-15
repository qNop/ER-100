#!/bin/sh
cd /home/nop/ltib/rootfs/etc
echo "rm profile rc.d/init.d/qtexport rc.d/init.d/ethcfg inittab rc.d/rc.conf "
rm profile rc.d/init.d/qtexport rc.d/init.d/ethcfg inittab rc.d/rc.conf
echo "cp profile qtexport ethcfg inittab rc.conf"
cd /home/nop/DownLoadFiles/rootfs 

cp  qtexport /home/nop/ltib/rootfs/etc/rc.d/init.d/
cp  ethcfg /home/nop/ltib/rootfs/etc/rc.d/init.d/
cp  profile /home/nop/ltib/rootfs/etc/ 
cp  inittab /home/nop/ltib/rootfs/etc/
cp  rc.conf /home/nop/ltib/rootfs/etc/rc.d/
#是否存在truetype文件 否 复制该字体到 该文件下
if [ -e /home/nop/ltib/rootfs/usr/share/fonts/truetype ] 
then
   echo "cp zhonghejian.ttf to dir /home/nop/ltib/rootfs/usr/share/fonts/truetype"
   cp zhonghejian.ttf /home/nop/ltib/rootfs/usr/share/fonts/truetype
fi
#是否存在/Nop文件夹
if [ -e /home/nop/ltib/rootfs/Nop ]
then
   echo "创建/Nop 并复制leds shell"
   mkdir /home/nop/ltib/rootfs/Nop
   cp leds /home/nop/ltib/rootfs/Nop
fi
