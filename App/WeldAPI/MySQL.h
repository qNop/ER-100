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
#include <QQueue>
#include <QJsonObject>


class SqlThread:public QThread{
    Q_OBJECT
    /*重写该函数*/
    void run()Q_DECL_OVERRIDE;
private:
    QQueue<QStringList> cmdBuf;
    int getTableJson(QString tableName,QList<QJsonObject>*pQJson);
public:
    SqlThread();
    ~SqlThread();
    QQueue<QStringList>  *pCmdBuf;
signals:
    void sqlThreadSignal(QList<QJsonObject> jsonObject);
};

class MySQL:public QObject
{
    Q_OBJECT
private:

public:
    MySQL();
    ~MySQL();
    QSqlDatabase myDataBases;
    SqlThread *pSqlThread;
public  slots:
    void setSqlCommand(QStringList Cmd);
    //信号
signals:
    // void mySqlChanged(QString tableName,QJsonObject* jsonObject);
     void mySqlChanged(QList<QJsonObject> jsonObject);
};

#endif // SQLITE3_H
