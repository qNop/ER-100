#include "ERModbus.h"
#include "modbus.h"
#include "modbus-rtu.h"
#include "modbus-rtu-private.h"
#include "modbus-private.h"
#include <QDebug>
#include <errno.h>

ERModbus::ERModbus(){

}
ERModbus::~ERModbus(){

}

/*
 * Modbus 建立
 */
void ERModbus::setmodbus_status(QString Status){
           status=Status;
          if(Status=="setup"){
               /*获取RTU结构体*/
               ER_Modbus =  modbus_new_rtu("/dev/ttymxc1",115200,'N',8,1);
               /*设置modbus为232模式*/
               modbus_rtu_set_serial_mode(ER_Modbus,MODBUS_RTU_RS232);
               /*为0输出调试信息*/
               modbus_set_debug(ER_Modbus, FALSE);
               /*设置超时时间 500 000 us*/
               modbus_set_response_timeout(ER_Modbus,0,100000);
              /*设置从机地址*/
               modbus_set_slave(ER_Modbus,0x0000);
               /*连接串口*/
               modbus_connect(ER_Modbus);
         }
        else  if(Status=="stop"){
              /*关闭modbus*/
              modbus_close(ER_Modbus);
              /*释放modbus内存*/
              modbus_free(ER_Modbus);
              /*清楚modbus指针*/
              ER_Modbus = NULL;
            }
          emit modbus_statuschanged(Status);
}

QString ERModbus::getmodus_status(void){
    return status;
}
void ERModbus::setmodbusdata(int data){
    int rc;
    if(ER_Modbus != NULL){
         //写modbus
      status = "send";
      emit modbus_statuschanged("send");
      if(modbus_num == 1){
           rc=modbus_write_register(ER_Modbus,modbus_reg,data);
      }else{
         // s=modbus_write_registers(ER_Modbus,modbus_reg,data)
      }
     if(rc > 0) status = "ok";
     else{
        status = modbus_strerror(errno);
     }
     emit modbus_statuschanged(status);
    }
}
int ERModbus::getmodbusdata(void){
    int s;
    uint16_t data;
     if(ER_Modbus != NULL){
    qDebug()<<"modbus send get mesg";
    //写modbus
    s=modbus_read_registers(ER_Modbus,modbus_reg,modbus_num,&data);
      qDebug()<<"modbus send get mesg"<<s;
       }
     else{
         qDebug()<<"modbus is closed ~";
     }
    return data;
}
void ERModbus::setmodbusreg(int reg){
    modbus_reg=reg;
}
int ERModbus::getmodbusreg(void){
    return modbus_reg;
}
void ERModbus::setmodbusnum(int num){
    modbus_num=num;
}
int ERModbus::getmodbusnum(void){
    return modbus_num;
}
