#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include "AppConfig.h"
#include "ERModbus.h"
#include "weldmath.h"
#include <QDebug>
#include "gloabldefine.h"
#include <QLocale>
#include <MySQL.h>


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
QObject* WeldMathEngineProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    WeldMath *p=new WeldMath();
    return p;
}

QObject* SQLEngineProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    MySQL *p=new MySQL();
    return p;
}

int main(int argc, char *argv[])
{
    //必须声明在APP之前声明环境变量。
    qputenv("QT_IM_MODULE", QByteArray("Virtualkeyboard"));
    //配置文件存储目录
    if(qgetenv("QTDIR")=="/usr/local/Qt-5.5.0")
        qputenv("HOME",QByteArray("/home/nop/ER-100/RootFs/Nop"));
    else
        qputenv("HOME",QByteArray("/usr/local/ER-100/Nop"));
    qDebug()<<qgetenv("HOME");
    //显示插件调试信息
    // qputenv("QT_DEBUG_PLUGINS", QByteArray("1"));
    // AppConfig.language();
    // QLocale.setDefault();
    QApplication app(argc, argv);
    qmlRegisterSingletonType<AppConfig>("WeldSys.AppConfig",1,0,"AppConfig",AppConfigEngineProvider);
    qmlRegisterSingletonType<ERModbus>("WeldSys.ERModbus",1,0,"ERModbus",ERModbusEngineProvider);
    qmlRegisterSingletonType<WeldMath>("WeldSys.WeldMath",1,0,"WeldMath",WeldMathEngineProvider);
   // qmlRegisterSingletonType<MySQL>("WeldSys.MySQL",1,0,"MySQL",SQLEngineProvider);
    app.setOrganizationName("TangShanKaiYuanSpecialWeldingEquipmentCo.,Ltd");
    app.setOrganizationDomain("www.spec-welding.com");
    app.setApplicationName("ER-100");
    QQmlApplicationEngine engine;
    //数据库文件存储目录
    qDebug()<<engine.offlineStoragePath();
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    return app.exec();
}
