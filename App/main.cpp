#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include "AppConfig.h"
#include "ERModbus.h"
#include <QDebug>
#include "gloabldefine.h"

//==============================================================================
QObject* ERModbusEngineProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
     ERModbus *p=new ERModbus();
     return p;
}
QObject* AppConfigEngineProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
     AppConfig *p=new AppConfig();
     return p;
}
int main(int argc, char *argv[])
{
    //必须声明在APP之前声明环境变量。
    qputenv("QT_IM_MODULE", QByteArray("virtualkeyboard"));
    //显示插件调试信息
   // qputenv("QT_DEBUG_PLUGINS", QByteArray("1"));
    QApplication app(argc, argv);
    qmlRegisterSingletonType<AppConfig>("WeldSys.AppConfig",1,0,"AppConfig",AppConfigEngineProvider);
    qmlRegisterSingletonType<ERModbus>("WeldSys.ERModbus",1,0,"ERModbus",ERModbusEngineProvider);
    QQmlApplicationEngine engine;
    engine.setOfflineStoragePath(".");
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
