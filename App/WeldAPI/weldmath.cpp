#include "weldmath.h"
#define ENABLE_SOLVE_FIRST                              1
#include <QtMath>

QString sysStatusList[9]= {"空闲态","坡口检测态","坡口检测完成态","焊接态","焊接中间暂停态","焊接端部暂停态","停止态","未登录态","禁止登录态"};


//weldMath
WeldMath::WeldMath()
{
    pGroove=new groove();
    sysMath=new SysMath();
    // sysMath->pWeldDataTable=&weldDataTable[0];
    sysMath->pDispWeldDataTable=&dispWeldDataTable;
    sysMath->rootFace=0;
    sysMath->currentAdd=0;
    sysMath->arcAvcEn=false;
    sysMath->arcSwEn=false;
    sysMath->arcSwWEn=false;
#ifdef USE_MODBUS
    pERModbus=new ERModbus();
    errorCode=0;
    changeUserFlag=0;
    connect(pERModbus,&ERModbus::modbusFrameChanged,this,&WeldMath::modbusSlot);
#endif
    pTimer=new QTimer();
    pTimer->setInterval(200);
    pTimer->setSingleShot(false);
    connect(pTimer,&QTimer::timeout,this,&WeldMath::timeSolt);
    pSchedule=new QTimer();
    pSchedule->setInterval(500);
    pSchedule->setSingleShot(false);
    connect(pSchedule,&QTimer::timeout,this,&WeldMath::scheduleSolt);
    pSchedule->start();
    weldFix=false;
    //
    weldIndex=255;
    totalNum=0;
    motoStatus=false;
}
WeldMath::~WeldMath(){
    sysMath->~SysMath();
#ifdef USE_MODBUS
    pERModbus->~ERModbus();
#endif
}
void WeldMath::setFixWeld(bool ok){
    fixWeld=ok;
    qDebug()<<"fixWeld"<<fixWeld;
}

void WeldMath::setFixPara(int a, int b, int c, int d,int e){
    startExternZ=d;
    stopExternZ=c;
   // restDeepA=a;
   // restDeepB=b;
    //radius=e;
}

void setSysDateTime(QList<int > value){
    //设置系统时间 格式为 date -s "2016-05-03 10:10:10" [[[[[YY]YY]MM]DD]hh]mm[.ss]
    QString s;
    int i;
    s="date -s \"20";
    for(i=2;i<value.length();i++){
        if(value.at(i)<10){
            s+="0";
        }
        s+=QString::number(value.at(i));
        if(i<4)
            s+="-";
        else if(i==4)
            s+=" ";
        else if(i<7)
            s+=":";
        else
            s+="\"";
    }
    qDebug()<<s;
    //调用系统命令
    system(s.toLatin1().data());
}
void WeldMath::setSysStatus(QString status){
    sysStatus=status;
    sysStatus=="空闲态"?0:sysStatus=="坡口检测态"?2:sysStatus=="坡口检测完成态"?3:sysStatus=="焊接态"?4:\
                                                                                          sysStatus=="焊接中间暂停态"?5:  sysStatus=="焊接端部暂停态"?6:7;
}
//组合成新的Modbus命令帧
void makeModbusFrame(int cmd,int reg,int num,int value,QList<int> *p){
    // p->length=0;
    p->clear();
    p->append(cmd);
    p->append(reg);
    p->append(num);
    p->append(value);
}
void WeldMath::readVersion(){
    QList<int> modbusList;
    makeModbusFrame(MODBUS_FC_READ_HOLDING_REGISTERS,REG_VERSION,3,0,&modbusList);
    pERModbus->setmodbusFrame(modbusList);
}
void WeldMath::getDateTime(){
    QList<int> modbusList;
    makeModbusFrame(MODBUS_FC_READ_HOLDING_REGISTERS,REG_READ_DATETIME,6,0,&modbusList);
    pERModbus->setmodbusFrame(modbusList);
}
void WeldMath::getMotoPoint(bool status){
    motoStatus=status;
  //  QList<int> modbusList;
  //  makeModbusFrame(MODBUS_FC_READ_HOLDING_REGISTERS,REG_ROCK_MOTO_CURRENT_POINT,6,0,&modbusList);
  //  pERModbus->setmodbusFrame(modbusList);
}
void WeldMath::getWeldLength(void){
    QList<int> modbusList;
    makeModbusFrame(MODBUS_FC_READ_HOLDING_REGISTERS,REG_WELD_LENGTH,1,0,&modbusList);
    pERModbus->setmodbusFrame(modbusList);
}
void WeldMath::setDateTime(QStringList dateTime){
    QList<int> modbusList;
    QList<int> datetime;
    unsigned char i;
    modbusList.clear();
    modbusList.append(MODBUS_FC_WRITE_MULTIPLE_REGISTERS);
    modbusList.append(REG_READ_DATETIME);
    modbusList.append(6);
    datetime.clear();
    datetime.append(0);
    datetime.append(0);
    QString temp;
    bool ok;
    for(i=0;i<6;i++){
        temp=dateTime.at(i);
        modbusList.append(temp.toInt(&ok,10));
        datetime.append(temp.toInt(&ok,10));
    }
    pERModbus->setmodbusFrame(modbusList);
    setSysDateTime(datetime);
    //
}
void WeldMath::setMoto(QList<int> value){
    QList<int> modbusList;
    unsigned char i;
    modbusList.clear();
    modbusList.append(MODBUS_FC_WRITE_MULTIPLE_REGISTERS);
    modbusList.append(REG_ROCK_MOTO_ORG);
    modbusList.append(value.length());
    for(i=0;i<value.length();i++){
        modbusList.append(value.at(i));
    }
    pERModbus->setmodbusFrame(modbusList);
}
void WeldMath::setPath(QList<int> value){
    QList<int> modbusList;
    unsigned char i;
    modbusList.clear();
    modbusList.append(MODBUS_FC_WRITE_MULTIPLE_REGISTERS);
    modbusList.append(REG_PATH);
    modbusList.append(value.length());
    for(i=0;i<value.length();i++){
        modbusList.append(value.at(i));
    }
    pERModbus->setmodbusFrame(modbusList);
}

