#include "ERModbus.h"

ModbusThread::ModbusThread(){
    pCmdBuf=&cmdBuf;
}
ModbusThread::~ModbusThread(){

}

ERModbus::ERModbus(QObject *parent)
    : QObject(parent)
{
    /*清除指针*/
    modbus = NULL;
    /*清除错误*/
    errno = 0;
    /*获取RTU结构体*/
    modbus =  modbus_new_rtu("/dev/ttymxc1",38400,'N',8,1);
    /*设置modbus为232模式*/
    modbus_rtu_set_serial_mode(modbus,MODBUS_RTU_RS232);
    /*为0输出调试信息*/
    modbus_set_debug(modbus, FALSE);
    /*设置超时时间 100 000 us*/
    modbus_set_response_timeout(modbus,0,80000);
    /*设置byte超时时间 1000 us*/
    modbus_set_byte_timeout(modbus,0,1000);
    /*设置从机地址*/
    modbus_set_slave(modbus,0x0001);
    /*连接串口*/
    if(modbus_connect(modbus)==-1){
        modbus_free(modbus);
        modbus=NULL;
    }
    qDebug()<<"ModbudsThread::INSTALL->"<<modbus_strerror(errno);
    /*创建任务线程*/
    pModbusThread = new ModbusThread();
    /*连接 线程*/
    connect(pModbusThread,&ModbusThread::ModbusThreadSignal,this,&ERModbus::modbusFrameChanged);
    //对其modbus赋值
    pModbusThread->ER_Modbus=modbus;
    //互斥信号
    //   pModbusThread->lockThread= &lockThread;
    //启动线程
    pModbusThread->start();
}
ERModbus::~ERModbus(){
    if(modbus){
        /*关闭modbus*/
        modbus_close(modbus);
        /*释放modbus内存*/
        modbus_free(modbus);
        /*清楚modbus指针*/
        modbus = NULL;
    }
}

/*R REG NUM */



#ifdef USE_MODBUS

void ERModbus::setmodbusFrame(QList<int> frame){
    //  qDebug()<<"ERModbus::setmodbusFrame"<<frame;
    //加入缓存队列
    pModbusThread->pCmdBuf->enqueue(frame);
    //qDebug()<<"pModbusThread::pCmdBuf count en"<<pModbusThread->pCmdBuf->count();
}

void ModbusThread::run(){
    int res,i;
    //函数大循环
    for(;;){
        //队列内有数则 传输数据
        if(cmdBuf.isEmpty()==false){
            res=0;
            frame=cmdBuf.dequeue();
            qDebug()<<"pModbusThread::pCmdBuf "<<frame;
            if(ER_Modbus){
                //R读命令
                modbusCmd=frame.at(0);
                modbusReg=frame.at(1);
                modbusNum=frame.at(2);
                modbusData.clear();
                if(modbusCmd==MODBUS_FC_READ_HOLDING_REGISTERS){
                    res= modbus_read_registers(ER_Modbus,modbusReg,modbusNum,data);
                    if(res!=-1){
                        modbusData.append(modbusReg);
                        for(i=0;i<modbusNum;i++){
                            //数据队列存储数据
                            modbusData.append(int16_t(data[i]));
                        }
                    }
                }else if(modbusCmd==MODBUS_FC_WRITE_SINGLE_REGISTER){
                    res= modbus_write_register(ER_Modbus,modbusReg,frame.at(3));
                }else if(modbusCmd==MODBUS_FC_WRITE_MULTIPLE_REGISTERS){
                    for(i=0;i<modbusNum;i++){
                        //先转换成浮点然后四舍5入求整最后转换成int
                        data[i]=int16_t(frame.at(i+3));
                    }
                    res= modbus_write_registers(ER_Modbus,modbusReg,modbusNum,data);
                }
                else{
                    qDebug()<<"ModbusThread::Cmd is not support .";
                }
                modbusData.insert(0,errno);
                emit ModbusThreadSignal(modbusData);
                // qDebug()<<"ModbusThread::ANSWER "<<modbusData;
            }else{
                // qDebug()<<"*Modbus is not exist !";
            }
            msleep(2);
        }else{//队列内部无数据则 线程休眠
            msleep(20);
        }
    }
}

#else

void ERModbus::setmodbusFrame(QStringList frame){
    //  qDebug()<<"ERModbus::setmodbusFrame"<<frame;
    //加入缓存队列
    pModbusThread->pCmdBuf->enqueue(frame);
    //qDebug()<<"pModbusThread::pCmdBuf count en"<<pModbusThread->pCmdBuf->count();
}
void ModbusThread::run(){
    int res,i;
    //函数大循环
    for(;;){
        //队列内有数则 传输数据
        if(cmdBuf.count()){
            res=0;
            frame=cmdBuf.dequeue();
            //    qDebug()<<"pModbusThread::pCmdBuf count de"<<cmdBuf.count();
            if(ER_Modbus){
                //R读命令
                modbusCmd=frame.at(0);
                modbusReg=frame.at(1);
                modbusNum=frame.at(2);
                modbusData.clear();
                if(modbusCmd=="R"){
                    res= modbus_read_registers(ER_Modbus,modbusReg.toInt(),modbusNum.toInt(),data);
                    if(res!=-1){
                        modbusData.append(modbusReg);
                        for(i=0;i<modbusNum.toInt();i++){
                            if((modbusReg=="0")||((i==6)&&(modbusReg=="150"))||((i==0)&&(modbusReg=="1022")))//此处用来转换32位拆分错误
                                modbusData.append(QString::number(uint16_t(data[i])));
                            else
                                modbusData.append(QString::number(int16_t(data[i])));
                        }
                    }
                }else if(modbusCmd=="W"){
                    for(i=0;i<modbusNum.toInt();i++){
                        //先转换成浮点然后四舍5入求整最后转换成int
                        data[i]=int16_t(qRound(frame.at(3+i).toFloat()));
                    }
                    if(modbusNum.toInt()!=1)
                        res= modbus_write_registers(ER_Modbus,modbusReg.toInt(),modbusNum.toInt(),data);
                    else
                        res= modbus_write_register(ER_Modbus,modbusReg.toInt(),data[0]);
                }else{
                    qDebug()<<"ModbusThread::Cmd is not support .";
                }
                modbusData.insert(0,QString::number(errno));
                emit ModbusThreadSignal(modbusData);
            }else{
                // qDebug()<<"*Modbus is not exist !";
            }
            msleep(2);
        }else{//队列内部无数据则 线程休眠
            msleep(50);
        }
    }
}
#endif
