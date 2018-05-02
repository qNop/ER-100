#ifndef MODBUSPORT_H
#define MODBUSPORT_H

#include <QObject>
#include <QString>
#include <QtQml/QQmlListProperty>
#include "modbus.h"
#include "modbus-rtu.h"
#include "modbus-rtu-private.h"
#include "modbus-private.h"
#include <QDebug>
#include <QThread>
//#include <QMutex>
#include "errno.h"
#include "stdint.h"
#include <QQueue>
#include "gloabldefine.h"

class ModbusThread:public QThread{
    Q_OBJECT
    /*重写该函数*/
    void run()Q_DECL_OVERRIDE;

    QQueue< modbusDataType > cmdBuf;

public:
    ModbusThread();
    ~ModbusThread();
    //QList< int > frame;
    //QMutex* lockThread;
    modbus_t *ER_Modbus;
    QQueue< modbusDataType > * pCmdBuf;

signals:
    void ModbusThreadSignal(QList< int > reply);
};

class ERModbus : public QObject
{
    Q_OBJECT
private:
    QString status;
    ModbusThread* pModbusThread;
    //槽
public:
    modbus_t* modbus;
     ERModbus(QObject* parent = 0);
    ~ERModbus();
     const char* getModbusStatus(int error);
public  slots:
    void setmodbusFrame(modbusDataType frame);
    //信号
signals:
    //发送命令改变
    void modbusFrameChanged(QList< int > reply);
};

#endif