/*设置相关参数*/
int WeldMath::setPara(QString name, int value,bool send,bool save){
    QList<int> modbusList;
    int res=0;
    save=save;
    int reg=-1;
    if(name=="sysStatus"){
        reg=REG_SYSTEM_STATUS;
    }else if(name=="weldStyle"){
        sysMath->weldStyleName=value==0?"平焊":value==1?"横焊":value==2?"立焊":"水平角焊";
        reg=REG_WELD_STYLE;
    }else if(name=="grooveStyle"){
        sysMath->grooveStyleName=value==0?"单边V形坡口":"V形坡口";
        reg=REG_GROOVE_STYLE;
    }else if(name=="connectStyle"){
        sysMath->weldConnectName=value==0?"T接头":"对接头";
        reg=REG_CONNECT_STYLE;
    }else if(name=="bottomStyle"){
        sysMath->ceramicBack=value;
        sysMath->bottomFloor=value==1?&bottomFloor0:&bottomFloor;
        reg=REG_BOTTOM_STYLE;
    }else if(name=="teachMode"){
        reg=REG_TEACH_MODE;
    }else if(name=="startEndCheck"){
        reg=REG_START_STOP;
    }else if(name=="teachFirstPoint"){
        sysMath->teachFirstPoint=value;
        reg=REG_TEACH_FIRST_POINT;
    }else if(name=="teachPoint"){
        sysMath->teachPoint=value;
        reg=REG_TEACH_POINT;
    }else if(name=="weldLength"){
        reg=REG_WELD_LENGTH;
    }else if(name=="checkLeft"){
        sysMath->checkLeftLength=value;
        reg=REG_TEACH_LEFT;
    }else if(name=="checkRight"){
        sysMath->checkRightLength=value;
        reg=REG_TEACH_RIGHT;
    }else if(name=="wireLength"){
        reg=REG_WELD_WIRE_LENGTH;
    }else if(name=="swingWay"){
        reg=REG_ROCK_WAY;
    }else if(name=="grooveDir"){
        reg=REG_GROOVE_DIR;
        pGroove->grooveDir=value;
        sysMath->grooveDir=value;
    }else if(name=="beforeGas"){
        reg=REG_START_GAS_TIME;
    }else if(name=="afterGas"){
        reg=REG_STOP_GAS_TIME;
    }else if(name=="startArcTime"){
        reg=REG_START_ARC_STAY_TIME;
    }else if(name=="stopArcTime"){
        reg=REG_STOP_ARC_STAY_TIME;
    }else if(name=="startArcCurrent"){
        reg=REG_START_CURRENT;
    }else if(name=="startArcVoltage"){
        reg=REG_START_VOLTAGE;
    }else if(name=="stopArcCurrent"){
        reg=REG_STOP_CURRENT;
    }else if(name=="stopArcVoltgae"){
        reg=REG_STOP_VOLTAGE;
    }else if(name=="stopArcBackLength"){
        reg=REG_STOP_ARC_BACK_LENGTH;
    }else if(name=="stopArcBackSpeed"){
        reg=REG_STOP_ARC_BACK_SPEED;
    }else if(name=="stopArcBackTime"){
        reg=REG_STOP_ARC_BACK_TIME;
    }else if(name=="voltageBack"){
        reg=REG_BURN_BACK_VOLTAGE;
    }else if(name=="time1Back"){
        reg=REG_BURN_BACK1;
    }else if(name=="time2Back"){
        reg=REG_BURN_BACK2;
    }else if(name=="reinforcement"){
        sysMath->reinforcement=value;
    }else if(name=="meltingCoefficient"){
        sysMath->meltingCoefficient=value;
    }else if(name=="rootFace"){
        sysMath->rootFace=float(value/10);
        pGroove->rootFace=float(value/10);
        reg=REG_ROOTFACE;
    }else if(name=="stopInTime"){
        sysMath->stopInTime=value;
    }else if(name=="stopOutTime"){
        sysMath->stopOutTime=value;
    }else if(name=="gas"){
        sysMath->gas=value;
        reg=REG_GAS;
    }else if(name=="pulse"){
        sysMath->pulse=value;
        reg=REG_PULSE;
    }else if(name=="wireType"){
        sysMath->wireType=value;
        reg=REG_WIRE_TYPE;
    }else if(name=="wireD"){
        sysMath->wireDValue=value;
        reg=REG_WIRE_D;
    }else if(name=="grooveValue"){
        grooveValue=value;
    }else if(name=="returnWay"){
        sysMath->returnWay=value;
    }else if(name=="startArcZz"){
        sysMath->startArcZz=value;
    }else if(name=="startArcZx"){
        sysMath->startArcZx=value;
    }else if(name=="stopArcZz"){
        sysMath->stopArcZz=value;
    }else if(name=="stopArcZx"){
        sysMath->stopArcZx=value;
    }else if(name=="currentAdd"){
        sysMath->currentAdd=value;
        reg=REG_CURRENT_ADD;
    }else if(name=="voltageAdd"){
        sysMath->voltageAdd=value;
        reg=REG_VOLTAGE_ADD;
    }else if(name=="signedIn"){
        reg=REG_SYSTEM_UP;
    }else if(name=="startArcStayTime"){
        reg=REG_START_ACR_STAY_TIME;
    }else if(name=="startArcSwingSpeed"){
        reg=REG_START_ACR_SWING_SPEED;
    }else if(name=="arcAvcEn"){
        if(value>0){
            sysMath->arcAvcEn=true;
        }else{
              sysMath->arcAvcEn=false;
        }
        reg=REG_ARC_AVC_EN;
    }else if(name=="arcAvcAdj"){
        reg=REG_ARC_AVC_ADJ;
    }else if(name=="arcAvcMax"){
        reg=REG_ARC_AVC_MAX;
    }else if(name=="arcSwEn"){
        if(value>0){
            sysMath->arcSwEn=true;
        }else{
              sysMath->arcSwEn=false;
        }
        reg=REG_ARC_SW_EN;
    }else if(name=="arcSwAdj"){
        reg=REG_ARC_SW_ADJ;
    }else if(name=="arcSwMax"){
        reg=REG_ARC_SW_MAX;
    }else if(name=="arcSwWEn"){
        if(value>0){
            sysMath->arcSwWEn=true;
        }else{
              sysMath->arcSwWEn=false;
        }
        reg=REG_ARC_SW_W_EN;
    }else if(name=="arcSwWAdj"){
        reg=REG_ARC_SW_W_ADJ;
    }else if(name=="arcSwWMax"){
        reg=REG_ARC_SW_W_MAX;
    }else{
        res=-1;
    }
    if((send)&&(reg!=-1)){
        makeModbusFrame(MODBUS_FC_WRITE_SINGLE_REGISTER,reg,1,value,&modbusList);
        pERModbus->setmodbusFrame(modbusList);
        if(reg==REG_ROCK_WAY){
            modbusList.clear();
            modbusList.append(MODBUS_FC_WRITE_MULTIPLE_REGISTERS);
            modbusList.append(REG_ROCK_LEFT);
            modbusList.append(2);
            switch(value){
            case 0:modbusList.append(0);modbusList.append(0);break;
            case 1:modbusList.append(24);modbusList.append(0);break;
            case 2:modbusList.append(0);modbusList.append(24);break;
            case 3:modbusList.append(24);modbusList.append(24);break;
            }
            pERModbus->setmodbusFrame(modbusList);
        }
    }
    return res;
}
int WeldMath::setGrooveRulesTable(QObject *value,int index){
    if(index>MAX_TEACHPOINT)
        return ERROR_TEACHPOINT_MAX;
    else{
        //如果为零则清空坡口数据表格
        if(index==0){
            //数据长度清零
            pGroove->index=0;
            pGroove->name=sysMath->weldStyleName=="水平角焊"?"水平角焊":sysMath->weldConnectName=="T接头"?"T接头":"对接头";
        }
        if(index==pGroove->index){
            //存储坡口数据
            return pGroove->setGrooveRules(&(weldDataTable[index].grooveRules),value);
        }
        else
            return -1;
        qDebug()<<index<<pGroove->index;
    }
}
int WeldMath::getWeldMath(){
    unsigned char i;
    int res;
    qDebug()<<"sysMath->teachPoint:"<<sysMath->teachPoint;
    qDebug()<<"pGroove->index:"<<pGroove->index;
    if(sysMath->teachPoint>30) return ERROR_TEACHPOINT_MAX;
    if(sysMath->teachPoint!=pGroove->index) return ERROR_TEACHPOINT_MIN;
    if(sysMath->teachPoint>1){
        //重新对坡口数据进行排序
        //第一点z坐标减最后一点坐标为负 则表明从右往左焊接否则从左往右焊接
        sysMath->weldTravelDir=weldDataTable[0].grooveRules.z-weldDataTable[sysMath->teachPoint-1].grooveRules.z>0?true:false;
        //确定从哪边开始焊接
        pGroove->reorderGrooveList(&weldDataTable[0],sysMath->weldTravelDir);

        if(sysMath->weldTravelDir){
            //左往右焊接 延长焊缝
            startZ=weldDataTable[0].grooveRules.z-startExternZ;
            stopZ=weldDataTable[sysMath->teachPoint-1].grooveRules.z+stopExternZ;
        }else{
            //从右往左焊
            startZ=weldDataTable[0].grooveRules.z+startExternZ;
            stopZ=weldDataTable[sysMath->teachPoint-1].grooveRules.z-stopExternZ;
        }

        weldDataTable[0].grooveRules.z=startZ;
        weldDataTable[sysMath->teachPoint-1].grooveRules.z=stopZ;

        qDebug()<<"startZ"<<startZ;
        qDebug()<<"stopZ"<<stopZ;
        //获取平均坡口数值
        pGroove->getGrooveRulesAv(&dispWeldDataTable.grooveRules,&weldDataTable[0],sysMath->teachPoint);
        //坡口数据大于1点
        if(sysMath->teachPoint>1){
            //计算焊接长度
            sysMath->weldLength=weldDataTable[0].grooveRules.z-weldDataTable[sysMath->teachPoint].grooveRules.z;
            //weldLength焊接长度发生改变
            emit er100_UpdateWeldLength(qRound(sysMath->weldLength));
        }
        //计算显示坡口
        res=sysMath->weldMath(&dispWeldDataTable);
        qDebug()<<res;
        if(res!=NO_ERROR) return res;
        //计算实际坡口数据
        for(i=0;i<sysMath->teachPoint;i++){
            res=sysMath->weldMath(&weldDataTable[i]);
            qDebug()<<res;
            if(res!=NO_ERROR) return res;
        }
        //计算焊接各层道坐标

        //计算Z轴坐标
        //startArcZz stopArcZz  层间偏移
        //startArcZx stopArcZx  层内偏移
        weldPointType *pPoint,*ps,*pe;
        int index;
        unsigned char j;
        index=0;
        float last_startz;
        last_startz=0;
        for(i=0;i<dispWeldDataTable.length;i++){
            for(j=0;j<dispWeldDataTable.weldDataFloorTable[i].length;j++){
                pPoint=&dispWeldDataTable.weldDataFloorTable[i].weldPointTable[j];
                ps=&weldDataTable[0].weldDataFloorTable[i].weldPointTable[j];
                pe=&weldDataTable[sysMath->teachPoint-1].weldDataFloorTable[i].weldPointTable[j];
                //判断正负
                if(startZ>stopZ){
                    pPoint->startArcZ=startZ+i*sysMath->startArcZz+j*sysMath->startArcZx;
                    pPoint->stopArcZ=stopZ-i*sysMath->stopArcZz-j*sysMath->stopArcZx;
                }else{
                    pPoint->startArcZ=startZ-i*sysMath->startArcZz-j*sysMath->startArcZx;
                    pPoint->stopArcZ=stopZ+i*sysMath->stopArcZz+j*sysMath->stopArcZx;
                }
                if((sysMath->returnWay==1)&&(index%2)){
                    last_startz=pPoint->startArcZ;
                    pPoint->startArcZ=pPoint->stopArcZ;
                    pPoint->stopArcZ=last_startz;
                    pPoint->startArcX=pe->startArcX;
                    pPoint->stopArcX=ps->stopArcX;
                }else if((sysMath->returnWay==2)&&(i%2)){
                    last_startz=pPoint->startArcZ;
                    pPoint->startArcZ=pPoint->stopArcZ;
                    pPoint->stopArcZ=last_startz;
                    pPoint->startArcX=pe->startArcX;
                    pPoint->stopArcX=ps->stopArcX;
                }else{
                    pPoint->startArcX=ps->startArcX;
                    pPoint->stopArcX=pe->stopArcX;
                }
                index++;
            }
        }
        //更新焊接数据表格
        weldDataType* p ;
        weldPointType* pP;
        qJsonList.clear();
        if(dispWeldDataTable.length>MAX_WELDFLOOR){
            return ERROR_WELDFLOOR_MAX;
        }
        for(int i=0;i<dispWeldDataTable.length;i++){
            for(int j=0;j<dispWeldDataTable.weldDataFloorTable[i].length;j++){
                if(dispWeldDataTable.weldDataFloorTable[i].length>MAX_WELDNUM){
                    return ERROR_WELDNUM_MAX;
                }
                p=&dispWeldDataTable.weldDataFloorTable[i].weldDataTable[j];
                pP=&dispWeldDataTable.weldDataFloorTable[i].weldPointTable[j];
                pJson.insert("ID",QJsonValue(QString::number(p->index)));
                pJson.insert("C1",QJsonValue(QString::number(p->floor)+"/"+QString::number(p->num)));
                pJson.insert("C2",QJsonValue(QString::number(p->weldCurrent)));
                pJson.insert("C3",QJsonValue(QString::number(float(qRound(p->weldVoltage*10))/10)));
                pJson.insert("C4",QJsonValue(QString::number(float(qRound(p->swingLength*5))/10)));
                pJson.insert("C5",QJsonValue(QString::number(float(qRound(p->swingSpeed*10))/10)));
                pJson.insert("C6",QJsonValue(QString::number(float(qRound(p->weldTravelSpeed))/10)));
                pJson.insert("C7",QJsonValue(QString::number(float(qRound(pP->weldLineX*10))/10)));
                pJson.insert("C8",QJsonValue(QString::number(float(qRound(pP->weldLineY*10))/10)));
                pJson.insert("C9",QJsonValue(QString::number(float(qRound(p->outSwingStayTime*10))/10)));
                pJson.insert("C10",QJsonValue(QString::number(float(qRound(p->interSwingStayTime*10))/10)));
                pJson.insert("C11",QJsonValue(QString::number(float(qRound(p->stopTime*10))/10)));
                pJson.insert("C12",QJsonValue(QString::number(float(qRound(p->s*10))/10)));
                pJson.insert("C13",QJsonValue(QString::number(float(qRound(p->weldFill*10))/10)));
                pJson.insert("C14",QJsonValue(QString::number(float(qRound(pP->startArcX*10))/10)));
                pJson.insert("C15",QJsonValue(QString::number(float(qRound(pP->startArcY*10))/10)));
                pJson.insert("C16",QJsonValue(QString::number(float(qRound(pP->startArcZ*10))/10)));
                pJson.insert("C17",QJsonValue(QString::number(float(qRound(pP->stopArcX*10))/10)));
                pJson.insert("C18",QJsonValue(QString::number(float(qRound(pP->stopArcY*10))/10)));
                pJson.insert("C19",QJsonValue(QString::number(float(qRound(pP->stopArcZ*10))/10)));
                //
                qJsonList.append(QVariant(pJson));
            }
        }
        er100_UpdateWeldRules(qJsonList);

        unsigned char k;

        for(int i=0;i<dispWeldDataTable.length;i++){
            for(int j=0;j<dispWeldDataTable.weldDataFloorTable[i].length;j++){
                p=&dispWeldDataTable.weldDataFloorTable[i].weldDataTable[j];
                pP=&dispWeldDataTable.weldDataFloorTable[i].weldPointTable[j];
                qDebug()<<"T"<<255<<" F"<<p->floor<<" NUM"<<p->num<<" A"<<p->weldCurrent<<" V"<<p->weldVoltage<<" SL"<<p->swingLength<<" HZ"<<p->swingSpeed<<"A"<<p->A<<" SP"<<p->weldTravelSpeed
                       <<"X"<<pP->weldLineX;
            }
        }
        for(k=0;k<sysMath->teachPoint;k++){
            for(int i=0;i<weldDataTable[k].length;i++){
                for(int j=0;j<weldDataTable[k].weldDataFloorTable[i].length;j++){
                    p=&weldDataTable[k].weldDataFloorTable[i].weldDataTable[j];
                    pP=&weldDataTable[k].weldDataFloorTable[i].weldPointTable[j];
                    qDebug()<<"T"<<i<<" F"<<p->floor<<" NUM"<<p->num<<" A"<<p->weldCurrent<<" V"<<p->weldVoltage<<" SL"<<p->swingLength<<" HZ"<<p->swingSpeed<<"A"<<p->A<<" SP"<<p->weldTravelSpeed
                           <<" X"<<pP->weldLineX;
                }
            }
        }
        return NO_ERROR;
    }else
        return ERROR_TEACHPOINT_MIN;
}
QStringList WeldMath::getLimitedMath(QObject *value){
    limitedString.clear();
    if(value==NULL) return limitedString;
    QString str;
    QVariant var=value->property("C1");
    QStringList strList;
    str =var.toString();
    strList=str.split("/");
    if(strList.length()==3){
        limitedString.append(strList[0]);
        limitedString.append(strList[1]);
        limitedString.append(strList[2]);
    }else
        return limitedString;
    //
    var=value->property("C2");
    str=var.toString();
    strList=str.split("/");
    if(strList.length()==2){
        limitedString.append(strList[0]);
        limitedString.append(strList[1]);
    }else
        return limitedString;
    //解析层高
    var=value->property("C3");
    str=var.toString();
    strList=str.split("/");
    if(strList.length()==2){
        limitedString.append(strList[0]);
        limitedString.append(strList[1]);
    }else
        return limitedString;
    //坡口距离
    var=value->property("C4");
    str=var.toString();
    strList=str.split("/");
    if(strList.length()==2){
        limitedString.append(strList[0]);
        limitedString.append(strList[1]);
    }else
        return limitedString;
    //最大摆宽
    var=value->property("C5");
    limitedString.append(var.toString());
    //分道间隔
    var=value->property("C6");
    limitedString.append(var.toString());
    //分开结束比
    var=value->property("C7");
    limitedString.append(var.toString());
    //焊接电压
    var=value->property("C8");
    limitedString.append(var.toString());
    //焊接速度
    var=value->property("C9");
    str=var.toString();
    strList=str.split("/");
    if(strList.length()==2){
        limitedString.append(strList[0]);
        limitedString.append(strList[1]);
    }else
        return limitedString;
    var=value->property("C10");
    limitedString.append(var.toString());
    return limitedString;
}
bool WeldMath::setLimited(QObject *value){
    QString str;
    QStringList strList;
    FloorCondition *p;
    if(value==NULL){
        return false;
    }else{
        QVariant var=value->property("ID");
        if(var.type()==QVariant::String){
            str=var.toString();
            if(str=="陶瓷衬垫"){
                p=&bottomFloor0;
                p->name="ceramicBackFloor";
                sysMath->bottomFloor=sysMath->ceramicBack==1?&bottomFloor0:&bottomFloor;
            }else if(str=="打底层"){
                p=&bottomFloor;
                p->name="bottomFloor";
                sysMath->bottomFloor=sysMath->ceramicBack==1?&bottomFloor0:&bottomFloor;
            }else if(str=="第二层"){
                p=&secondFloor;
                p->name="secondFloor";
                sysMath->secondFloor=&secondFloor;
            }else if(str=="填充层"){
                p=&fillFloor;
                p->name="fillFloor";
                sysMath->fillFloor=&fillFloor;
            }else if(str=="盖面层"){
                p=&topFloor;
                p->name="topFloor";
                sysMath->topFloor=&topFloor;
            }else
                return false;
            //解析电流
            var=value->property("C1");
            if(var.type()==QVariant::String){
                str=var.toString();
                strList=str.split("/");
                if(strList.length()==3){
                    p->current_left=strList[0].toFloat();
                    p->current_middle=strList[1].toFloat();
                    p->current_right=strList[2].toFloat();
                    p->current=p->current_left;
                }else
                    return false;
            }else
                return false;
            //解析停留时间
            var=value->property("C2");
            if(var.type()==QVariant::String){
                str=var.toString();
                strList=str.split("/");
                if(strList.length()==2){
                    p->swingGrooveStayTime=strList[0].toFloat();
                    p->swingNotGrooveStayTime=strList[1].toFloat();
                    p->totalStayTime=p->swingGrooveStayTime+p->swingNotGrooveStayTime;
                    p->totalStayTime=float(qRound(10*p->totalStayTime))/10;
                }else
                    return false;
            }else
                return false;
            //解析层高
            var=value->property("C3");
            if(var.type()==QVariant::String){
                str=var.toString();
                strList=str.split("/");
                if(strList.length()==2){
                    p->minHeight=strList[0].toFloat();
                    p->maxHeight=strList[1].toFloat();
                }else
                    return false;
            }else
                return false;
            //坡口距离
            var=value->property("C4");
            if(var.type()==QVariant::String){
                str=var.toString();
                strList=str.split("/");
                if(strList.length()==2){
                    p->swingLeftLength=strList[0].toFloat();
                    p->swingRightLength=strList[1].toFloat();
                }else
                    return false;
            }else
                return false;
            //最大摆宽
            var=value->property("C5");
            if(var.type()==QVariant::String){
                str=var.toString();
                p->maxSwingLength=str.toFloat();
            }else
                return false;
            //分道间隔
            var=value->property("C6");
            if(var.type()==QVariant::String){
                str=var.toString();
                p->weldSwingSpacing=str.toFloat();
            }else
                return false;
            //分开结束比
            var=value->property("C7");
            if(var.type()==QVariant::String){
                str=var.toString();
                p->k=str.toFloat();
            }else
                return false;
            //焊接电压
            var=value->property("C8");
            if(var.type()==QVariant::String){
                str=var.toString();
                p->voltage=str.toFloat();
            }else
                return false;
            //焊接速度
            var=value->property("C9");
            if(var.type()==QVariant::String){
                str=var.toString();
                strList=str.split("/");
                if(strList.length()==2){
                    p->minWeldSpeed=strList[0].toFloat();
                    p->maxWeldSpeed=strList[1].toFloat();
                }else
                    return false;
            }else
                return false;
            return true;
        }else
            return false;
    }
}

