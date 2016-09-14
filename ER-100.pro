#QT由一个主项目一个插件组成
TEMPLATE = subdirs
#组成目录有App 和 VirtualKeyboard
SUBDIRS = App VirtualKeyBoard #qtvirtualkeyboard/src
#子目录的编译顺序在SUBDIRS中指明
CONFIG+=ordered

