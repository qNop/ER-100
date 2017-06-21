#include "weldmath.h"
#define ENABLE_SOLVE_FIRST                              1
#include <QtMath>

//weldMath
WeldMath::WeldMath()
{
    connect(&sysMath,SIGNAL(weldRulesChanged(QStringList )),this,SLOT(setWeldRules(QStringList )));
    sysMath.rootFace=0;
}

void WeldMath::setReinforcement(float value){
    sysMath.reinforcementValue=value;
}

void WeldMath::setMeltingCoefficient(int value){
    sysMath.meltingCoefficientValue=value;
}

void WeldMath::setRootFace(float value){
    sysMath.rootFace=value;
}

void WeldMath::setStopInTime(int value){
    sysMath.stopInTime=value;
}

void WeldMath::setStopOutTime(int value){
    sysMath.stopOutTime=value;
}

void WeldMath::setWeldRules(QStringList value){
    emit weldRulesChanged(value);
}

void WeldMath::setGrooveRules(QStringList value){
    //数组有效
    if(sysMath.setGrooveRules(value)==-1){
        value.clear();
        value<<sysMath.status;
        emit weldRulesChanged(value);
    }
}

void WeldMath::setCeramicBack(int value){
    sysMath.ceramicBack=value;
    sysMath.bottomFloor=sysMath.ceramicBack==1?&bottomFloor0:&bottomFloor;
}

void WeldMath::setGas(int value){
    sysMath.gasValue=value;
}
void WeldMath::setPulse(int value){
    sysMath.pulseValue=value;
}

void WeldMath::setWireType(int value){
    sysMath.wireTypeValue=value;
}

void WeldMath::setWireD(int value){
    sysMath.wireDValue=value;
}

void WeldMath::setGrooveDir(bool value){
    sysMath.grooveDirValue=value;
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
        sysMath.grooveStyleName=value?"V形坡口":"单边V形坡口";
}
void WeldMath::setWeldStyle(int value){
        sysMath.weldStyleName=value==0?"平焊":value==1?"横焊":value==2?"立焊":"水平角焊";
}
void WeldMath::setConnectStyle(int value){
        sysMath.weldConnectName=value?"平对接":"T接头";
}

void WeldMath::setReturnWay(int value){
    sysMath.returnWay=value;
}

void WeldMath::setStartArcZz(int value){
    sysMath.startArcZz=value;
}

void WeldMath::setStartArcZx(int value){
    sysMath.startArcZx=value;
}

void WeldMath::setStopArcZz(int value){
    sysMath.stopArcZz=value;
}

void WeldMath::setStopArcZx(int value){
    sysMath.stopArcZx=value;
}


int WeldMath::getFeedSpeed(int current){
    return  sysMath.getFeedSpeed(current);
}

float WeldMath::getWeldVoltage(int current){
    return sysMath.getVoltage(current);
}

float WeldMath::getWeldArea(int current, float weldSpeed,float k,float met){
    return  GET_WELDFILL_AREA(met,(sysMath.wireDValue==4?1.2*1.2:1.6*1.6)*PI/4,sysMath.getFeedSpeed(current),weldSpeed);
}

float WeldMath::getWeldA(float swing,float swingLeftStayTime,float swingRightStayTime,float weldSpeed,float maxSpeed){
    float swingHz=0;
    return  sysMath.getSwingSpeed(swing,swingLeftStayTime,swingRightStayTime,weldSpeed*10,maxSpeed,&swingHz);
}
//获取 高度 底面宽度 mm 角度0.1度且均为正值 电流A 行走速度cm/min ba 是底部矩形高度
float WeldMath::getWeldHeight(float deep,float bottomWidth, float leftAngel, float rightAngel, int current, float weldSpeed, float k, float met)
{
    float s=getWeldArea(current,weldSpeed,k,met);
    float grooveAngel1Tan=qTan(leftAngel*PI/180);
    float grooveAngel2Tan=qTan(rightAngel*PI/180);
    float aa=(grooveAngel1Tan+grooveAngel2Tan)/2;
    float bb=bottomWidth;
    float cc=GET_CERAMICBACK_AREA(bottomWidth,deep)-s;
    float h= (qSqrt(bb*bb-4*aa*cc)-bb)/(2*aa);
    return h;
}

