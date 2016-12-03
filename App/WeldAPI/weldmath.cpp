#include "weldmath.h"
#define ENABLE_SOLVE_FIRST                              1
#include <QtMath>

//weldMath
WeldMath::WeldMath()
{
    //meltingCoefficientValue=105;
    connect(&flat,SIGNAL(weldRulesChanged(QStringList )),this,SLOT(setWeldRules(QStringList )));
    connect(&horizontal,SIGNAL(weldRulesChanged(QStringList )),this,SLOT(setWeldRules(QStringList )));
    connect(&vertical,SIGNAL(weldRulesChanged(QStringList )),this,SLOT(setWeldRules(QStringList )));
    flat.meltingCoefficientValue=105;
    vertical.meltingCoefficientValue=105;
    horizontal.meltingCoefficientValue=100;
    fillet.meltingCoefficientValue=0.98;
    flat.p=0;
    vertical.rootFace=0;
    horizontal.rootFace=0;
    fillet.rootFace=0;
}

void WeldMath::setReinforcement(int value){
    switch (grooveValue) {
    case 0:
    case 1:
    case 2: flat.reinforcementValue=value; break;
    case 3:
    case 4: horizontal.reinforcementValue=value; break;
    case 5:
    case 6:
    case 7: vertical.reinforcementValue=value; break;
    case 8: fillet.reinforcementValue=value;break;
    default:
        break;
    }
}

void WeldMath::setMeltingCoefficient(int value){
    switch (grooveValue) {
    case 0:
    case 1:
    case 2: flat.meltingCoefficientValue=value; break;
    case 3:
    case 4: horizontal.meltingCoefficientValue=value; break;
    case 5:
    case 6:
    case 7: vertical.meltingCoefficientValue=value; break;
    case 8: fillet.meltingCoefficientValue=value;break;
    default:
        break;
    }
}

void WeldMath::setWeldRules(QStringList value){
    emit weldRulesChanged(value);
}

void WeldMath::setGrooveRules(QStringList value){
    qDebug()<<"WeldMath::setGrooveRules "<<value;
    //数组有效
    switch (grooveValue) {
    case 0:
    case 1:
    case 2:
        flat.bottomFloor=flat.ceramicBack==1?&bottomFloor0:&bottomFloor;
        //如果发生计算错误则 抛出错误 提示。
        if(flat.setGrooveRules(value)==-1){
            value.clear();
            value<<flat.status;
            emit weldRulesChanged(value) ;
        }
        break;
    case 3:
    case 4:
        horizontal.bottomFloor=horizontal.ceramicBack==1?&bottomFloor0:&bottomFloor;
        horizontal.setGrooveRules(value); break;
    case 5:
    case 6:
    case 7:
        vertical.bottomFloor=vertical.ceramicBack==1?&bottomFloor0:&bottomFloor;
        vertical.setGrooveRules(value); break;
    case 8:
        fillet.setGrooveRules(value);break;
    default:
        break;
    }
}

void WeldMath::setCeramicBack(int value){
    qDebug()<<"WeldMath::setCeramicBack"<<value;
    //数组有效
    switch (grooveValue) {
    case 0:
    case 1:
    case 2:flat.ceramicBack=value; break;
    case 3:
    case 4: horizontal.ceramicBack=value; break;
    case 5:
    case 6:
    case 7:vertical.ceramicBack=value; break;
    case 8:break;
    default:
        break;
    }
}

void WeldMath::setGas(int value){
    switch (grooveValue) {
    case 0:
    case 1:
    case 2:flat.gasValue=value; break;
    case 3:
    case 4: horizontal.gasValue=value; break;
    case 5:
    case 6:
    case 7:vertical.gasValue=value; break;
    case 8:fillet.gasValue=value;break;
    default:
        break;
    }
}
void WeldMath::setPulse(int value){
    switch (grooveValue) {
    case 0:
    case 1:
    case 2:flat.pulseValue=value; break;
    case 3:
    case 4: horizontal.pulseValue=value; break;
    case 5:
    case 6:
    case 7:vertical.pulseValue=value; break;
    case 8:fillet.pulseValue=value;break;
    default:
        break;
    }
}

void WeldMath::setWireType(int value){
    switch (grooveValue) {
    case 0:
    case 1:
    case 2: flat.wireTypeValue=value; break;
    case 3:
    case 4: horizontal.wireTypeValue=value; break;
    case 5:
    case 6:
    case 7: vertical.wireTypeValue=value; break;
    case 8: fillet.wireTypeValue=value;break;
    default:
        break;
    }
}

void WeldMath::setWireD(int value){
    switch (grooveValue) {
    case 0:
    case 1:
    case 2: flat.wireDValue=value; break;
    case 3:
    case 4: horizontal.wireDValue=value; break;
    case 5:
    case 6:
    case 7: vertical.wireDValue=value; break;
    case 8: fillet.wireDValue=value;break;
    default:
        break;
    }
}

void WeldMath::setGrooveDir(bool value){
    switch (grooveValue) {
    case 0:
    case 1:
    case 2: flat.grooveDirValue=value; break;
    case 3:
    case 4: horizontal.grooveDirValue=value; break;
    case 5:
    case 6:
    case 7: vertical.grooveDirValue=value; break;
    case 8: break;
    default:
        break;
    }
}

void WeldMath::setGroove(int value){
    grooveValue=value;
}

int WeldMath::getFeedSpeed(int current){
    int res=0;
    switch (grooveValue) {
    case 0:
    case 1:
    case 2: res=flat.getFeedSpeed(current); break;
    case 3:
    case 4: res=horizontal.getFeedSpeed(current); break;
    case 5:
    case 6:
    case 7:res=vertical.getFeedSpeed(current);break;
    case 8: res=fillet.getFeedSpeed(current); break;
    default:
        break;
    }
    return  res;
}

