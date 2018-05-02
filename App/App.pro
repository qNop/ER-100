TEMPLATE = app

QT +=  quick  sql serialport  widgets

#CONFIG+=staticlib

SOURCES += main.cpp \
    libmodbus/src/modbus.c \
    libmodbus/src/modbus-data.c \
    libmodbus/src/modbus-rtu.c \
    WeldAPI/ERModbus.cpp \
    WeldAPI/AppConfig.cpp \
    WeldAPI/SysMath.cpp \
    WeldAPI/MySQL.cpp \
    WeldAPI/WeldMath.cpp \
    WeldAPI/Weldcontrol.cpp \
    WeldAPI/DoError.cpp

RESOURCES += \
    qml.qrc

HEADERS += \
    WeldAPI/gloabldefine.h \
    libmodbus/src/modbus.h \
    libmodbus/src/modbus-rtu.h \
    libmodbus/src/modbus-rtu-private.h \
    WeldAPI/ERModbus.h \
    WeldAPI/AppConfig.h \
    WeldAPI/SysMath.h \
    WeldAPI/MySQL.h \
    WeldAPI/WeldMath.h \
    WeldAPI/WeldControl.h \
    WeldAPI/DoError.h

INCLUDEPATH +=libmodbus \
              libmodbus/src \
              WeldAPI

linux-g++{
   # DESTDIR = $$[QT_INSTALL_PLUGINS]/platforminputcontexts
    CONFIG += console qml_debug
}else{
#存储位置为 downloadfiles
    DESTDIR = $$_PRO_FILE_PWD_/../RootFs/Nop/Update
}

target.path=/ER-100
INSTALLS += target

DISTFILES += \
    MathLimited.txt










