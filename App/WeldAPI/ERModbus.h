#ifndef MODBUSPORT_H
#define MODBUSPORT_H
#include "gloabldefine.h"
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

#define MODBUS_READ         0
#define MODBUS_WRITE        1

#ifdef USE_MODBUS
//#define
#endif

class ModbusThread:public QThread{
    Q_OBJECT
    /*重写该函数*/
    void run()Q_DECL_OVERRIDE;
#ifdef USE_MODBUS
    /*modbus 寄存器*/
    int modbusReg;
    /*modbus 寄存器地址*/
    int modbusNum;
    /*modbus 寄存器地址*/
    QList<int> modbusData;
    /*modbus 命令*/
    int modbusCmd;
    /*命令队列*/
    QQueue< QList<int> > cmdBuf;
#else
    /*modbus 寄存器*/
    QString modbusReg;
    /*modbus 寄存器地址*/
    QString modbusNum;
    /*modbus 寄存器地址*/
    QStringList modbusData;
    /*modbus 命令*/
    QString modbusCmd;
   /*命令队列*/
    QQueue<QStringList> cmdBuf;
#endif
    /*缓存数组*/
    uint16_t data[260];
public:
    ModbusThread();
    ~ModbusThread();
    //QMutex* lockThread;
    modbus_t *ER_Modbus;

#ifdef USE_MODBUS
    QQueue< QList<int> > *pCmdBuf;
    QList<int> frame;
#else
    QQueue<QStringList> * pCmdBuf;
    QStringList frame;
#endif

signals:
    void ModbusThreadSignal(QList<int> Frame);
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
public  slots:
//#ifdef USE_MODBUS
    void setmodbusFrame(QList<int> frame);

//#else
//    void setmodbusFrame(QStringList frame);
//#endif
    //信号
signals:
    //发送命令改变
#ifdef    USE_MODBUS
    void modbusFrameChanged(QList<int> frame);
#else
    void modbusFrameChanged(QStringList frame);
#endif

    //
};

#endif
