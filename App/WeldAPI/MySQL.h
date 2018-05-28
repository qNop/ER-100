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
    QQueue<QString> cmdBuf;
public:
    SqlThread();
    ~SqlThread();
    QQueue<QString>  *pCmdBuf;

signals:
    void sqlThreadSignal(QList<QVariant> jsonObject,QString tableName);
    void sqlThreadFinished(bool res,QString tableName);
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
    //获取JSON格式的数据
    void getJsonTable(QString tableName);
    //创建表格
    void createTable(QString tableName,QString format);
    //删除行信息
    void clearTable(QString tableName,QString func,QString value);
    //删除表格
    void deleteTable(QString tableName);
    //插入表格Qobject模式的
    void insertTable(QString tableName,QObject* data);
    //插入表格内容 json格式
    void insertTableByJson(QString tableName,QJsonObject data);
    //重命名表格
    void renameTable(QString oldName,QString newName);
    //表格添加字段
    void alterTable(QString tableName,QString columnName);
    //从数据库里面获取最新的数据库
    void getDataOrderByTime(QString tableName,QString func);
    //设置value值
    void setValue(QString tableName,QString funcI,QString id,QString funcV,QString value);
    //获取value值
    void getValue(QString tableName,QString func,QString id);
    //
    void mySqlChanged(QList<QVariant> jsonObject,QString tableName);
signals:
     void mySqlStatusChanged(bool status,QString tableName);
     //获取账户列表
     void accountTableChanged(QList<QVariant> jsonObject);
     //获取示教条件
     void teachConditionChanged(QList<QVariant> jsonObject);
     //获取焊接条件
     void weldConditionChanged(QList<QVariant> jsonObject);
     //获取坡口信息
     void grooveTableChanged(QList<QVariant> jsonObject);
     //获取限制条件信息
     void limitedTableChanged(QList<QVariant> jsonObject);
     //获取焊接条件信息
     void weldTableChanged(QList<QVariant> jsonObject);
     //获取坡口信息
     void grooveTableListChanged(QList<QVariant> jsonObject);
     //获取限制条件信息
     void limitedTableListChanged(QList<QVariant> jsonObject);
     //获取焊接条件信息
     void weldTableListChanged(QList<QVariant> jsonObject);
};

#endif // SQLITE3_H
