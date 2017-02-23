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
#include <errno.h>
#include <stdint.h>
#include <QtSql>

class SqlThread:public QThread{
    Q_OBJECT
    /*重写该函数*/
    //void run()Q_DECL_OVERRIDE;

private:
    QSqlDatabase myDataBases;
public:
    SqlThread();
    ~SqlThread();
signals:
    void SqlThreadSignal(QStringList record);
};

class SQL:public QObject
{
    Q_OBJECT
private:
    SqlThread* pSqlThread;
public:
    SQL();
public  slots:

    //信号
signals:
    //发送命令改变

};

#endif // SQLITE3_H
