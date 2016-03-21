TEMPLATE = app

QT += qml quick core widgets sql serialport charts

SOURCES += main.cpp \
    libmodbus/src/modbus.c \
   libmodbus/src/modbus-data.c \
    libmodbus/src/modbus-rtu.c \
    WeldAPI/ERModbus.cpp \
    WeldAPI/AppConfig.cpp \
    WeldAPI/SysInfor.cpp


RESOURCES += \
    qml.qrc\



HEADERS += \
    WeldAPI/gloabldefine.h \
    libmodbus/src/modbus.h \
    libmodbus/src/modbus-rtu.h \
    libmodbus/src/modbus-rtu-private.h \
    WeldAPI/ERModbus.h \
    WeldAPI/AppConfig.h \
    WeldAPI/SysInfor.h

INCLUDEPATH +=libmodbus \
              libmodbus/src \
              WeldAPI\
              VirtualKeyboard\

linux-g++{
   # DESTDIR = $$[QT_INSTALL_PLUGINS]/platforminputcontexts
    CONFIG += console qml_debug
}else{
#存储位置为 downloadfiles
    DESTDIR = /home/nop/ER-100/RootFs/Nop/
}

#DISTFILES += \
# TeachEnv.qml









