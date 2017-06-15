#-------------------------------------------------
#
# Project created by QtCreator 2013-04-04T23:11:38
#
#-------------------------------------------------
TEMPLATE = lib

QT       += qml quick quick-private gui-private widgets

CONFIG += plugin

TARGET = VirtualKeyboard

linux-g++{
    DESTDIR = $$[QT_INSTALL_PLUGINS]/platforminputcontexts
}else{
#存储位置为 downloadfiles
    DESTDIR =/home/nop/ER-100/RootFs/opt/Qt5/plugins/platforminputcontexts
}

SOURCES += \
    DeclarativeInputEngine.cpp \
    VirtualKeyboardInputContext.cpp \
    VirtualKeyboardInputContextPlugin.cpp

HEADERS += \
    DeclarativeInputEngine.h \
    VirtualKeyboardInputContext.h \
    VirtualKeyboardInputContextPlugin.h

RESOURCES += \
    res/res.qrc


