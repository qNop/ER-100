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
    //qDebug()<<"ModbusThread::INSTALL->"<<modbus_strerror(errno);
    /*创建任务线程*/
    pModbusThread = new ModbusThread();
    /*连接 线程*/
    connect(pModbusThread,SIGNAL(ModbusThreadSignal(QList<int>)),this,SIGNAL(modbusFrameChanged(QList<int>)));
    //对其modbus赋值
    pModbusThread->ER_Modbus=modbus;
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
void ERModbus::setmodbusFrame(modbusDataType frame){
    //加入缓存队列
    pModbusThread->pCmdBuf->enqueue(frame);
}
//获取Modbus状态
const char* ERModbus::getModbusStatus(int error){
    return modbus_strerror(error);
}

void ModbusThread::run(){
    int res,i;
    //函数大循环
    for(;;){
        //队列内有数则 传输数据
        if(cmdBuf.count()){
            modbusDataType cmd=cmdBuf.dequeue();
            QList< int > reply;
            reply<<cmd.rw<<cmd.reg<<cmd.num;
            if(ER_Modbus){
                //R读命令
                if(cmd.rw){
                    res=modbus_read_registers(ER_Modbus,cmd.reg,cmd.num,&cmd.data[0]);
                    reply<<errno;
                    if(res!=-1){
                        for(i=0;i<cmd.num;i++){
                         /*   if((modbusReg==0)||((i==6)&&(modbusReg==150))||((i==0)&&(modbusReg==1022)))//此处用来转换32位拆分错误
                                modbusData.append(uint16_t(data[i]));
                            else
                                modbusData.append(int16_t(data[i]));*/
                                reply<<cmd.data[i];
                        }
                    }
                }else {
                    if(cmd.num!=1)
                        modbus_write_registers(ER_Modbus,cmd.reg,cmd.num,&cmd.data[0]);
                    else
                        modbus_write_register(ER_Modbus,cmd.reg,cmd.data[0]);
                }
                reply<<errno;
            }else{
                //系统错误No such device or address
                reply<<6;
            }
            emit ModbusThreadSignal(reply);
        }else{//队列内部无数据则 线程休眠25ms一个命令
            msleep(25);
        }
    }
}

