TEMPLATE = app

QT +=  quick sql serialport  widgets

#CONFIG+=staticlib

SOURCES += main.cpp \
    libmodbus/src/modbus.c \
   libmodbus/src/modbus-data.c \
    libmodbus/src/modbus-rtu.c \
    WeldAPI/ERModbus.cpp \
    WeldAPI/AppConfig.cpp \
    WeldAPI/weldmath.cpp \
   # WeldAPI/verticalmath.cpp \
   #WeldAPI/flatmath.cpp \
   # WeldAPI/horizontalmath.cpp \
   #WeldAPI/filletmath.cpp \
    WeldAPI/SysMath.cpp \
    WeldAPI/SQL.cpp \
#    WeldAPI/json/json_writer.cpp \
#    WeldAPI/json/json_valueiterator.inl \
#    WeldAPI/json/json_value.cpp \
#    WeldAPI/json/json_reader.cpp


RESOURCES += \
    qml.qrc

#LIBS += -L~/ltib/rootfs/opt/Qt5/plugins/platforms -lqeglfs -L~/ltib/rootfs/opt/Qt5/plugins/imageformats -lqdds -lqicns -lqico -lqtga -lqtiff -lqwbmp -lqwebp
#LIBS +=-L~/ltib/rootfs/opt/Qt5/plugins/egldeviceintegrations -lqeglfs-viv-integration -lqeglfs-viv-wl-integration
#LIBS +=-L~/ltib/rootfs/opt/Qt5/plugins/qmltooling -lqmldbg_debugger -lqmldbg_inspector -lqmldbg_local -lqmldbg_native -lqmldbg_profiler -lqmldbg_server -lqmldbg_tcp
#LIBS +=-L~/ltib/rootfs/opt/Qt5/plugins/bearer -lqconnmanbearer -lqgenericbearer -lqnmbearer
#LIBS +=-L~/ltib/rootfs/opt/Qt5/plugins/sqldrivers -lqsqlite -lGLESv2 -lEGL -lGAL -lpthread
#LIBS +=-L
#LIBS + = -L ~/ltib/rootfs/opt/Qt5/plugins/platforms #-lqeglfs
#LIBS + = -L ~/ltib/rootfs/opt/Qt5/plugins/imageformats # -lqdds -lqicns -lqico -lqtga -lqtiff -lqwbmp -lqwebp
#LIBS + = -L ~/ltib/rootfs/opt/Qt5/plugins/egldeviceintegrations #-lqeglfs-viv-integration -lqeglfs-viv-wl-integration
#LIBS + = -L ~/ltib/rootfs/opt/Qt5/plugins/qmltooling #-lqmldbg_debugger -lqmldbg_inspector -lqmldbg_local -lqmldbg_native -lqmldbg_profiler -lqmldbg_server -lqmldbg_tcp
#LIBS + = -L ~/ltib/rootfs/opt/Qt5/plugins/bearer #-lqconnmanbearer -lqgenericbearer -lqnmbearer
#LIBS + = -L ~/ltib/rootfs/opt/Qt5/plugins/sqldrivers # -lqsqlite -lGLESv2 -lEGL -lGAL -lpthread

HEADERS += \
    WeldAPI/gloabldefine.h \
    libmodbus/src/modbus.h \
    libmodbus/src/modbus-rtu.h \
    libmodbus/src/modbus-rtu-private.h \
    WeldAPI/ERModbus.h \
    WeldAPI/AppConfig.h \
    WeldAPI/weldmath.h \
    #WeldAPI/verticalmath.h \
   # WeldAPI/flatmath.h \
   # WeldAPI/horizontalmath.h \
   # WeldAPI/filletmath.h \
    WeldAPI/SysMath.h \
    WeldAPI/SQL.h \
#    WeldAPI/json/version.h.in \
#    WeldAPI/json/json_tool.h \
#    WeldAPI/json/writer.h \
#    WeldAPI/json/version.h \
#    WeldAPI/json/value.h \
#    WeldAPI/json/reader.h \
#    WeldAPI/json/json.h \
#    WeldAPI/json/forwards.h \
#    WeldAPI/json/features.h \
#    WeldAPI/json/config.h \
#    WeldAPI/json/autolink.h \
#    WeldAPI/json/assertions.h \
#    WeldAPI/json/allocator.h

INCLUDEPATH +=libmodbus \
              libmodbus/src \
              WeldAPI

linux-g++{
   # DESTDIR = $$[QT_INSTALL_PLUGINS]/platforminputcontexts
    CONFIG += console qml_debug
}else{
#存储位置为 downloadfiles
    DESTDIR = /home/nop/ER-100/RootFs/Nop/
}

target.path=/ER-100
INSTALLS += target

#DISTFILES += \
# TeachEnv.qml











