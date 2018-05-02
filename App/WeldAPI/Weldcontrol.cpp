#include "weldcontrol.h"
#include <stdio.h>

WeldControl::WeldControl()
{
    pWeldMath=new WeldMath();
    pSysMath=pWeldMath->sysMath;
    pModbus=new ERModbus();
    pDoError=new DoError();
    //链接modbus 信号槽
    connect(pModbus,SIGNAL(modbusFrameChanged(QList<int>)),this,SLOT(modbusReply(QList<int>)));
    //系统错误异常链接
    connect(pDoError,&DoError::upDateHistory,this,&WeldControl::updateHistroy);
    connect(pDoError,&DoError::upDateError,this,&WeldControl::updateError);
}
WeldControl::~WeldControl(){}

/* "平焊单边V形坡口T接头",  "平焊单边V形坡口平对接",  "平焊V形坡口平对接",
    "横焊单边V形坡口T接头",  "横焊单边V形坡口平对接",
    "立焊单边V形坡口T接头",  "立焊单边V形坡口平对接", "立焊V形坡口平对接",
    "水平角焊"*/
void WeldControl::setGroove(int value){pWeldMath->grooveValue=value;}
void WeldControl::setWeldStyle(int value){
    pSysMath->weldStyleName=value==0?"平焊":value==1?"横焊":value==2?"立焊":"水平角焊";
    modbusDataType cmd;cmd.rw=WRITE;cmd.reg=88;cmd.num=1;cmd.data[0]=value==2?0:value; cmd.error=0;pModbus->setmodbusFrame(cmd);
}
void WeldControl::setGrooveStyle(int value){
    pSysMath->grooveStyleName=value?"V形坡口":"单边V形坡口";
    modbusDataType cmd;cmd.rw=WRITE;cmd.reg=89;cmd.num=1;cmd.data[0]=value; cmd.error=0;pModbus->setmodbusFrame(cmd);
}
void WeldControl::setConnectStyle(int value){
    pSysMath->weldConnectName=value?"平对接":"T接头";
    modbusDataType cmd;cmd.rw=WRITE;cmd.reg=90;cmd.num=1;cmd.data[0]=value; cmd.error=0;pModbus->setmodbusFrame(cmd);
}
void WeldControl::setCeramicBack(int value){
    pSysMath->ceramicBack=value;
    pSysMath->bottomFloor=pSysMath->ceramicBack==1?&pWeldMath->bottomFloor0:&pWeldMath->bottomFloor;
    modbusDataType cmd;cmd.rw=WRITE;cmd.reg=90;cmd.num=1;cmd.data[0]=value; cmd.error=0;pModbus->setmodbusFrame(cmd);
}
//示教模式
void WeldControl::setTeachMode(int value){modbusDataType cmd;cmd.rw=WRITE;cmd.reg=100;cmd.num=1;cmd.data[0]=value; cmd.error=0;pModbus->setmodbusFrame(cmd);}
//焊接始终端检测
void WeldControl::setWeldStartStop(int value){modbusDataType cmd;cmd.rw=WRITE;cmd.reg=101;cmd.num=1;cmd.data[0]=value; cmd.error=0;pModbus->setmodbusFrame(cmd);}
//示教第一点位置
void WeldControl::setTeachFirstPoint(int value){modbusDataType cmd;cmd.rw=WRITE;cmd.reg=102;cmd.num=1;cmd.data[0]=value; cmd.error=0;pModbus->setmodbusFrame(cmd);}
//示教点数
void WeldControl::setTeachPointNum(int value){modbusDataType cmd;cmd.rw=WRITE;cmd.reg=103;cmd.num=1;cmd.data[0]=value; cmd.error=0;pModbus->setmodbusFrame(cmd);}
//weldLength
void WeldControl::setWeldLength(int value){modbusDataType cmd;cmd.rw=WRITE;cmd.reg=104;cmd.num=1;cmd.data[0]=value; cmd.error=0;pModbus->setmodbusFrame(cmd);}
//坡口检测点左侧距离
void WeldControl::setGrooveCheckLeftLength(int value){modbusDataType cmd;cmd.rw=WRITE;cmd.reg=105;cmd.num=1;cmd.data[0]=value; cmd.error=0;pModbus->setmodbusFrame(cmd);}
//坡口检测点右侧距离
void WeldControl::setGrooveCheckRightLength(int value){modbusDataType cmd;cmd.rw=WRITE;cmd.reg=106;cmd.num=1;cmd.data[0]=value; cmd.error=0;pModbus->setmodbusFrame(cmd);}
//头部摆动方式[W,99,1]
void WeldControl::setSwingWay(int value){
    modbusDataType cmd;cmd.rw=WRITE;cmd.reg=99;cmd.num=1;cmd.data[0]=value; cmd.error=0;pModbus->setmodbusFrame(cmd);
    cmd.reg=130;cmd.num=2;
    switch(value){
    case 0:cmd.data[0]=0;cmd.data[1]=0;break;
    case 1:cmd.data[0]=22;cmd.data[1]=0;break;
    case 2:cmd.data[0]=0;cmd.data[1]=22;break;
    case 3:cmd.data[0]=22;cmd.data[1]=22;break;
    }
    pModbus->setmodbusFrame(cmd);
}
//设置干伸长[W,120,1]
void WeldControl::setWeldOutLength(int value){modbusDataType cmd;cmd.rw=WRITE;cmd.reg=120;cmd.num=1;cmd.data[0]=value; cmd.error=0;pModbus->setmodbusFrame(cmd);}
//焊接电流偏置[W,128,1]
void WeldControl::setWeldCurrentOffset(int value){modbusDataType cmd;cmd.rw=WRITE;cmd.reg=128;cmd.num=1;cmd.data[0]=value; cmd.error=0;pModbus->setmodbusFrame(cmd);}
//焊接电压偏置[W,129,1]
void WeldControl::setWeldVoltageOffset(int value){modbusDataType cmd;cmd.rw=WRITE;cmd.reg=129;cmd.num=1;cmd.data[0]=value; cmd.error=0;pModbus->setmodbusFrame(cmd);}
//提前送气时间[W,132,1]
void WeldControl::setGasBeforeWeld(int value){modbusDataType cmd;cmd.rw=WRITE;cmd.reg=132;cmd.num=1;cmd.data[0]=value; cmd.error=0;pModbus->setmodbusFrame(cmd);}
//滞后送气时间[W,133,1]
void WeldControl::setGasAfterWeld(int value){modbusDataType cmd;cmd.rw=WRITE;cmd.reg=133;cmd.num=1;cmd.data[0]=value; cmd.error=0;pModbus->setmodbusFrame(cmd);}
//起弧停留时间[W,134,1]
void WeldControl::setStartArcStatyTime(int value){modbusDataType cmd;cmd.rw=WRITE;cmd.reg=134;cmd.num=1;cmd.data[0]=value; cmd.error=0;pModbus->setmodbusFrame(cmd);}
//收弧停留时间[W,135,1]
void WeldControl::setStopArcStatyTime(int value){modbusDataType cmd;cmd.rw=WRITE;cmd.reg=135;cmd.num=1;cmd.data[0]=value; cmd.error=0;pModbus->setmodbusFrame(cmd);}
//起弧电流[W,136,1]
void WeldControl::setStartArcCurrent(int value){modbusDataType cmd;cmd.rw=WRITE;cmd.reg=136;cmd.num=1;cmd.data[0]=value; cmd.error=0;pModbus->setmodbusFrame(cmd);}
//起弧电压[W,137,1]
void WeldControl::setStartArcVoltage(int value){modbusDataType cmd;cmd.rw=WRITE;cmd.reg=137;cmd.num=1;cmd.data[0]=value; cmd.error=0;pModbus->setmodbusFrame(cmd);}
//收弧电流[W,138,1]
void WeldControl::setStopArcCurrent(int value){modbusDataType cmd;cmd.rw=WRITE;cmd.reg=138;cmd.num=1;cmd.data[0]=value; cmd.error=0;pModbus->setmodbusFrame(cmd);}
//收弧电压[W,139,1]
void WeldControl::setStopArcVoltgae(int value){modbusDataType cmd;cmd.rw=WRITE;cmd.reg=139;cmd.num=1;cmd.data[0]=value; cmd.error=0;pModbus->setmodbusFrame(cmd);}
//回烧电压补偿[W,300,1]
void WeldControl::setBrunBackVoltage(int value){modbusDataType cmd;cmd.rw=WRITE;cmd.reg=300;cmd.num=1;cmd.data[0]=value; cmd.error=0;pModbus->setmodbusFrame(cmd);}
//回烧时间1[W,301,1]
void WeldControl::setBrunBackTime1(int value){modbusDataType cmd;cmd.rw=WRITE;cmd.reg=301;cmd.num=1;cmd.data[0]=value; cmd.error=0;pModbus->setmodbusFrame(cmd);}
//回烧时间2[W,302,1]
void WeldControl::setBrunBackTime2(int value){modbusDataType cmd;cmd.rw=WRITE;cmd.reg=302;cmd.num=1;cmd.data[0]=value; cmd.error=0;pModbus->setmodbusFrame(cmd);}
//起弧停留时间[W,148,1]
void WeldControl::setStartArcTime(int value){modbusDataType cmd;cmd.rw=WRITE;cmd.reg=148;cmd.num=1;cmd.data[0]=value; cmd.error=0;pModbus->setmodbusFrame(cmd);}
//起弧摆动速度[W,149,1]
void WeldControl::setStartArcSwingSpeed(int value){modbusDataType cmd;cmd.rw=WRITE;cmd.reg=149;cmd.num=1;cmd.data[0]=value; cmd.error=0;pModbus->setmodbusFrame(cmd);}

