TEMPLATE = app

QT +=  quick  sql serialport  widgets

#CONFIG+=staticlib

SOURCES += main.cpp \
    libmodbus/src/modbus.c \
    libmodbus/src/modbus-data.c \
    libmodbus/src/modbus-rtu.c \
    WeldAPI/ERModbus.cpp \
    WeldAPI/AppConfig.cpp \
    WeldAPI/weldmath.cpp \
    WeldAPI/SysMath.cpp \
    WeldAPI/MySQL.cpp \
    WeldAPI/groove.cpp

RESOURCES += \
    qml.qrc

HEADERS += \
    WeldAPI/gloabldefine.h \
    libmodbus/src/modbus.h \
    libmodbus/src/modbus-rtu.h \
    libmodbus/src/modbus-rtu-private.h \
    WeldAPI/ERModbus.h \
    WeldAPI/AppConfig.h \
    WeldAPI/weldmath.h \
    WeldAPI/SysMath.h \
    WeldAPI/MySQL.h \
    WeldAPI/FeedSpeedTable.h \
    WeldAPI/groove.h

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


#v1.0.2版本主要变动如下：
#1\修复以往分道焊接时起弧位置跑偏bug
#2\重新调整Modbus程序，将原qml中程序段移动到C++,提高modbus响应速度。
#3\重新调整焊接排道算法，主要有以下几点：
#	3.1\焊道层高分布策略调整
#	3.2\立焊时药芯焊丝与实芯焊丝摆速调整分开
#	3.3\计算焊速时，超过最大最小限制，将不再调整焊接电流适应焊速。而是直接赋予最大或最小焊速。
#	3.4\横焊取消摆动
#	3.5\排道算法框架变更，主要有以下几点：
#		3.5.1\排道算法支持多点检测自适应排道也支持多点检测均布排道
#		3.5.2\排道算法中加入渐变坡口实时调整
#	3.6\横焊分开结束比为渐变举例 系数为1.1 三道 一道 1 二道 1.1 三道 1.2 总体为 1/3.3 (1+1.2)*3/2
#4\加入焊道的整体延长、缩短。统一层间距离、道间距离名词概念。
#5\数据库大范围调整，将不再以接头形式、坡口形式为依据，直接统一到坡口，减少因接头形式、坡口形式不同需要重复调整限制条件变量。
#数据库数量由250个减少到130个
#v1.0.3版本主要变动如下：
#1\修复下发规范中会出现无法下发的bug，增加提示，要下发的规范必须被选中！！
#2\修复因无法获取数据库导致的死机问题。
#3\变更各条件界面的处理方式，提高运行效率，结构紧凑，增加稳定性。
#v1.0.4版本主要变动如下：
#修复V1.0.2更改时出现的陶瓷衬垫、无衬垫不能焊接的问题。（陶瓷衬垫摆速未下发）
#修复系统时间不能更改问题。
#新添加立焊三角摆功能。
#v1.0.5版本主要变化如下：
#修复水平角焊盖面坐标
#添加电弧跟踪界面。
#移除了数据目录增强系统稳定性。









