#ifndef MODBUSPORT_H
#define MODBUSPORT_H

#include <QObject>
#include <QString>
#include <QtQml/QQmlListProperty>
#include "modbus.h"

/*
 *  实现modbus与qml的联合调用
*/
class ERModbus : public QObject
{
    Q_OBJECT
    /*modbus_cmd*/
    Q_PROPERTY(QStringList modbusFrame READ modbusFrame WRITE setmodbusFrame NOTIFY modbusFrameChanged)
private:
    modbus_t *ER_Modbus;
    QString status;
    /*modbus 寄存器*/
    QString modbusReg;
    /*modbus 寄存器地址*/
    QString modbusNum;
    /*modbus 寄存器地址*/
    QStringList modbusData;
    /*modbus 命令*/
    QString modbusCmd;
//槽
public:
   explicit ERModbus(QObject* parent = 0);
    ~ERModbus();
    QStringList modbusFrame();
public  slots:
    void setmodbusFrame(QStringList frame);
//信号
signals:
    //发送命令改变
    void modbusFrameChanged(QStringList frame);
};





#endif