float WeldMath::getWeldArea(int current, float weldSpeed,float k,float met){
    float res=0;
    switch (grooveValue) {
    case 0:
    case 1:
    case 2: flat.weldWireSquare=(flat.wireDValue==4?1.2*1.2:1.6*1.6)*PI/4; res=met*(flat.getFeedSpeed(current)*flat.weldWireSquare)/(weldSpeed*10)/k; break;
    case 3:
    case 4: horizontal.weldWireSquare=(horizontal.wireDValue==4?1.2*1.2:1.6*1.6)*PI/4; res=met*(horizontal.getFeedSpeed(current)*horizontal.weldWireSquare)/(weldSpeed*10)/k;break;
    case 5:
    case 6:
    case 7: vertical.weldWireSquare=(vertical.wireDValue==4?1.2*1.2:1.6*1.6)*PI/4; res=(vertical.getFeedSpeed(current)*vertical.weldWireSquare)/(weldSpeed*10)/k;break;
    case 8: fillet.weldWireSquare=(fillet.wireDValue==4?1.2*1.2:1.6*1.6)*PI/4; res=(fillet.getFeedSpeed(current)*fillet.weldWireSquare)/(weldSpeed*10)/k; break;
    default:
        break;
    }
    return  res;
}

float WeldMath::getWeldA(float swing,float swingLeftStayTime,float swingRightStayTime,float weldSpeed,float maxSpeed){
    float res=0;
    switch (grooveValue) {
    case 0: break;
    case 1: break;
    case 2: flat.getSwingSpeed(swing,swingLeftStayTime,swingRightStayTime,weldSpeed*10,maxSpeed); break;
    case 3: break;
    case 4: break;
    case 5: break;
    case 6: break;
    case 7: break;
    case 8:break;
    default:
        break;
    }
    return  res;
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

void WeldMath::setLimited(QStringList value){
    qDebug()<<"WeldMath::setLimited value "<<value;
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
    bottomFloor0.fillCoefficient=value.at(BOTTOM_0+FILL_COE).toFloat();
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
    bottomFloor.fillCoefficient=value.at(BOTTOM_1+FILL_COE).toFloat();
    bottomFloor.current=bottomFloor.current_left;
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
    secondFloor.fillCoefficient=value.at(SECOND+FILL_COE).toFloat();;
    secondFloor.current=secondFloor.current_left;
    secondFloor.maxWeldSpeed=value.at(SECOND+MAX_SPEED).toFloat();
    secondFloor.minWeldSpeed=value.at(SECOND+MIN_SPEED).toFloat();
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
    fillFloor.fillCoefficient=value.at(FILL+FILL_COE).toFloat();;
    fillFloor.current= fillFloor.current_left;
    fillFloor.maxWeldSpeed=value.at(FILL+MAX_SPEED).toFloat();
    fillFloor.minWeldSpeed=value.at(FILL+MIN_SPEED).toFloat();
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
    topFloor.fillCoefficient=value.at(TOP+FILL_COE).toFloat();;
    topFloor.maxWeldSpeed=value.at(TOP+MAX_SPEED).toFloat();
    topFloor.minWeldSpeed=value.at(TOP+MIN_SPEED).toFloat();

    switch (grooveValue) {
    case 0:flat.bottomFloor=flat.ceramicBack==1?&bottomFloor0:&bottomFloor;flat.secondFloor=&secondFloor;flat.fillFloor=&fillFloor;flat.topFloor=&topFloor; break;
    case 1: flat.bottomFloor=flat.ceramicBack==1?&bottomFloor0:&bottomFloor;flat.secondFloor=&secondFloor;flat.fillFloor=&fillFloor;flat.topFloor=&topFloor; break;
    case 2:flat.bottomFloor=flat.ceramicBack==1?&bottomFloor0:&bottomFloor;flat.secondFloor=&secondFloor;flat.fillFloor=&fillFloor;flat.topFloor=&topFloor; break;
    case 3:horizontal.bottomFloor=horizontal.ceramicBack==1?&bottomFloor0:&bottomFloor;horizontal.secondFloor=&secondFloor;horizontal.fillFloor=&fillFloor;horizontal.topFloor=&topFloor;  break;
    case 4: horizontal.bottomFloor=horizontal.ceramicBack==1?&bottomFloor0:&bottomFloor;horizontal.secondFloor=&secondFloor;horizontal.fillFloor=&fillFloor;horizontal.topFloor=&topFloor; break;
    case 5: vertical.bottomFloor=vertical.ceramicBack==1?&bottomFloor0:&bottomFloor;vertical.secondFloor=&secondFloor;vertical.fillFloor=&fillFloor;vertical.topFloor=&topFloor; break;
    case 6: vertical.bottomFloor=vertical.ceramicBack==1?&bottomFloor0:&bottomFloor;vertical.secondFloor=&secondFloor;vertical.fillFloor=&fillFloor;vertical.topFloor=&topFloor; break;
    case 7:vertical.bottomFloor=vertical.ceramicBack==1?&bottomFloor0:&bottomFloor;vertical.secondFloor=&secondFloor;vertical.fillFloor=&fillFloor;vertical.topFloor=&topFloor; break;
    case 8: vertical.bottomFloor=vertical.ceramicBack==1?&bottomFloor0:&bottomFloor;vertical.secondFloor=&secondFloor;vertical.fillFloor=&fillFloor;vertical.topFloor=&topFloor; break;
    default:
        break;
    }
}