/*
 * 算法相关
 */
void WeldControl::setReinforcement(float value){pSysMath->reinforcementValue=value;}
void WeldControl::setMeltingCoefficient(int value){pSysMath->meltingCoefficientValue=value;}
//设定顿边[W,161,1]
void WeldControl::setRootFace(float value){pSysMath->rootFace=value;modbusDataType cmd;cmd.rw=WRITE;cmd.reg=161;cmd.num=1;cmd.data[0]=value*10; cmd.error=0;pModbus->setmodbusFrame(cmd); }
//设置保护气体[W,124,1]
void WeldControl::setGas(int value){pSysMath->gasValue=value;modbusDataType cmd;cmd.rw=WRITE;cmd.reg=124;cmd.num=1;cmd.data[0]=value; cmd.error=0;pModbus->setmodbusFrame(cmd);}
//设置脉冲[W,119,1]
void WeldControl::setPulse(int value){ pSysMath->pulseValue=value;modbusDataType cmd;cmd.rw=WRITE;cmd.reg=119;cmd.num=1;cmd.data[0]=value; cmd.error=0;pModbus->setmodbusFrame(cmd);}
//设置焊丝种类[W,126,1]
void WeldControl::setWireType(int value){pSysMath->wireTypeValue=value;modbusDataType cmd;cmd.rw=WRITE;cmd.reg=126;cmd.num=1;cmd.data[0]=value; cmd.error=0;pModbus->setmodbusFrame(cmd);}
//设置焊丝直径[W,123,1]
void WeldControl::setWireD(int value){pSysMath->wireDValue=value;modbusDataType cmd;cmd.rw=WRITE;cmd.reg=123;cmd.num=1;cmd.data[0]=value; cmd.error=0;pModbus->setmodbusFrame(cmd);}
//设置坡口方向[W,122,1]
void WeldControl::setGrooveDir(bool value){pSysMath->grooveDirValue=value;modbusDataType cmd;cmd.rw=WRITE;cmd.reg=122;cmd.num=1;cmd.data[0]=value; cmd.error=0;pModbus->setmodbusFrame(cmd);}