bool WeldMath::setLimited(QStringList value){
    qDebug()<<"WeldMath::setLimited value "<<value<<value.length();
    if(value.length()>=80){
        bottomFloor0.name="ceramicBackFloor";
        bottomFloor0.current_left=value.at(BOTTOM_0+CURRENT-1).toFloat();
        bottomFloor0.current_middle=value.at(BOTTOM_0+CURRENT).toFloat();
        bottomFloor0.current_right=value.at(BOTTOM_0+CURRENT+1).toFloat();
        bottomFloor0.maxHeight=value.at(BOTTOM_0+MAX_HEIGHT).toFloat();
        bottomFloor0.minHeight=value.at(BOTTOM_0+MIN_HEIGHT).toFloat();
        bottomFloor0.k=value.at(BOTTOM_0+K).toFloat();
        bottomFloor0.maxSwingLength=value.at(BOTTOM_0+MAX_SWING_LENGTH).toFloat();
        bottomFloor0.swingLeftLength=value.at(BOTTOM_0+SWING_LEFT_LENGTH).toFloat();
        bottomFloor0.swingRightLength=value.at(BOTTOM_0+SWING_RIGHT_LENGTH).toFloat();
        bottomFloor0.swingLeftStayTime=value.at(BOTTOM_0+SWING_LEFT_STAYTIME).toFloat();
        bottomFloor0.swingRightStayTime=value.at(BOTTOM_0+SWING_RIGHT_STAYTIME).toFloat();
        bottomFloor0.totalStayTime=bottomFloor0.swingLeftStayTime+bottomFloor0.swingRightStayTime;
        bottomFloor0.totalStayTime=float(qRound(10*bottomFloor0.totalStayTime))/10;
        bottomFloor0.weldSwingSpacing=value.at(BOTTOM_0+SWING_SPACING).toFloat();
        bottomFloor0.maxWeldSpeed=value.at(BOTTOM_0+MAX_SPEED).toFloat();
        bottomFloor0.minWeldSpeed=value.at(BOTTOM_0+MIN_SPEED).toFloat();
      //  bottomFloor0.fillCoefficient=value.at(BOTTOM_0+FILL_COE).toFloat();
        bottomFloor0.voltage=value.at(BOTTOM_0+VOLTAGE).toFloat();
        bottomFloor0.current=bottomFloor0.current_left;
        //底层限制条件 选取电流中间侧
        bottomFloor.name="bottomFloor";
        bottomFloor.current_left=value.at(BOTTOM_1+CURRENT-1).toFloat();
        bottomFloor.current_middle=value.at(BOTTOM_1+CURRENT).toFloat();
        bottomFloor.current_right=value.at(BOTTOM_1+CURRENT+1).toFloat();
        bottomFloor.maxHeight=value.at(BOTTOM_1+MAX_HEIGHT).toFloat();
        bottomFloor.minHeight=value.at(BOTTOM_1+MIN_HEIGHT).toFloat();
        bottomFloor.k=value.at(BOTTOM_1+K).toFloat();
        bottomFloor.maxSwingLength=value.at(BOTTOM_1+MAX_SWING_LENGTH).toFloat();
        bottomFloor.swingLeftLength=value.at(BOTTOM_1+SWING_LEFT_LENGTH).toFloat();
        bottomFloor.swingRightLength=value.at(BOTTOM_1+SWING_RIGHT_LENGTH).toFloat();
        bottomFloor.swingLeftStayTime=value.at(BOTTOM_1+SWING_LEFT_STAYTIME).toFloat();
        bottomFloor.swingRightStayTime=value.at(BOTTOM_1+SWING_RIGHT_STAYTIME).toFloat();
        bottomFloor.totalStayTime=bottomFloor.swingLeftStayTime+bottomFloor.swingRightStayTime;
        bottomFloor.totalStayTime=float(qRound(10*bottomFloor.totalStayTime))/10;
        bottomFloor.weldSwingSpacing=value.at(BOTTOM_1+SWING_SPACING).toFloat();
        bottomFloor.maxWeldSpeed=value.at(BOTTOM_1+MAX_SPEED).toFloat();
        bottomFloor.minWeldSpeed=value.at(BOTTOM_1+MIN_SPEED).toFloat();
       // bottomFloor.fillCoefficient=value.at(BOTTOM_1+FILL_COE).toFloat();
        bottomFloor.current=bottomFloor.current_left;
        bottomFloor.voltage=value.at(BOTTOM_1+VOLTAGE).toFloat();
        //第二层限制条件
        secondFloor.name="secondFloor";
        secondFloor.current_left=value.at(SECOND+CURRENT-1).toFloat();
        secondFloor.current_middle=value.at(SECOND+CURRENT).toFloat();
        secondFloor.current_right=value.at(SECOND+CURRENT+1).toFloat();
        secondFloor.maxHeight=value.at(SECOND+MAX_HEIGHT).toFloat();
        secondFloor.minHeight=value.at(SECOND+MIN_HEIGHT).toFloat();
        secondFloor.k=value.at(SECOND+K).toFloat();
        secondFloor.maxSwingLength=value.at(SECOND+MAX_SWING_LENGTH).toFloat();
        secondFloor.swingLeftLength=value.at(SECOND+SWING_LEFT_LENGTH).toFloat();
        secondFloor.swingRightLength=value.at(SECOND+SWING_RIGHT_LENGTH).toFloat();
        secondFloor.swingLeftStayTime=value.at(SECOND+SWING_LEFT_STAYTIME).toFloat();
        secondFloor.swingRightStayTime=value.at(SECOND+SWING_RIGHT_STAYTIME).toFloat();
        secondFloor.totalStayTime=secondFloor.swingLeftStayTime+secondFloor.swingRightStayTime;
        secondFloor.totalStayTime=float(qRound(10*secondFloor.totalStayTime));
        secondFloor.totalStayTime=secondFloor.totalStayTime/10;
        secondFloor.weldSwingSpacing=value.at(SECOND+SWING_SPACING).toFloat();
       // secondFloor.fillCoefficient=value.at(SECOND+FILL_COE).toFloat();;
        secondFloor.current=secondFloor.current_left;
        secondFloor.maxWeldSpeed=value.at(SECOND+MAX_SPEED).toFloat();
        secondFloor.minWeldSpeed=value.at(SECOND+MIN_SPEED).toFloat();
        secondFloor.voltage=value.at(SECOND+VOLTAGE).toFloat();
        //填充层限制条件
        fillFloor.name="fillFloor";
        fillFloor.current_left=value.at(FILL+CURRENT-1).toFloat();
        fillFloor.current_middle=value.at(FILL+CURRENT).toFloat();
        fillFloor.current_right=value.at(FILL+CURRENT+1).toFloat();
        fillFloor.maxHeight=value.at(FILL+MAX_HEIGHT).toFloat();
        fillFloor.minHeight=value.at(FILL+MIN_HEIGHT).toFloat();
        fillFloor.k=value.at(FILL+K).toFloat();
        fillFloor.maxSwingLength=value.at(FILL+MAX_SWING_LENGTH).toFloat();
        fillFloor.swingLeftLength=value.at(FILL+SWING_LEFT_LENGTH).toFloat();
        fillFloor.swingRightLength=value.at(FILL+SWING_RIGHT_LENGTH).toFloat();
        fillFloor.swingLeftStayTime=value.at(FILL+SWING_LEFT_STAYTIME).toFloat();
        fillFloor.swingRightStayTime=value.at(FILL+SWING_RIGHT_STAYTIME).toFloat();
        fillFloor.totalStayTime=fillFloor.swingLeftStayTime+fillFloor.swingRightStayTime;
        fillFloor.totalStayTime=float(qRound(fillFloor.totalStayTime*10))/10;
        fillFloor.weldSwingSpacing=value.at(FILL+SWING_SPACING).toFloat();
     //   fillFloor.fillCoefficient=value.at(FILL+FILL_COE).toFloat();;
        fillFloor.current= fillFloor.current_left;
        fillFloor.maxWeldSpeed=value.at(FILL+MAX_SPEED).toFloat();
        fillFloor.minWeldSpeed=value.at(FILL+MIN_SPEED).toFloat();
        fillFloor.voltage=value.at(FILL+VOLTAGE).toFloat();
        //表层限制条件
        topFloor.name="topFloor";
        topFloor.current_left=value.at(TOP+CURRENT-1).toFloat();
        topFloor.current_middle=value.at(TOP+CURRENT).toFloat();
        topFloor.current_right=value.at(TOP+CURRENT+1).toFloat();
        topFloor.maxHeight=value.at(TOP+MAX_HEIGHT).toFloat();
        topFloor.minHeight=value.at(TOP+MIN_HEIGHT).toFloat();
        topFloor.k=value.at(TOP+K).toFloat();
        topFloor.maxSwingLength=value.at(TOP+MAX_SWING_LENGTH).toFloat();
        topFloor.swingLeftLength=value.at(TOP+SWING_LEFT_LENGTH).toFloat();
        topFloor.swingRightLength=value.at(TOP+SWING_RIGHT_LENGTH).toFloat();
        topFloor.swingLeftStayTime=value.at(TOP+SWING_LEFT_STAYTIME).toFloat();
        topFloor.swingRightStayTime=value.at(TOP+SWING_RIGHT_STAYTIME).toFloat();
        topFloor.totalStayTime=topFloor.swingLeftStayTime+topFloor.swingRightStayTime;
        topFloor.totalStayTime=float(qRound(topFloor.totalStayTime*10))/10;
        topFloor.weldSwingSpacing=value.at(TOP+SWING_SPACING).toFloat();
       // topFloor.fillCoefficient=value.at(TOP+FILL_COE).toFloat();;
        topFloor.maxWeldSpeed=value.at(TOP+MAX_SPEED).toFloat();
        topFloor.minWeldSpeed=value.at(TOP+MIN_SPEED).toFloat();
        topFloor.voltage=value.at(TOP+VOLTAGE).toFloat();

        if(value.length()>80){
            //立板层限制条件
            overFloor.name="overFloor";
            overFloor.current_left=value.at(OVER+CURRENT-1).toFloat();
            overFloor.current_middle=value.at(OVER+CURRENT).toFloat();
            overFloor.current_right=value.at(OVER+CURRENT+1).toFloat();
            overFloor.maxHeight=value.at(OVER+MAX_HEIGHT).toFloat();
            overFloor.minHeight=value.at(OVER+MIN_HEIGHT).toFloat();
            overFloor.k=value.at(OVER+K).toFloat();
            overFloor.maxSwingLength=value.at(OVER+MAX_SWING_LENGTH).toFloat();
            overFloor.swingLeftLength=value.at(OVER+SWING_LEFT_LENGTH).toFloat();
            overFloor.swingRightLength=value.at(OVER+SWING_RIGHT_LENGTH).toFloat();
            overFloor.swingLeftStayTime=value.at(OVER+SWING_LEFT_STAYTIME).toFloat();
            overFloor.swingRightStayTime=value.at(OVER+SWING_RIGHT_STAYTIME).toFloat();
            overFloor.totalStayTime=overFloor.swingLeftStayTime+overFloor.swingRightStayTime;

            overFloor.totalStayTime=float(qRound(overFloor.totalStayTime*10))/10;
            overFloor.weldSwingSpacing=value.at(OVER+SWING_SPACING).toFloat();
      //      overFloor.fillCoefficient=value.at(OVER+FILL_COE).toFloat();;
            overFloor.maxWeldSpeed=value.at(OVER+MAX_SPEED).toFloat();
            overFloor.minWeldSpeed=value.at(OVER+MIN_SPEED).toFloat();
            overFloor.voltage=value.at(OVER+VOLTAGE).toFloat();
            sysMath.overFloor=&overFloor;
        }

        sysMath.bottomFloor=sysMath.ceramicBack==1?&bottomFloor0:&bottomFloor;
        sysMath.secondFloor=&secondFloor;
        sysMath.fillFloor=&fillFloor;
        sysMath.topFloor=&topFloor;
    }else
        return false;
    return true;
}
