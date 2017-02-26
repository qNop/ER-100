#ifndef SQLITE3_H
#define SQLITE3_H

#include <QObject>
#include <QString>
#include <QtQml/QQmlListProperty>
#include "modbus.h"
#include "modbus-rtu.h"
#include "modbus-rtu-private.h"
#include "modbus-private.h"
#include <QDebug>
#include <QThread>
#include <QMutex>
#include <errno.h>
#include <stdint.h>
#include <QtSql>
#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <json/json.h>

class SqlThread:public QThread{
    Q_OBJECT
    /*重写该函数*/
    void run()Q_DECL_OVERRIDE;
private:
    QTimer* timer;
public:
    SqlThread();
    ~SqlThread();
    QMutex* lockThread;
    QString function;
       QSqlDatabase myDataBases;
signals:
    void sqlThreadSignal(QStringList record);
};

class SQL:public QObject
{
    Q_OBJECT
private:

public:
    SQL();
    ~SQL();
    //信号量
    QMutex lockThread;
    QSqlDatabase myDataBases;
public  slots:
    void setSqlCommand(QString Cmd);
    void openDatabases();
    //信号
signals:
    //发送命令改变
    void sqlSignalChanged(QStringList record);
};

#endif // SQLITE3_H