void WeldControl::setReturnWay(int value){pSysMath->returnWay=value;}
void WeldControl::setStopInTime(int value){pSysMath->stopInTime=value;}
void WeldControl::setStopOutTime(int value){pSysMath->stopOutTime=value;}
void WeldControl::setStartArcZz(int value){pSysMath->startArcZz=value;}
void WeldControl::setStartArcZx(int value){pSysMath->startArcZx=value;}
void WeldControl::setStopArcZz(int value){pSysMath->stopArcZz=value;}
void WeldControl::setStopArcZx(int value){pSysMath->stopArcZx=value;}
bool WeldControl::setGrooveRules(int index, QObject *obj,bool ok){return pWeldMath->setGrooveRules(index,obj,ok);}
bool WeldControl::setLimited(QObject *value){return pWeldMath->setLimited(value);}
//设置各轴信息
void WeldControl::setMotoInfo(QList<int> qList){
    int i;modbusDataType cmd;
    for(i=0;i<qList.length();i++)
        cmd.data[i]=int16_t(qList.at(i));
    cmd.rw=WRITE;cmd.reg=26;cmd.num=20; cmd.error=0;pModbus->setmodbusFrame(cmd);
}
//获取坡口数据
void WeldControl::getGrooveData(){modbusDataType cmd;cmd.rw=READ;cmd.reg=150;cmd.num=10; cmd.error=0;pModbus->setmodbusFrame(cmd);}
//获取各轴信息
void WeldControl::getMotoInfo(){modbusDataType cmd;cmd.rw=READ;cmd.reg=1022;cmd.num=6; cmd.error=0;pModbus->setmodbusFrame(cmd);}
//获取版本信息
void WeldControl::getVersionInfo(){modbusDataType cmd;cmd.rw=READ;cmd.reg=500;cmd.num=3; cmd.error=0;pModbus->setmodbusFrame(cmd);}
//获取系统状态信息
void WeldControl::setSysStatusOk(){modbusDataType cmd;cmd.rw=WRITE;cmd.reg=25;cmd.num=1; cmd.error=0;cmd.data[0]=2;pModbus->setmodbusFrame(cmd);}
//系统状态改变为端部暂停态["W","0","1","5"]
void WeldControl::setSysStatusStop(){modbusDataType cmd;cmd.rw=WRITE;cmd.reg=0;cmd.num=1; cmd.error=0;cmd.data[0]=5;pModbus->setmodbusFrame(cmd);}
//写系统状态空闲 ["W","0","1","0"]
void WeldControl::setSysStatusIdle(){modbusDataType cmd;cmd.rw=WRITE;cmd.reg=0;cmd.num=1; cmd.error=0;cmd.data[0]=0;pModbus->setmodbusFrame(cmd);}
//获取系统状态["R","0","5"]
void WeldControl::getSysStatus(){modbusDataType cmd;cmd.rw=READ;cmd.reg=0;cmd.num=5; cmd.error=0;pModbus->setmodbusFrame(cmd);}
//获取钥匙开关状态["R","25","1"]
void WeldControl::getKeyStatus(){modbusDataType cmd;cmd.rw=READ;cmd.reg=25;cmd.num=1; cmd.error=0;pModbus->setmodbusFrame(cmd);}
//获取系统日期及时间信息
void WeldControl::getSysDateTime(){modbusDataType cmd;cmd.rw=READ;cmd.reg=510;cmd.num=6; cmd.error=0;pModbus->setmodbusFrame(cmd);}
//获取操作盒端设置["R","99","6"]
void WeldControl::getHMIset(){modbusDataType cmd;cmd.rw=READ;cmd.reg=99;cmd.num=6; cmd.error=0;pModbus->setmodbusFrame(cmd);}
//获取焊接长度["R","104","1"]
void WeldControl::getWeldLength(){modbusDataType cmd;cmd.rw=READ;cmd.reg=104;cmd.num=1; cmd.error=0;pModbus->setmodbusFrame(cmd);}
//设置系统时间
void WeldControl::setSysDateTime(QStringList qList){
    int i;modbusDataType cmd;
    for(i=0;i<6;i++)
        cmd.data[i]=int16_t(qList.at(i).toInt());
    cmd.rw=WRITE;cmd.reg=510;cmd.num=6; cmd.error=0;pModbus->setmodbusFrame(cmd);
}
//设置示教焊缝宽度跟踪关闭
void WeldControl::setTeachSwingOff(){modbusDataType cmd;cmd.rw=WRITE;cmd.reg=98;cmd.num=1; cmd.error=0;cmd.data[0]=0;pModbus->setmodbusFrame(cmd);}
//获取当前焊道号码
void WeldControl::getCurrentWeldNum(){modbusDataType cmd;cmd.rw=WRITE;cmd.reg=200;cmd.num=1; cmd.error=0;pModbus->setmodbusFrame(cmd);}
//下发焊接规范
void WeldControl::downLoadWeldRules(){

}

