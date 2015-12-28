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
    /*modbus_status */
    Q_PROPERTY(QString  modbus_status  READ getmodus_status WRITE  setmodbus_status NOTIFY modbus_statuschanged)
    /*modbus_data*/
    Q_PROPERTY(int modbusdata READ getmodbusdata WRITE setmodbusdata)
    /*modbus_regadr*/
    Q_PROPERTY(int modbusreg READ getmodbusreg WRITE setmodbusreg)
    /*modbus_reg*/
   Q_PROPERTY(int modbusnum READ getmodbusnum WRITE setmodbusnum)

public:
    ERModbus();
    ~ERModbus();

    void setmodbusnum(int num);
    int getmodbusnum(void);

    void setmodbusreg(int reg);
    int getmodbusreg(void);

    void setmodbusdata(int data);
    int getmodbusdata(void);

    void setmodbus_status(QString Status);
    QString getmodus_status(void );
private:
    /*modbus 结构体指针，用于操作modbus*/
    modbus_t *ER_Modbus;
    QString status;
    /*modbus 寄存器*/
    int modbus_reg;
    /*modbus 寄存器地址*/
    int modbus_num;
    /*modbus 寄存器地址*/
    int modbus_data;
    signals:
    void modbus_statuschanged(QString status);
};





#endif
