#include "ERModbus.h"

ModbusThread::ModbusThread(){
    /*清除指针*/
    ER_Modbus = NULL;
    /*清除错误*/
    errno = 0;
    /*获取RTU结构体*/
    ER_Modbus =  modbus_new_rtu("/dev/ttymxc1",38400,'N',8,1);
    /*设置modbus为232模式*/
    modbus_rtu_set_serial_mode(ER_Modbus,MODBUS_RTU_RS232);
    /*为0输出调试信息*/
    modbus_set_debug(ER_Modbus, TRUE);
    /*设置超时时间 100 000 us*/
    modbus_set_response_timeout(ER_Modbus,0,80000);
    /*设置byte超时时间 1000 us*/
    modbus_set_byte_timeout(ER_Modbus,0,1000);
    /*设置从机地址*/
    modbus_set_slave(ER_Modbus,0x0001);
    /*连接串口*/
    if(modbus_connect(ER_Modbus)==-1){
        modbus_free(ER_Modbus);;
        ER_Modbus=NULL;
    }
    qDebug()<<"ModbusThread::INSTALL->"<<modbus_strerror(errno);
}
ModbusThread::~ModbusThread(){

    if(ER_Modbus){
        /*关闭modbus*/
        modbus_close(ER_Modbus);
        /*释放modbus内存*/
        modbus_free(ER_Modbus);
        /*清楚modbus指针*/
        ER_Modbus = NULL;
    }
    qDebug()<<"ModbusThread::REMOVE";
}

void ModbusThread::run()Q_DECL_OVERRIDE{
    int res,i;
    res=0;
    errno=0;
    if(ER_Modbus){
    //R读命令
    modbusCmd=frame.at(0);
    modbusReg=frame.at(1);
    modbusNum=frame.at(2);
    modbusData.clear();
    if(modbusCmd=="R"){
        res= modbus_read_registers(ER_Modbus,modbusReg.toInt(),modbusNum.toInt(),data);
        if(res!=-1){
            for(i=0;i<modbusNum.toInt();i++){
                modbusData.append(QString::number(data[i]));
            }
        }
    }else if(modbusCmd=="W"){
        for(i=0;i<modbusNum.toInt();i++){
            data[i]=frame.at(3+i).toInt();
        }
        if(modbusNum.toInt()!=1)
            res= modbus_write_registers(ER_Modbus,modbusReg.toInt(),modbusNum.toInt(),data);
        else
            res= modbus_write_register(ER_Modbus,modbusReg.toInt(),data[0]);
    }else{
        qDebug()<<"ModbusThread::Cmd is not support .";
    }
    modbusData.insert(0,modbus_strerror(errno));
    emit ModbusThreadSignal(modbusData);
    qDebug()<<"ModbusThread::ANSWER "<<modbusData;
     }
}

ERModbus::ERModbus(QObject *parent)
    : QObject(parent)
{
    /*创建任务线程*/
    pModbusThread = new ModbusThread();
    /*连接 线程*/
    connect(pModbusThread,&ModbusThread::ModbusThreadSignal,this,&ERModbus::modbusFrameChanged);
   // connect(pModbusThread,&ModbusThread::finished,pModbusThread,&ModbusThread::stop);
}
ERModbus::~ERModbus(){
    delete pModbusThread;
}

QStringList ERModbus::modbusFrame(){
    return Frame;
}
/*R REG NUM */
void ERModbus::setmodbusFrame(QStringList frame){
    pModbusThread->frame = frame;
    while(pModbusThread->isRunning());
    pModbusThread->start();
}