/*
 * modbus相关
 */
QString sysStatusList[]={"空闲态","坡口检测态","坡口检测完成态","焊接态","焊接中间暂停态","焊接端部暂停态","停止态","未登录态"};

#define ERROR_REG  3
#define RW_REG        0
#define REG_REG       1
#define NUM_REG     2
#define OFFSET_REG  4

void WeldControl::modbusReply(QList< int > reply){
    long long MathError=1;
    QJsonObject json;
    if(strcmp(pModbus->getModbusStatus(reply.at(ERROR_REG)),"Success")){
        MathError=1;
        MathError<<=25;
        errorCode=MathError;
        // errorMath(MathError);
        pDoError->errorMath(errorCode);
    }else{
        //查询系统状态
        if(reply.at(REG_REG)==0){
            if(reply.at(NUM_REG)==5){
                //获取系统状态
                sysStatus=sysStatusList[reply.at(OFFSET_REG)];
                emit upDateSysStatus(sysStatus);
                //获取系统错误警报
                MathError=int16_t(reply.at(OFFSET_REG+4));
                MathError<<=16;
                MathError|=int16_t(reply.at(OFFSET_REG+3));
                MathError<<=16;
                MathError=int16_t(reply.at(OFFSET_REG+2));
                MathError<<=16;
                MathError|=int16_t(reply.at(OFFSET_REG+1));
                errorCode=MathError;
                pDoError->errorMath(errorCode);
            }
        }else if((reply.at(REG_REG)==150)&&(sysStatus=="坡口检测态")){//更新坡口参数
            if(reply.at(NUM_REG)==10){
                json.insert("ID",QJsonValue(QString(reply.at(OFFSET_REG))));
                float b1,b2,r,a1,a2,x,y,z;
                b1=float(reply.at(OFFSET_REG+1))/10;
                b2=float(reply.at(OFFSET_REG+2))/10;
                r=float(reply.at(OFFSET_REG+3))/10;
                a1=float(reply.at(OFFSET_REG+4))/10;
                a2=float(reply.at(OFFSET_REG+5))/10;
                x=float(reply.at(OFFSET_REG+9))/10;
                y=float(reply.at(OFFSET_REG+8))/10;
                json.insert("C1",QJsonValue(QString::number(b1,'f',1)));
                json.insert("C2",QJsonValue(QString::number(b2,'f',1)));
                json.insert("C3",QJsonValue(QString::number(r,'f',1)));
                json.insert("C4",QJsonValue(QString::number(a1,'f',1)));
                json.insert("C5",QJsonValue(QString::number(a2,'f',1)));
                json.insert("C6",QJsonValue(QString::number(x,'f',1)));
                json.insert("C7",QJsonValue(QString::number(y,'f',1)));
                int z1;
                z1=int16_t(reply.at(OFFSET_REG+7))<<16;
                z1=reply.at(OFFSET_REG+6)|z1;
                z=float(z1)/10;
                json.insert("C8",QJsonValue(QString::number(z,'f',1)));
                emit updateGrooveData(json);
            }
        }else if((reply.at(REG_REG)==104)&&(sysStatus=="坡口检测完成态")){

        }else if((reply.at(REG_REG)==10)&&(sysStatus=="焊接态")){
            //记录焊接时间 查找当前焊接位置

        }else  if((reply.at(REG_REG)==200)&&((sysStatus=="焊接端部暂停态")||(sysStatus=="焊接中间暂停态"))){
            //下发焊接规范

        }else if(reply.at(REG_REG)==500){
            QObject obj;
            uint16_t temp;
            uint16_t bottomVer,softVer,bugVer;
            QString str;
            int i;
            for(i=0;i<3;i++){
                temp=reply.at(OFFSET_REG+i);
                bottomVer=temp|0xf000;
                softVer=temp|0x0f80;
                bugVer=temp|0x007f;
                str="Version "+QString(bottomVer)+"."+QString(softVer)+"."+QString(bugVer);
                obj.setProperty(i==0?"control":i==1?"driver":"hmi",str);
            }
            emit updateVersion(&obj);
        }else if(reply.at(REG_REG)==510){//读取系统时间
            if(reply.at(NUM_REG)==6){
                QStringList qList;
                qList.append(QString(reply.at(OFFSET_REG+0)));
                qList.append(QString(reply.at(OFFSET_REG+1)));
                qList.append(QString(reply.at(OFFSET_REG+2)));
                qList.append(QString(reply.at(OFFSET_REG+3)));
                qList.append(QString(reply.at(OFFSET_REG+4)));
                qList.append(QString(reply.at(OFFSET_REG+5)));
                emit updateDateTime(qList);
            }
        }else if(reply.at(REG_REG)==99){//读取设置
            if(reply.at(NUM_REG)==6){
                json.insert("RockWay",QJsonValue(reply.at(OFFSET_REG+0)));
                emit updateRockWay(json);
                json.insert("TeachMode",QJsonValue(reply.at(OFFSET_REG+1)));
                json.insert("StartStop",QJsonValue(reply.at(OFFSET_REG+2)));
                json.insert("FirstPointLeftOrRight",QJsonValue(reply.at(OFFSET_REG+3)));
                json.insert("TeachPoint",QJsonValue(reply.at(OFFSET_REG+4)));
                json.insert("WeldLength",QJsonValue(reply.at(OFFSET_REG+5)));
                emit updateTeachSet(json);
            }
        }else if(reply.at(REG_REG)==1022){ //读取电机位置
            int16_t m2,m3,m4,m5;
            int m1;
            m1=reply.at(OFFSET_REG+0);
            m1<<=16;
            m1|=reply.at(OFFSET_REG+1);
            if(reply.at(NUM_REG)>2){//获取各轴坐标
                json.insert("TravelPoint",QJsonValue(QString::number(float(m1)/10)));
                m2=int16_t(reply.at(OFFSET_REG+2));
                m3=int16_t(reply.at(OFFSET_REG+3));
                m4=int16_t(reply.at(OFFSET_REG+4));
                m5=int16_t(reply.at(OFFSET_REG+5));
                json.insert("SwingPoint",QJsonValue(QString::number(float(m2)/10)));
                json.insert("AvcPoint",QJsonValue(QString::number(float(m3)/10)));
                json.insert("RockPoint",QJsonValue(QString::number(float(m5)/10)+"度 "+QString::number(float(m4)/10)));
                emit updateMotoPoint(json);
            }
        }else if(reply.at(REG_REG)==25){//钥匙开关读取
            if(reply.at(NUM_REG)==1)
                emit updateKeyStatus(reply.at(OFFSET_REG+0)>0);
        }
    }
}

