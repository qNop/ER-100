#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include "appconfig.h"
#include "ERModbus.h"
#include <QDebug>

int main(int argc, char *argv[])
{
    //必须声明在APP之前否则不管用。
    qputenv("QT_IM_MODULE", QByteArray("VirtualKeyboard"));
    //显示调试信息
    qputenv("QT_DEBUG_PLUGINS", QByteArray("1"));
    QApplication app(argc, argv);
    qmlRegisterType<APPConfig>("WeldSys.APPConfig",1,0,"APPConfig");
    qmlRegisterType<ERModbus>("WeldSys.ERModbus",1,0,"ERModbus");
    QQmlApplicationEngine engine;
    engine.setOfflineStoragePath("offlineSrorage");
    qDebug()<<engine.offlineStoragePath();
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    return app.exec();
}
