#include "weldmath.h"
#define ENABLE_SOLVE_FIRST                              1
#include <QtMath>

//weldMath
WeldMath::WeldMath()
{
    sysMath=new SysMath();
    connect(sysMath,&SysMath::weldRulesChanged,this,&WeldMath::weldRulesChanged);
    sysMath->rootFace=0;
}

void WeldMath::setReinforcement(float value){
    sysMath->reinforcementValue=value;
}

void WeldMath::setMeltingCoefficient(int value){
    sysMath->meltingCoefficientValue=value;
}

void WeldMath::setRootFace(float value){
    sysMath->rootFace=value;
}

void WeldMath::setStopInTime(int value){
    sysMath->stopInTime=value;
}

void WeldMath::setStopOutTime(int value){
    sysMath->stopOutTime=value;
}

void WeldMath::setGrooveRules(QStringList value){
    //数组有效
    if(sysMath->setGrooveRules(value)==-1){
        QJsonObject pJson;
        emit weldRulesChanged(sysMath->status,pJson);
    }
}

void WeldMath::setCeramicBack(int value){
    sysMath->ceramicBack=value;
    sysMath->bottomFloor=sysMath->ceramicBack==1?&bottomFloor0:&bottomFloor;
}

void WeldMath::setGas(int value){
    sysMath->gasValue=value;
}
void WeldMath::setPulse(int value){
    sysMath->pulseValue=value;
}

void WeldMath::setWireType(int value){
    sysMath->wireTypeValue=value;
}

void WeldMath::setWireD(int value){
    sysMath->wireDValue=value;
}

void WeldMath::setGrooveDir(bool value){
    sysMath->grooveDirValue=value;
}
/*
     "平焊单边V形坡口T接头",  "平焊单边V形坡口平对接",  "平焊V形坡口平对接",
    "横焊单边V形坡口T接头",  "横焊单边V形坡口平对接",
    "立焊单边V形坡口T接头",  "立焊单边V形坡口平对接", "立焊V形坡口平对接",
    "水平角焊" ]
    */
void WeldMath::setGroove(int value){
    grooveValue=value;
}

void WeldMath::setGrooveStyle(int value){
    sysMath->grooveStyleName=value?"V形坡口":"单边V形坡口";
}
void WeldMath::setWeldStyle(int value){
    sysMath->weldStyleName=value==0?"平焊":value==1?"横焊":value==2?"立焊":"水平角焊";
}
void WeldMath::setConnectStyle(int value){
    sysMath->weldConnectName=value?"平对接":"T接头";
}

void WeldMath::setReturnWay(int value){
    sysMath->returnWay=value;
}

void WeldMath::setStartArcZz(int value){
    sysMath->startArcZz=value;
}

void WeldMath::setStartArcZx(int value){
    sysMath->startArcZx=value;
}

void WeldMath::setStopArcZz(int value){
    sysMath->stopArcZz=value;
}

void WeldMath::setStopArcZx(int value){
    sysMath->stopArcZx=value;
}


int WeldMath::getFeedSpeed(int current){
    return  sysMath->getFeedSpeed(current);
}

float WeldMath::getWeldVoltage(int current){
    return sysMath->getVoltage(current);
}

float WeldMath::getWeldArea(int current, float weldSpeed,float met){
    return  GET_WELDFILL_AREA(met,(sysMath->wireDValue==4?1.2*1.2:1.6*1.6)*PI/4,sysMath->getFeedSpeed(current),weldSpeed);
}
/*
float WeldMath::getWeldA(float swing,float swingLeftStayTime,float swingRightStayTime,float weldSpeed,float maxSpeed){
    float swingHz=0;
    return swingHz; //sysMath->getSwingSpeed(swing,swingLeftStayTime,swingRightStayTime,weldSpeed*10,maxSpeed,&swingHz);
}*/
//获取 高度 底面宽度 mm 角度0.1度且均为正值 电流A 行走速度cm/min ba 是底部矩形高度
float WeldMath::getWeldHeight(float deep,float bottomWidth, float leftAngel, float rightAngel, int current, float weldSpeed, float met)
{
    float s=getWeldArea(current,weldSpeed,met);
    float grooveAngel1Tan=qTan(leftAngel*PI/180);
    float grooveAngel2Tan=qTan(rightAngel*PI/180);
    float aa=(grooveAngel1Tan+grooveAngel2Tan)/2;
    float bb=bottomWidth;
    float cc=GET_CERAMICBACK_AREA(bottomWidth,deep)-s;
    float h= (qSqrt(bb*bb-4*aa*cc)-bb)/(2*aa);
    return h;
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
                p->swingLeftStayTime=strList[0].toFloat();
                p->swingRightStayTime=strList[1].toFloat();
                p->totalStayTime=p->swingLeftStayTime+p->swingRightStayTime;
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