#ifdef USE_MODBUS

void WeldMath::scheduleSolt(){
    QList<int> modbusList;
    if(((sysStatus=="焊接态")&&(weldIndex!=200))||(motoStatus)){
        makeModbusFrame(MODBUS_FC_READ_HOLDING_REGISTERS,REG_ROCK_MOTO_CURRENT_POINT,6,0,&modbusList);
        pERModbus->setmodbusFrame(modbusList);
    }
}
void WeldMath::initWeldMath(){
    totalNum=0;
    weldIndex=255;

    weldAdd.weldCurrent=0;
    weldAdd.weldTravelSpeed=0;
    weldAdd.weldVoltage=0;
    weldAdd.interSwingStayTime=0;
    weldAdd.outSwingStayTime=0;
    weldAdd.stopTime=0;
    weldAdd.swingLength=0;
    weldAdd.swingSpeed=0;
    weldAdd.startArcX=0;
    weldAdd.startArcY=0;
    weldAdd.startArcZ=0;
    weldAdd.stopArcX=0;
    weldAdd.stopArcY=0;
    weldAdd.stopArcZ=0;

    currentNum=0;
    currentFloor=0;

    weldFix=false;
    lastMotoPoint=0;
}
void WeldMath::getWeldDataRules(){
    weldDataType* pD1;
    weldDataType* pD;
    weldDataType p;
    weldPointType* pP;
    weldPointType* pP1;
    grooveRulesType *pG,* pG1;
    modBusWeldType weldData;
    QList<int> modbusList;
    int weldNum;
    float k;
    int i;
    float travel;
    qDebug()<<"totalNum"<<totalNum;
    qDebug()<<"weldIndex"<<weldIndex;
    qDebug()<<"currentFloor"<<currentFloor;
    qDebug()<<"currentNum"<<currentNum;
    //判断当前焊道所在的层、道
    if((totalNum!=0)&&(weldIndex<totalNum)){
        pP=&dispWeldDataTable.weldDataFloorTable[currentFloor-1].weldPointTable[currentNum-1];
        travel=float(moto.travel)/10;
        qDebug()<<"moto.travel "<<travel<<" lastMotoPoint "<<lastMotoPoint<<" startArcZ "<<pP->startArcZ<<" pP->stopArcZ "<<pP->stopArcZ;
        if((((travel-lastMotoPoint)>0)&&(pP->startArcZ-pP->stopArcZ)<0)||(((travel-lastMotoPoint)<0)&&(pP->startArcZ-pP->stopArcZ)>0)){
            //根据当前位置搜寻所在示教点位置
            for(i=0;i<(sysMath->teachPoint-1);i++){
                pG=&weldDataTable[i].grooveRules;
                pG1=&weldDataTable[i+1].grooveRules;
                //找出相应区间
                if(((travel>pG1->z)&&(travel<pG->z))||((travel<pG1->z)&&(travel>pG->z))){
                    //行走距离位于i和i+1的示教点中间位置开始线性拟合
                    pD=&weldDataTable[i].weldDataFloorTable[currentFloor-1].weldDataTable[currentNum-1];
                    pD1=&weldDataTable[i+1].weldDataFloorTable[currentFloor-1].weldDataTable[currentNum-1];
                    pP=&weldDataTable[i].weldDataFloorTable[currentFloor-1].weldPointTable[currentNum-1];
                    pP1=&weldDataTable[i+1].weldDataFloorTable[currentFloor-1].weldPointTable[currentNum-1];
                    weldNum=dispWeldDataTable.weldDataFloorTable[currentFloor-1].length;
                    qDebug()<<"pG->z"<<pG->z;
                    qDebug()<<"pG1->z"<<pG1->z;
                    k=(travel-pG->z)/(pG1->z-pG->z);
                    qDebug()<<"k"<<k;
                    qDebug()<<"pD1->weldTravelSpeed"<<pD1->weldTravelSpeed;
                    qDebug()<<"pD->weldTravelSpeed"<<pD->weldTravelSpeed;
                    //摆动速度拟合
                    weldData.weldTravelSpeed=k*(pD1->weldTravelSpeed-pD->weldTravelSpeed)+pD->weldTravelSpeed+weldAdd.weldTravelSpeed;
                    //摆动幅度拟合
                    if((sysMath->weldStyleName!="水平角焊")){
                        weldData.swingLength=k*(pD1->swingLength-pD->swingLength)+pD->swingLength+weldAdd.swingLength;
                        qDebug()<<"pD1->swingLength"<<pD1->swingLength;
                        qDebug()<<"pD->swingLength"<<pD->swingLength;
                        if(((sysMath->weldStyleName!="横焊")&&(weldData.swingLength>2.5))||((sysMath->weldStyleName=="横焊")&&(currentFloor==1)&&(weldNum==1))){
                            if((sysMath->weldStyleName=="立焊")&&(sysMath->wireType==0)){
                                weldData.swingSpeed=(weldData.swingLength>6?qMax(1570-31*weldData.swingLength,float(600)):WAVE_MAX_VERTICAL_SPEED)/10;
                                lastWeldData.swingSpeed=weldData.swingSpeed;
                            }else{
                                p.name=currentFloor==dispWeldDataTable.length?"fillFloor":"topFloor";
                                p.interSwingStayTime=pD->interSwingStayTime;
                                p.outSwingStayTime=pD->outSwingStayTime;
                                p.swingLength=weldData.swingLength;
                                p.weldTravelSpeed=weldData.weldTravelSpeed;
                                weldData.swingSpeed=sysMath->getSwingSpeed(WAVE_MAX_SPEED,&p)/10;
                                lastWeldData.swingSpeed=weldData.swingSpeed;
                            }
                        }else{
                            weldData.swingLength=0;
                            weldData.swingSpeed=lastWeldData.swingSpeed;
                        }
                    }else{
                        weldData.swingLength=0;
                        weldData.swingSpeed=lastWeldData.swingSpeed;
                    }
                    //焊接电流拟合
                    weldData.weldCurrent=k*(pD1->weldCurrent-pD->weldCurrent)+pD->weldCurrent+weldAdd.weldCurrent;
                    //焊接电压拟合
                    weldData.weldVoltage=k*(pD1->weldVoltage-pD->weldVoltage)+pD->weldVoltage+weldAdd.weldVoltage;
                    //焊接线X
                    weldData.x=k*(pP1->weldLineX-pP->weldLineX)+pP->weldLineX+weldAdd.weldLineX;
                    qDebug()<<"pP1->weldLineX"<<pP1->weldLineX;
                    qDebug()<<"pP->weldLineX"<<pP->weldLineX;
                    qDebug()<<"weldData.x"<<weldData.x;
                    //焊接线Y
                    weldData.y=k*(pP1->weldLineY-pP->weldLineY)+pP->weldLineY+weldAdd.weldLineY;

                    weldData.outSwingStayTime=weldAdd.outSwingStayTime+pD1->outSwingStayTime;

                    weldData.interSwingStayTime=weldAdd.interSwingStayTime+pD1->interSwingStayTime;
                    //如果有出现变化的处理下发控制
                    modbusList.clear();
                    modbusList.append(MODBUS_FC_WRITE_MULTIPLE_REGISTERS);
                    modbusList.append(REG_WELD_CURRENT);
                    modbusList.append(9);
                    modbusList.append(weldData.weldCurrent);
                    modbusList.append(qRound(weldData.weldVoltage*10));
                    modbusList.append(qRound(weldData.swingLength*5));
                    modbusList.append(qRound(weldData.swingSpeed*10));
                    modbusList.append(qRound(weldData.weldTravelSpeed));
                    modbusList.append(qRound(weldData.x*10));
                    modbusList.append(qRound(weldData.y*10));
                    modbusList.append(qRound(weldData.outSwingStayTime*10));
                    modbusList.append(qRound(weldData.interSwingStayTime*10));
                    qDebug()<<modbusList;
                    pERModbus->setmodbusFrame(modbusList);
                }
            }
        }
    }
    lastMotoPoint=travel;
}
bool WeldMath::sendWeldData(QObject *value){
    QList<int> modbusList;
    int i,temp=0,temp1;
    weldDataType weldData;
    weldPointType weldPoint;
    weldDataType *pd;
    weldPointType *pp;
    weldPointType *pz;
    int num=0;
    currentNum=0;
    currentFloor=0;
    if(value==NULL){
        return false;
    }else{
        {
            //初始化增加的数值
            weldAdd.weldCurrent=0;
            weldAdd.weldTravelSpeed=0;
            weldAdd.weldVoltage=0;
            weldAdd.interSwingStayTime=0;
            weldAdd.outSwingStayTime=0;
            weldAdd.stopTime=0;
            weldAdd.swingLength=0;
            weldAdd.swingSpeed=0;
            weldAdd.startArcX=0;
            weldAdd.startArcY=0;
            weldAdd.startArcZ=0;
            weldAdd.stopArcX=0;
            weldAdd.stopArcY=0;
            weldAdd.stopArcZ=0;
        }

        {  //转化传递参数
            weldData.weldCurrent=value->property("C2").toInt();
            weldData.weldVoltage=value->property("C3").toFloat();
            weldData.swingLength=(value->property("C4").toFloat()*2);
            weldData.swingSpeed=value->property("C5").toFloat();
            weldData.weldTravelSpeed=value->property("C6").toFloat()*10;
            weldPoint.weldLineX=value->property("C7").toFloat();
            weldPoint.weldLineY=value->property("C8").toFloat();
            weldData.interSwingStayTime=value->property("C9").toFloat();
            weldData.outSwingStayTime=value->property("C10").toFloat();
            weldData.stopTime=value->property("C11").toFloat();
            weldData.s=value->property("C12").toFloat();
            weldData.weldFill=value->property("C13").toFloat();
            weldPoint.startArcX=value->property("C14").toFloat();
            weldPoint.startArcY=value->property("C15").toFloat();
            weldPoint.startArcZ=value->property("C16").toFloat();
            weldPoint.stopArcX=value->property("C17").toFloat();
            weldPoint.stopArcY=value->property("C18").toFloat();
            weldPoint.stopArcZ=value->property("C19").toFloat();
        }
        if(weldIndex==200){
            //修补焊下发
            QString s=value->property("C1").toString();
            QStringList s1= s.split("/");

            if(s1.length()==2){
                currentFloor=s1.at(0).toInt();
                currentNum=s1.at(1).toInt();
            }else
                return -1;
            s=value->property("ID").toString();
            num=s.toInt()+1;
        }else{
            //正常焊接下发
            totalNum=dispWeldDataTable.totalNum-1;
            if(totalNum<0){
                qDebug()<<"er100_changeWeldRules";
                return false;
            } else if((totalNum>0)&&(weldIndex<totalNum)){
                for(i=0;i<dispWeldDataTable.length;i++){
                    temp1=dispWeldDataTable.weldDataFloorTable[i].length;
                    temp+=temp1;
                    if(temp>=(weldIndex+1)){
                        currentFloor=i+1;
                        currentNum=temp1-(temp-weldIndex)+1;
                        break;
                    }
                }
                if((currentFloor<=weldDataTable[0].length)&&(currentNum<=weldDataTable[0].weldDataFloorTable[currentFloor-1].length)){
                    pd=&dispWeldDataTable.weldDataFloorTable[currentFloor-1].weldDataTable[currentNum-1];
                    pp=&dispWeldDataTable.weldDataFloorTable[currentFloor-1].weldPointTable[currentNum-1];
                    if(fixWeld>0)
                    {
                        weldAdd.weldCurrent=weldData.weldCurrent-pd->weldCurrent;
                        weldAdd.weldTravelSpeed=weldData.weldTravelSpeed-pd->weldTravelSpeed;
                        weldAdd.weldVoltage=weldData.weldVoltage-pd->weldVoltage;
                        weldAdd.interSwingStayTime=weldData.interSwingStayTime-pd->interSwingStayTime;
                        weldAdd.outSwingStayTime=weldData.outSwingStayTime-pd->outSwingStayTime;
                        weldAdd.stopTime=weldData.stopTime-pd->stopTime;
                        weldAdd.swingLength=weldData.swingLength-pd->swingLength;
                        weldAdd.swingSpeed=weldData.swingSpeed-pd->swingSpeed;
                        weldAdd.startArcX=weldPoint.startArcX-pp->startArcX;
                        weldAdd.startArcY=weldPoint.startArcY-pp->startArcY;
                        weldAdd.startArcZ=weldPoint.startArcZ-pp->startArcZ;
                        weldAdd.stopArcX=weldPoint.stopArcX-pp->stopArcX;
                        weldAdd.stopArcY=weldPoint.stopArcY-pp->stopArcY;
                        weldAdd.stopArcZ=weldPoint.stopArcZ-pp->stopArcZ;
                        weldAdd.weldLineX=weldPoint.weldLineX-pp->weldLineX;
                        weldAdd.weldLineY=weldPoint.weldLineY-pp->weldLineY;}
                    pd =&weldDataTable[0].weldDataFloorTable[currentFloor-1].weldDataTable[currentNum-1];
                    pp=&weldDataTable[0].weldDataFloorTable[currentFloor-1].weldPointTable[currentNum-1];
                    {
                        pz=&dispWeldDataTable.weldDataFloorTable[currentFloor-1].weldPointTable[currentNum-1];

                        weldData.weldCurrent=weldAdd.weldCurrent+pd->weldCurrent;
                        weldData.weldVoltage=weldAdd.weldVoltage+pd->weldVoltage;
                        weldData.swingLength=weldAdd.swingLength+pd->swingLength;
                        weldData.swingSpeed=weldAdd.swingSpeed+pd->swingSpeed;
                        weldData.weldTravelSpeed=weldAdd.weldTravelSpeed+pd->weldTravelSpeed;
                        weldPoint.weldLineX=weldAdd.weldLineX+pp->weldLineX;
                        weldPoint.weldLineY=weldAdd.weldLineY+pp->weldLineY;
                        weldData.interSwingStayTime=weldAdd.interSwingStayTime+pd->interSwingStayTime;
                        weldData.outSwingStayTime=weldAdd.outSwingStayTime+pd->outSwingStayTime;
                        weldData.stopTime=weldAdd.stopTime+pd->stopTime;

                        weldPoint.startArcX=weldAdd.startArcX+pz->startArcX;
                        weldPoint.startArcY=weldAdd.startArcY+pp->startArcY;
                        weldPoint.startArcZ=weldAdd.startArcZ+pz->startArcZ;

                        weldPoint.stopArcX=weldAdd.stopArcX+pz->stopArcX;
                        weldPoint.stopArcY=weldAdd.stopArcY+pp->stopArcY;
                        weldPoint.stopArcZ=weldAdd.stopArcZ+pz->stopArcZ;

                    }
                    num=totalNum;
                }
            }
        }
        pp=&weldPoint;
        pd=&weldData;
        {
            modbusList.clear();
            modbusList.append(MODBUS_FC_WRITE_MULTIPLE_REGISTERS);
            modbusList.append(REG_WELD_FLOOR);
            modbusList.append(20);
            //
            modbusList.append(currentFloor*100+currentNum);
            modbusList.append(pd->weldCurrent);
            modbusList.append(qRound(pd->weldVoltage*10));
            modbusList.append(qRound(pd->swingLength*5));
            modbusList.append(qRound(pd->swingSpeed*10));
            modbusList.append(qRound(pd->weldTravelSpeed));
            modbusList.append(qRound(pp->weldLineX*10));
            modbusList.append(qRound(pp->weldLineY*10));
            modbusList.append(qRound(pd->outSwingStayTime*10));
            modbusList.append(qRound(pd->interSwingStayTime*10));

            modbusList.append(qRound(pd->stopTime));
            modbusList.append(qRound(pd->s*10));
            modbusList.append(qRound(pd->weldFill*10));
            modbusList.append(qRound(pp->startArcX*10));
            modbusList.append(qRound(pp->startArcY*10));
            modbusList.append(qRound(pp->startArcZ));
            modbusList.append(num);
            modbusList.append(qRound(pp->stopArcX*10));
            modbusList.append(qRound(pp->stopArcY*10));
            modbusList.append(qRound(pp->stopArcZ));

            pERModbus->setmodbusFrame(modbusList);}
        return true;
    }
}
void WeldMath::getGrooveTable(void){
    QList<int> modbusList;
    makeModbusFrame(MODBUS_FC_READ_HOLDING_REGISTERS,REG_GROOVE_DATA,10,0,&modbusList);
    pERModbus->setmodbusFrame(modbusList);
}
void WeldMath::timeSolt(){
    QList<int> modbusList;
    if(sysStatus!="未登录态"){ //登陆以后才支持
        if((readSet)&&(sysStatus=="坡口检测态")){
            makeModbusFrame(MODBUS_FC_READ_HOLDING_REGISTERS,REG_GROOVE_DATA,10,0,&modbusList);
            pERModbus->setmodbusFrame(modbusList);
        }else if((readSet)&&((sysStatus=="焊接端部暂停态")||(sysStatus=="焊接中间暂停态"))){
            makeModbusFrame(MODBUS_FC_READ_HOLDING_REGISTERS,REG_SEND_WELD_RULES,1,0,&modbusList);
            pERModbus->setmodbusFrame(modbusList);
        }else if((readSet)&&(sysStatus=="空闲态")){
            makeModbusFrame(MODBUS_FC_READ_HOLDING_REGISTERS,REG_ROCK_WAY,6,0,&modbusList);
            pERModbus->setmodbusFrame(modbusList);
        }else{
            makeModbusFrame(MODBUS_FC_READ_HOLDING_REGISTERS,REG_SYSTEM_STATUS,7,0,&modbusList);
            pERModbus->setmodbusFrame(modbusList);
        }
        readSet=!readSet;
    }
    //无论登录与否都查询钥匙开关状态
    makeModbusFrame(MODBUS_FC_READ_HOLDING_REGISTERS,REG_SYSTEM_UP,1,0,&modbusList);
    pERModbus->setmodbusFrame(modbusList);
    //获取控制板数据
   // makeModbusFrame(MODBUS_FC_READ_HOLDING_REGISTERS,REG_CONTROL_STATUS,20,0,&modbusList);
  // pERModbus->setmodbusFrame(modbusList);
}
void WeldMath::doError(int e1, int e2, int e3, int e4){
    //将错误代码转为64位数据
    uint64_t tempError;
    tempError=uint16_t(e4);
    tempError<<=16;
    tempError|=uint16_t(e3);
    tempError<<=16;
    tempError|=uint16_t(e2);
    tempError<<=16;
    tempError|=uint16_t(e1);
    //
    uint64_t errorXor=tempError^errorCode;
    errorCode=tempError;
    int rw;
    for(int i=0;i<64;i++){
        if(errorXor&1){
            if(tempError&1){
                rw=1;
            }else{
                rw=0;
            }
            emit er100_SysError(i+1,rw);
        }
        tempError>>=1;
        errorXor>>=1;
    }
}
void WeldMath::doControlSatus(int s1,int s2){
  QList<int> p;
  p.clear();
  uint16_t temp;
  temp=s1&0x00ff;
  p.append((int)temp);
  temp=s1>>8;
  p.append((int)temp);
  temp=s2&0x00ff;
  p.append((int)temp);
  temp=s2>>8;
  p.append((int)temp);
   emit er100_GetControlStatus(p);
}

