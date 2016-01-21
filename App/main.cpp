#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include "appconfig.h"
#include "ERModbus.h"
#include <QDebug>
#include "gloabldefine.h"
//==============================================================================
QObject* inputEngineProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
     ERModbus *p=new ERModbus();
     return p;
}

int main(int argc, char *argv[])
{
    //必须声明在APP之前否则虚拟按键不管用。
    qputenv("QT_IM_MODULE", QByteArray("virtualkeyboard"));
    //显示插件调试信息
    //qputenv("QT_DEBUG_PLUGINS", QByteArray("1"));
    QApplication app(argc, argv);
    qmlRegisterType<APPConfig>("WeldSys.APPConfig",1,0,"APPConfig");
    qmlRegisterSingletonType<ERModbus>("WeldSys.ERModbus",1,0,"ERModbus",inputEngineProvider);
    QQmlApplicationEngine engine;
    engine.setOfflineStoragePath(".");
    qDebug()<<"Engine::SetOfflineStoragePath "<<engine.offlineStoragePath();
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    return app.exec();
}
