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


class ModbusThread:public QThread{
    Q_OBJECT
    /*重写该函数*/
    void run()Q_DECL_OVERRIDE;

    /*modbus 寄存器*/
    QString modbusReg;
    /*modbus 寄存器地址*/
    QString modbusNum;
    /*modbus 寄存器地址*/
    QStringList modbusData;
    /*modbus 命令*/
    QString modbusCmd;
    /*缓存数组*/
    uint16_t data[260];

    QQueue<QStringList> cmdBuf;

public:
    ModbusThread();
    ~ModbusThread();
     QStringList frame;
     //QMutex* lockThread;
     modbus_t *ER_Modbus;
    QQueue<QStringList> * pCmdBuf;

signals:
    void ModbusThreadSignal(QStringList Frame);
};

class ERModbus : public QObject
{
    Q_OBJECT
private:
    QString status;
    ModbusThread* pModbusThread;
    QStringList Frame;
    //槽
public:
      //QMutex lockThread;
       modbus_t *modbus;
    explicit ERModbus(QObject* parent = 0);
    ~ERModbus();

       //设置焊接位置
       void setWeldStyle(int value);
       //设置坡口形式
       void setGrooveStyle(int value);
       //设置链接方式
       void setConnectStyle(int value);
       //设置陶瓷衬垫形式(int value)
       void setCeramicBack(int value);


public  slots:
    void setmodbusFrame(QStringList frame);
    //信号
signals:
    //发送命令改变
    void modbusFrameChanged(QStringList frame);
};

#endif