void WeldControl::setGrooveTableNullError(){
    long long errorCode;
    errorCode=pDoError->getErrorCode();
    errorCode|=0x20000000;
    modbusDataType cmd;
    cmd.rw=WRITE;
    cmd.reg=1;
    cmd.num=2;
    cmd.error=0;
    cmd.data[0]=errorCode&0x000000000000ffff;
    cmd.data[1]=(errorCode&0x00000000ffff0000)>>16;
    pModbus->setmodbusFrame(cmd);
}

void WeldControl::setWeldTableNullError(){
    long long errorCode;
    errorCode=pDoError->getErrorCode();
    errorCode|=0x80000000;
    modbusDataType cmd;
    cmd.rw=WRITE;
    cmd.reg=1;
    cmd.num=2;
    cmd.error=0;
    cmd.data[0]=errorCode&0x000000000000ffff;
    cmd.data[1]=(errorCode&0x00000000ffff0000)>>16;
    pModbus->setmodbusFrame(cmd);
}

void WeldControl::setMakeWeldRulesError(){
    long long errorCode;
    errorCode=pDoError->getErrorCode();
    errorCode|=0x40000000;
    modbusDataType cmd;
    cmd.rw=WRITE;
    cmd.reg=1;
    cmd.num=2;
    cmd.error=0;
    cmd.data[0]=errorCode&0x000000000000ffff;
    cmd.data[1]=(errorCode&0x00000000ffff0000)>>16;
    pModbus->setmodbusFrame(cmd);
}

QStringList WeldControl::getLimitedMath(QObject* value){
     return  pWeldMath->getLimitedMath(value);
}