void WeldMath::modbusSlot(QList<int> value){
    QJsonObject json;
    int32_t travel;
    int error=value.at(0);
    int reg;
    int id;
    bool updateFlag;
    //uint32_t temp;
    QString s;
    //无错误
    if((error==0)||((error!=EMBXILFUN)&&(error!=EMBXILADD)&&(error!=EMBXILVAL)&&(error!=EMBXSFAIL)\
                    &&(error!=EMBXACK)&&(error!=EMBXSBUSY)&&(error!=EMBXNACK)&&(error!=EMBXMEMPAR)\
                    &&(error!=EMBXGPATH)&&(error!=EMBXGTAR)&&(error!=EMBBADCRC)&&(error!=EMBBADDATA)\
                    &&(error!=EMBBADEXC)&&(error!=EMBMDATA)&&(error!=EMBBADSLAVE))){
        if(value.length()>1){
            reg=value.at(1);
            switch(reg){
            //系统状态寄存器
            case REG_SYSTEM_STATUS:
                if(sysStatus!="未登录态"){
                    if(value.length()==9){
                        //发送系统状态信号
                        if(sysStatus!=sysStatusList[value.at(2)])
                            emit er100_SysStatus(sysStatusList[value.at(2)]);
                        //处理错误信息64位
                         doError(value.at(3),value.at(4),value.at(5),value.at(6));
                         //处理下位机状态数据
                         doControlSatus(value.at(7),value.at(8));
                    }
                }
                break;
            case REG_SYSTEM_UP:
                if(changeUserFlag!=value.at(2)){
                    emit er100_Key(value.at(2));
                    changeUserFlag=value.at(2);
                }
                break;
            case REG_ROCK_WAY:
                if(value.length()==8){
                value.removeAt(0);
                value.removeAt(0);
                //此处添加判断
                updateFlag=false;
                if(teachSet.rockWay!=value.at(0)){
                       teachSet.rockWay=value.at(0);
                       updateFlag=true;
                }
                if(teachSet.teachMode!=value.at(1)){
                       teachSet.teachMode=value.at(1);
                       updateFlag=true;
                }
                if(teachSet.startEnd!=value.at(2)){
                       teachSet.startEnd=value.at(2);
                       updateFlag=true;
                }
                if(teachSet.teachFirstPoint!=value.at(3)){
                       teachSet.teachFirstPoint=value.at(3);
                       updateFlag=true;
                }
                if(teachSet.teachPoint!=value.at(4)){
                       teachSet.teachPoint=value.at(4);
                       updateFlag=true;
                }
                if(teachSet.length!=value.at(5)){
                      teachSet.length=value.at(5);
                      emit er100_UpdateWeldLength(teachSet.length);
                }
                if(updateFlag)
                    emit er100_TeachSet(value);
                }
                break;
            case REG_WELD_LENGTH:
            /*    if(teachSet.length!=value.at(2)){
                    teachSet.length=value.at(2);
                    emit er100_UpdateWeldLength(teachSet.length);
                }*/
                break;
            case REG_GROOVE_DATA:
                if(value.length()==12){
                id=value.at(2);
                if(id){
                    //判断当前id与坡口索引是否一致 仅限ID递增的情况下更新坡口数据表
                    if(id!=grooveIndex){
                        qDebug()<<value;
                        travel=value.at(9);
                        travel<<=16;
                        travel|=uint16_t(value.at(8));
                        json.insert("ID",QJsonValue(QString::number(id)));
                        json.insert("C1",QJsonValue(QString::number(float(value.at(3))/10)));
                        json.insert("C2",QJsonValue(QString::number(float(value.at(4))/10)));
                        json.insert("C3",QJsonValue(QString::number(float(value.at(5))/10)));
                        json.insert("C4",QJsonValue(QString::number(float(value.at(6))/10)));
                        json.insert("C5",QJsonValue(QString::number(float(value.at(7))/10)));
                        json.insert("C6",QJsonValue(QString::number(float(value.at(11))/10)));
                        json.insert("C7",QJsonValue(QString::number(float(value.at(10))/10)));
                        json.insert("C8",QJsonValue(QString::number(float(travel)/10)));
                        grooveIndex=id;
                        weldIndex=255;
                        emit er100_updateGrooveTable(json);
                    }
                }else{
                    grooveIndex=0;
                }
                }
                break;
            case REG_SEND_WELD_RULES:
                //qDebug()<<value;
                if((sysStatus=="焊接端部暂停态")||(sysStatus=="焊接中间暂停态")){
                    if((weldIndex!=value.at(2))&&(!weldFix)){
                        //更新焊道参数
                        if(value.at(2)!=200){
                            //emit er100_changeWeldTableIndex(value.at(2));
                            weldFix=false;
                            //下发焊接规范 此处存在着争议
                            // sendWeldRules();
                        }else{
                            weldFix=true;
                            //下发修补焊数据
                        }
                        //存储
                        weldIndex=value.at(2);
                        //发送信号 无论是修补还是焊接都发送信号 数值不为200时 数据回传 数值内表格，数据为200时回传选中的数据表格数据
                        emit er100_changeWeldTableIndex(value.at(2));
                    }else if((weldFix)&&(value.at(2)!=200)){
                        weldFix=false;
                    }
                }
                break;
            case REG_READ_DATETIME:
                //emit er100_readDateTime();
                if(value.length()==8)
                setSysDateTime(value);
                pTimer->start();
                break;
            case REG_ROCK_MOTO_CURRENT_POINT:
                if(value.length()==8){
                travel=value.at(3);
                travel<<=16;
                travel|=uint16_t(value.at(2));
                updateFlag=false;
                if(moto.travel!=travel){
                      moto.travel=travel;
                      updateFlag=true;
                }
                if(moto.swing!=value.at(4)){
                     moto.swing=value.at(4);
                      updateFlag=true;
                }
                if(moto.avc!=value.at(5)){
                    moto.avc=value.at(5);
                    updateFlag=true;
                }
                if(moto.rock!=value.at(6)){
                    moto.rock=value.at(6);
                    updateFlag=true;
                }
                if(updateFlag){
                    value.removeAt(0);
                    value.removeAt(0);
                     emit er100_MotoPoint(value);
                }
                 //修补焊不补偿  fixweld 补偿kaiguan budakai
                if((sysStatus=="焊接态")&&(weldIndex!=200)&&fixWeld)
                    getWeldDataRules();
                }
                break;
            case REG_VERSION:
                if(value.length()==5){
                    emit er100_Version(value.at(2),value.at(3),value.at(4));
                }
               break;
         //   case REG_CONTROL_STATUS:
                  //  emit er100_GetControlStatus(value);
               // qDebug()<<value;
            //    break;
            }
        }
    }else{
        emit er100_SysError(26,1);
    }
}

#endif
