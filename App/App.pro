TEMPLATE = app

QT += qml quick core widgets sql serialport

SOURCES += main.cpp \
    WeldAPI/appconfig.cpp\
    libmodbus/src/modbus.c \
   libmodbus/src/modbus-data.c \
    libmodbus/src/modbus-rtu.c \
    WeldAPI/ERModbus.cpp


RESOURCES += \
    qml.qrc

CONFIG += console qml_debug

HEADERS += \
    WeldAPI/appconfig.h \
    WeldAPI/gloabldefine.h \
    libmodbus/src/modbus.h \
    libmodbus/src/modbus-rtu.h \
    libmodbus/src/modbus-rtu-private.h \
    WeldAPI/ERModbus.h

INCLUDEPATH +=libmodbus \
              libmodbus/src \
              WeldAPI\
              VirtualKeyboard\

linux-g++{
 #  DESTDIR = $$[QT_INSTALL_PLUGINS]/platforminputcontexts
}else{
#存储位置为 downloadfiles
    DESTDIR = /home/nop/ER-100/RootFs/Nop/
}





