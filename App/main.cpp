#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include "AppConfig.h"
#include "ERModbus.h"
#include "SysInfor.h"
#include "weldmath.h"
#include <QDebug>
#include "gloabldefine.h"
#include <QLocale>
//#include <QLabel>
//#include <QMovie>



//==============================================================================
QObject* ERModbusEngineProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    ERModbus *rootFace=new ERModbus();
    return rootFace;
}
QObject* AppConfigEngineProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    AppConfig *rootFace=new AppConfig();
    return rootFace;
}
QObject* SysInforEngineProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    SysInfor *rootFace=new SysInfor();
    return rootFace;
}
QObject* WeldMathEngineProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    WeldMath *rootFace=new WeldMath();
    return rootFace;
}

int main(int argc, char *argv[])
{
    //必须声明在APP之前声明环境变量。
    qputenv("QT_IM_MODULE", QByteArray("Virtualkeyboard"));
    //显示插件调试信息
   // qputenv("QT_DEBUG_PLUGINS", QByteArray("1"));
   // AppConfig.language();
   // QLocale.setDefault();
    QApplication app(argc, argv);

  //  qmlRegisterSingletonType<SysInfor>("WeldSys.SysInfor",1,0,"SysInfor",SysInforEngineProvider);
    qmlRegisterSingletonType<AppConfig>("WeldSys.AppConfig",1,0,"AppConfig",AppConfigEngineProvider);
    qmlRegisterSingletonType<ERModbus>("WeldSys.ERModbus",1,0,"ERModbus",ERModbusEngineProvider);
    qmlRegisterSingletonType<WeldMath>("WeldSys.WeldMath",1,0,"WeldMath",WeldMathEngineProvider);

    QQmlApplicationEngine engine;

    engine.setOfflineStoragePath(".");
     qDebug()<<engine.offlineStoragePath();
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    return app.exec();
}
