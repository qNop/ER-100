#include "WeldMath.h"
#define ENABLE_SOLVE_FIRST                              1
#include <QtMath>

//weldMath
WeldMath::WeldMath()
{
    int i;
    sysMath=new SysMath();
    //connect(sysMath,&SysMath::weldRulesChanged,this,&WeldMath::weldRulesChanged);
    sysMath->rootFace=0;
    sysMath->pWeldTable=&weldTable;
    sysMath->pPointRulesLists=&pointRulesList;
    sysMath->pBufWeldRules=&bufWeldRules;

    for( i=0;i<30;i++){
        pointRulesList.append(&pointRulesData[i]);
    }
    bufWeldRules.floorRulesTableLength=0;
    weldTable.floorNum=0;
    for(i=0;i<50;i++){
        bufWeldRules.floorRulesTable[i].weldDataTableLength=0;
        weldTable.floorRules[i].weldNum=0;
        for(int j=0;j<25;j++)
            bufWeldRules.floorRulesTable[i].weldDataTable[j].weldRulesLength=0;
    }
    count=0;
}

WeldMath::~WeldMath(){
    delete sysMath;
}
////获取 高度 底面宽度 mm 角度0.1度且均为正值 电流A 行走速度cm/min ba 是底部矩形高度
//float WeldMath::getWeldHeight(float deep,float bottomWidth, float leftAngel, float rightAngel, int current, float weldSpeed, float met)
//{
//    float s=getWeldArea(current,weldSpeed,met);
//    float grooveAngel1Tan=qTan(leftAngel*PI/180);
//    float grooveAngel2Tan=qTan(rightAngel*PI/180);
//    float aa=(grooveAngel1Tan+grooveAngel2Tan)/2;
//    float bb=bottomWidth;
//    float cc=GET_CERAMICBACK_AREA(bottomWidth,deep)-s;
//    float h= (qSqrt(bb*bb-4*aa*cc)-bb)/(2*aa);
//    return h;
//}

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
    QVariant var=value->property("ID");
    QString str;
    QStringList strList;
    FloorCondition *p;
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
        }else if(str=="立板余高层"){
            p=&overFloor;
            p->name="overFloor";
            sysMath->overFloor=&overFloor;
        }else
            return false;
        //解析电流
        var=value->property("C1");
        if(var.type()==QVariant::String){
            str=var.toString();
            strList=str.split("/");
            if(strList.length()==3){
                p->current_left=strList[0].toInt();
                p->current_middle=strList[1].toInt();
                p->current_right=strList[2].toInt();
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
                p->swingLeftStayTime=strList[0].toFloat();
                p->swingRightStayTime=strList[1].toFloat();
                p->totalStayTime=p->swingLeftStayTime+p->swingRightStayTime;
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

void WeldMath::getMathGrooveRule(int index, QObject *obj,grooveRulesType *p){
    p->index=index;
    p->grooveHeight=obj->property("C1").toFloat();
    p->grooveHeightError=obj->property("C2").toFloat();
    if(sysMath->weldStyleName!="水平角焊"){
        if(sysMath->weldConnectName=="T接头"){
            float a,b,c,c2,angel1,angel2,angela,angelc;
            if(sysMath->grooveDirValue){
                angel1=obj->property("C5").toFloat();
                angel2=obj->property("C4").toFloat();
            }else{
                angel1=obj->property("C4").toFloat();//坡口侧角度
                angel2=obj->property("C5").toFloat();//非坡口侧角度
            }
            angelc=angel1+angel2;
            a=p->grooveHeight/qCos(angel1*PI/180);//坡口长度
            b=p->grooveHeight/qCos(angel2*PI/180)+p->grooveHeightError;
            c2=a*a+b*b-2*a*b*qCos(angelc*PI/180);//夹角对应的边长平方;
            c=qSqrt(c2);//夹角对应边长
            angela=qAcos((b*b+c2-a*a)/(2*b*c))*180/PI;
            p->angel=90-angel2-angela;
            p->grooveHeight=b*qCos((angel2+p->angel)*PI/180);
            p->rootGap*=qCos(p->angel*PI/180);// 有根部间隙的旋转坐标系还存在漏洞 填充量计算的时候 可能过大
            if(sysMath->grooveDirValue){
                p->grooveAngel2=angel1-p->angel;
                p->grooveAngel1=angel2+p->angel;
            }else{
                p->grooveAngel1=angel1-p->angel;
                p->grooveAngel2=angel2+p->angel;
            }
        }else{ //输入的板厚已经和板厚差做出变化
            p->rootGap=obj->property("C3").toFloat();
            p->grooveAngel1=obj->property("C4").toFloat();
            p->grooveAngel2=obj->property("C5").toFloat();
        }
    }else{//水平角焊
        p->angel=qAtan(p->grooveHeight/p->grooveHeightError)*180/PI;
        p->grooveHeight*=qCos(p->angel*PI/180);
        p->rootGap=0;
        if(sysMath->grooveDirValue){//非坡口侧
            p->grooveAngel1=obj->property("C4").toFloat()+p->angel;
            p-> grooveAngel2=obj->property("C5").toFloat()-p->angel;
        }else{
            p->grooveAngel1=obj->property("C4").toFloat()-p->angel;
            p->grooveAngel2=obj->property("C5").toFloat()+p->angel;
        }
    }
    p->x=obj->property("C6").toFloat();
    p->y=obj->property("C7").toFloat();
    p->z=obj->property("C8").toFloat();
    p->grooveAngel1Tan=qTan(p->grooveAngel1*PI/180);
    p->grooveAngel2Tan=qTan(p->grooveAngel2*PI/180);
}

int WeldMath::getGrooveIndex(int index,int max){
    int i=0;
    for(i=0;i<max;i++){
        if(index==pointRulesList.at(i)->groove.index)
            return i;
    }
    return -1;
}

void WeldMath::makeJson(QJsonObject *pJson, weldDataType *pWeldData,weldCoordinateType *pWeldCoordinate){
    //全部参数计算完成
    pJson->insert("ID",QJsonValue(QString::number(pWeldData->index)));
    pJson->insert("C1",QJsonValue(QString::number(pWeldData->floor)+"/"+QString::number(pWeldData->num)));
    pJson->insert("C2",QJsonValue(QString::number(pWeldData->weldCurrent)));
    pJson->insert("C3",QJsonValue(QString::number(pWeldData->weldVoltage,'f',1)));
    pJson->insert("C4",QJsonValue(QString::number(pWeldData->swingLength,'f',1)));
    pJson->insert("C5",QJsonValue(QString::number(pWeldData->swingSpeed/10,'f',1)));
    pJson->insert("C6",QJsonValue(QString::number(pWeldData->weldTravelSpeed/10,'f',1)));
    pJson->insert("C7",QJsonValue(QString::number(pWeldData->weldLineX,'f',1)));
    pJson->insert("C8",QJsonValue(QString::number(pWeldData->weldLineY,'f',1)));
    pJson->insert("C9",QJsonValue(QString::number(pWeldData->beforeSwingStayTime,'f',1)));
    pJson->insert("C10",QJsonValue(QString::number(pWeldData->afterSwingStayTime,'f',1)));
    pJson->insert("C11",QJsonValue(QString::number(pWeldData->stopTime,'f',1)));
    pJson->insert("C12",QJsonValue(QString::number(pWeldData->s,'f',1)));
    pJson->insert("C13",QJsonValue(QString::number(pWeldData->weldFill,'f',1)));
    pJson->insert("C14",QJsonValue(QString::number(pWeldCoordinate->startArcX,'f',1)));
    pJson->insert("C15",QJsonValue(QString::number(pWeldCoordinate->startArcY,'f',1)));
    pJson->insert("C16",QJsonValue(QString::number(pWeldCoordinate->startArcZ,'f',1)));
    pJson->insert("C17",QJsonValue(QString::number(pWeldCoordinate->stopArcX,'f',1)));
    pJson->insert("C18",QJsonValue(QString::number(pWeldCoordinate->stopArcY,'f',1)));
    pJson->insert("C19",QJsonValue(QString::number(pWeldCoordinate->stopArcZ,'f',1)));
}

bool WeldMath::setGrooveRules(int index, QObject *obj,bool ok){
    int i,j,z;
    //把obj的所有属性全部传输到 temp
    if(index>29) return false;
    if(obj==NULL) return false;
    getMathGrooveRule(index,obj,&pointRulesList.at(index)->groove);
    if(ok){
        //如果各点板厚差超过3mm 则要报错
        //对各点进行Z轴位置排序找最大
        int low = 0;
        int high=index; //设置变量的初始值
        grooveRulesPoint=index+1;
        pointRules* tmp;
        while (low < high) {
            for (i= low; i< high; ++i) //正向冒泡,找到最大者
                if (pointRulesList[i]->groove.z> pointRulesList[i+1]->groove.z) {
                    tmp = pointRulesList[i];
                    pointRulesList[i]=pointRulesList[i+1];
                    pointRulesList[i+1]=tmp;
                }
            --high; //修改high值,前移一位
            for ( i=high; i>low; --i) //反向冒泡,找到最小者
                if (pointRulesList[i]->groove.z<pointRulesList[i-1]->groove.z) {
                    tmp = pointRulesList[i]; pointRulesList[i]=pointRulesList[i-1];pointRulesList[i-1]=tmp;
                }
            ++low; //修改low值,后移一位
        }
        for(i=0;i<grooveRulesPoint;i++)
            pointRulesList.at(i)->groove.rootGap+=i*(count/8)/grooveRulesPoint;
        count++;
        qDebug()<<"pointRulesList.at(grooveRulesPoint-1)->groove.rootGap"<<pointRulesList.at(grooveRulesPoint-1)->groove.rootGap<<"\ncount"<<count;
        //清零排序数组的长度标记
        for(i=0;i<bufWeldRules.floorRulesTableLength;i++){
            for(j=0;j<bufWeldRules.floorRulesTable[i].weldDataTableLength;j++){
                for(z=0;z<grooveRulesPoint;z++)
                    bufWeldRules.floorRulesTable[i].weldDataTable[j].weldRulesData[z].pWeldRules->index=0;
                bufWeldRules.floorRulesTable[i].weldDataTable[j].weldRulesLength=0;
            }
            bufWeldRules.floorRulesTable[i].weldDataTableLength=0;
        }
        bufWeldRules.floorRulesTableLength=0;
        //数组有效开始计算 每个点的焊接规范
        if( sysMath->weldMath(grooveRulesPoint)==-1)
            return false;
        //输出数据表格
        QJsonObject pJson;
        pJsonList.clear();
        for(i=0;i<weldTable.floorNum;i++){
            for(j=0;j<weldTable.floorRules[i].weldNum;j++){
                makeJson(&pJson,weldTable.floorRules[i].weldRulesData[j].pWeldRules,&weldTable.floorRules[i].weldCoordinates[j]);
                pJsonList.append(QVariant(pJson));
            }
        }
        emit weldRulesChanged(sysMath->status,pJsonList);
    }
    return true;
}





