#include "weldmath.h"
#define ENABLE_SOLVE_FIRST                              1

//weldMath
WeldMath::WeldMath()
{
    meltingCoefficientValue=105;
}

//打底层函数计算
void WeldMath::firstFloorFunc(){
    QStringList value;
    h=bottomFloor.height;
    float current=solveI(&bottomFloor,0,1);
    //计算填充面积
    float s=((h-p)*(h-p)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap*h)*bottomFloor.fillCoefficient;
    //求取摆宽宽 摆宽为 填充高度的1/2位置
    float swingLength=qMax(float(0),(h/2-p))*(grooveAngel1Tan+grooveAngel2Tan)+rootGap-bottomFloor.swingLeftLength-bottomFloor.swingRightLength;
    //保留一位整数 小数位为偶数
    float swingLengthOne=float(qRound(swingLength*5))/5;
    //计算摆动频率
    int swingHz=getSwingHz(qCeil(swingLengthOne),0,bottomFloor.totalStayTime);
    //计算电压
    int voltage=getVoltage(current);
    //计算送丝速度
    int feedSpeed=getFeedSpeed(current);
    //计算最大焊接速度 溶敷系数*摆动周期*焊丝橫截面积*送丝速度
    float weldSpeed=(meltingCoefficientValue*60*weldWireSquare*feedSpeed)/(swingHz*bottomFloor.totalStayTime*s*100);
    //保证焊接速度不大于最大焊接速度 否则减小电流
    if(weldSpeed>bottomFloor.maxWeldSpeed){
        while(weldSpeed>bottomFloor.maxWeldSpeed){
            current-=10;
            voltage=getVoltage(current);
            feedSpeed=getFeedSpeed(current);
            weldSpeed=(meltingCoefficientValue*60*weldWireSquare*feedSpeed)/(swingHz*bottomFloor.totalStayTime*s*100);
            weldSpeed=qRound(weldSpeed);
            // if()/***********************************************此处尚且存在争议未决。
            // status=""
           if(current==0){
               status="输入条件错误";
               break;
           }
        }
    }else if((s>=bottomFloor.maxFillMetal)||(weldSpeed<bottomFloor.minWeldSpeed)){
        weldSpeed=qCeil(weldSpeed);
    }else{
        weldSpeed=qRound(weldSpeed);
    }
    //重新计算s
    s=((meltingCoefficientValue*60*weldWireSquare*feedSpeed)/(weldSpeed*swingHz*100*bottomFloor.totalStayTime))/bottomFloor.fillCoefficient;
    float aa=(grooveAngel1Tan+grooveAngel2Tan)/2;
    float bb=rootGap-p*(grooveAngel1Tan+grooveAngel2Tan);
    float cc=(p*p)*(grooveAngel1Tan+grooveAngel2Tan)/2-s;
    //重新计算h
    h=(qSqrt(bb*bb-4*aa*cc)-bb)/(2*aa);
    //重新计算 摆动范围据坡口左右侧壁的距离 为了精确计算 X偏移
    float reSwingLeftLength= ((qMax(float(0),(h/2-p))*(grooveAngel1Tan+grooveAngel2Tan)+rootGap-swingLengthOne)*(bottomFloor.swingLeftLength))/(bottomFloor.swingLeftLength+bottomFloor.swingRightLength);
    //中线偏移
    //float weldLineY=float(qRound(10h/2))/10;
    float weldLineY=0;
    weldLineYUesd=float(qRound(10*h))/10;
    //中线偏移X 取一位小数
    float weldLineX= float(qRound(10*(reSwingLeftLength+swingLengthOne/2-qMax(float(0),(h/2-p)*grooveAngel1Tan)-rootGap/2)))/10;
    //循环迭代层面积
    sUsed=s;
    //循环迭代层高
    hUsed=h;
    //全部参数计算完成
    value.clear();
    value<<status<<QString::number(currentWeldNum)<<"1/1"<<QString::number(current)<<QString::number(voltage)<<QString::number(swingLengthOne/2)
        <<QString::number(swingHz)<<QString::number(weldSpeed/10)<<QString::number(weldLineX)<<QString::number(weldLineY)
       <<QString::number(bottomFloor.swingLeftStayTime)<<QString::number(bottomFloor.swingRightStayTime)<<"1"
      <<QString::number(float(qRound(s*10))/10)<<QString::number(float(qRound(s*10))/10)<<QString::number(weldLineX)<<QString::number(weldLineY)
     <<QString::number(startArcz);
    emit weldRulesChanged(value);
}
//计算第二层
void WeldMath::FloorFunc(FloorCondition *pF){
    int i,j;
    float s,swingLength,aa,bb,cc,weldLineY,weldLineX,swingLengthOne,swingHz,reSwingLeftLength;
    int weldNum;
    QStringList value;
    for(i=0;i<pF->num;i++){
        //层数+1
        floorNum+=1;
        h=pF->height;
        s=((hUsed+h-p)*(hUsed+h-p)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap*(hUsed+h)-sUsed)*pF->fillCoefficient;
        swingLength=(hUsed+h/2-p)*(grooveAngel1Tan+grooveAngel2Tan)+rootGap-pF->swingLeftLength-pF->swingRightLength;
        weldNum=qCeil((swingLength+pF->weldSwingSpacing)/(pF->maxSwingLength+pF->weldSwingSpacing));
        //获取每一道填充
        float weldFill[weldNum];
        //初始化数组
        solveA(&weldFill[0],pF,weldNum,s);
        //分道后面积过小，减少一条焊道，在一定程度上增大单道摆动宽度
        if(weldFill[weldNum-1]<pF->minFillMetal){
            if(weldNum>1){
                weldNum-=1;
                solveA(&weldFill[0],pF,weldNum,s);
            }
            //else //分道过小
            //return -1;
        }
        swingLengthOne=float(qRound(5*(swingLength-(weldNum-1)*pF->weldSwingSpacing)/weldNum))/5;
        swingHz=getSwingHz(qCeil(swingLengthOne),1,pF->totalStayTime);
        s=0;
        //道循环
        //层内每一道的电流
        float weldCurrent[weldNum];
        //层内每一道的电压
        float weldVoltage[weldNum];
        //层内每一道的送丝速度
        float weldFeedSpeed[weldNum];
        //层内每一道的焊接速度
        float weldTravelSpeed[weldNum];
        for(j=0;j<weldNum;j++){
            weldCurrent[j]=solveI(pF,j,weldNum);
            weldVoltage[j]=getVoltage(weldCurrent[j]);
            weldFeedSpeed[j]=getFeedSpeed(weldCurrent[j]);
            weldTravelSpeed[j]=(meltingCoefficientValue*60*weldWireSquare*weldFeedSpeed[j])/(swingHz*pF->totalStayTime*weldFill[j]*100);
            //保证焊接速度不大于最大焊接速度 否则减小电流
            if(weldTravelSpeed[j]>pF->maxWeldSpeed){
                while(weldTravelSpeed[j]>pF->maxWeldSpeed){
                    weldCurrent[j]-=10;
                    weldVoltage[j]=getVoltage(weldCurrent[j]);
                    weldFeedSpeed[j]=getFeedSpeed(weldCurrent[j]);
                    weldTravelSpeed[j]=(meltingCoefficientValue*60*weldWireSquare*weldFeedSpeed[j])/(swingHz*pF->totalStayTime*weldFill[j]*100);
                }
                weldTravelSpeed[j]=qRound(weldTravelSpeed[j]);
            }else if((weldFill[j]>pF->maxFillMetal)||(weldTravelSpeed[j]<pF->minWeldSpeed)){
                weldTravelSpeed[j]=qCeil(weldTravelSpeed[j]);
            }else{
                weldTravelSpeed[j]=qRound(weldTravelSpeed[j]);
            }
            //重新计算焊道面积
            weldFill[j]=(meltingCoefficientValue*60*weldWireSquare*weldFeedSpeed[j])/(weldTravelSpeed[j]*swingHz*100*pF->totalStayTime)/pF->fillCoefficient;
            //重新计算层面积
            s+=weldFill[j];
        }
        aa=(grooveAngel1Tan+grooveAngel2Tan)/2;
        bb=rootGap+(hUsed-p)*(grooveAngel1Tan+grooveAngel2Tan);
        cc=(hUsed-p)*(hUsed-p)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap*hUsed-sUsed-s;
        //重新计算h
        h=(qSqrt(bb*bb-4*aa*cc)-bb)/(2*aa);
        //重新计算
        reSwingLeftLength= (((hUsed+h/2-p)*(grooveAngel1Tan+grooveAngel2Tan)+rootGap-weldNum*swingLengthOne-(weldNum-1)*pF->weldSwingSpacing)*(bottomFloor.swingLeftLength))/(bottomFloor.swingLeftLength+bottomFloor.swingRightLength);
        //中线偏移Y
        weldLineY=weldLineYUesd ;//+ float(qRound(10*h/2))/10;
        //迭代中线偏移Y
        weldLineYUesd=weldLineY+ float(qRound(10*h))/10;//weldLineY*2-weldLineYUesd;
        //单层内所有道计算完成 依次发送数据
        for(j=0;j<weldNum;j++){
            //焊道数增加
            currentWeldNum++;
            //中线偏移X 取一位小数
            weldLineX= float(qRound(10*(reSwingLeftLength+swingLengthOne/2+(swingLengthOne+pF->weldSwingSpacing)*(j)-qMax(float(0),(hUsed+h/2-p)*grooveAngel1Tan)-rootGap/2)))/10;
            //全部参数计算完成
            value.clear();
            value<<status<<QString::number(currentWeldNum)<<QString::number(floorNum)+"/"+QString::number(j+1)<<QString::number(weldCurrent[j])<<QString::number(weldVoltage[j])<<QString::number(swingLengthOne/2)
                <<QString::number(swingHz)<<QString::number(weldTravelSpeed[j]/10)<<QString::number(weldLineX)<<QString::number(weldLineY)
               <<QString::number(pF->swingLeftStayTime)<<QString::number(pF->swingRightStayTime)<<"1"
              <<QString::number(float(qRound(s*10))/10)<<QString::number(float(qRound(weldFill[j]*10))/10)<<QString::number(weldLineX)<<QString::number(weldLineY) <<QString::number(0);;
            emit weldRulesChanged(value);
        }
        //迭代赋值
        sUsed+=s;
        hUsed+=h;
    }
}

void WeldMath::topFloorFunc(){
    /**计算盖面层***********************************************/
    int j;
    QStringList value;
    float ba=1.5;

    floorNum+=1;
    h=grooveHeight+reinforcementValue-hUsed;

    float s=(grooveHeight-p)*(grooveHeight-p)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap*grooveHeight+
            reinforcementValue*(2*(grooveHeight-p)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap+2*ba)/2-sUsed;

    float swingLength=(hUsed+h/2-p)*(grooveAngel1Tan+grooveAngel2Tan)+rootGap-topFloor.swingLeftLength-topFloor.swingRightLength;

    int weldNum=qCeil((swingLength+topFloor.weldSwingSpacing)/(topFloor.maxSwingLength+topFloor.weldSwingSpacing));

    //获取每一道填充
    float weldFill[weldNum];
    //初始化数组
    solveA(&weldFill[0],&topFloor,weldNum,s);
    //分道后面积过小，减少一条焊道，在一定程度上增大单道摆动宽度
    if(weldFill[0]<topFloor.minFillMetal){
        if(weldNum>1){
            weldNum-=1;
            solveA(&weldFill[0],&topFloor,weldNum,s);
        }
    }
    float swingLengthOne=float(qRound(5*(swingLength-(weldNum-1)*topFloor.weldSwingSpacing)/weldNum))/5;
    float swingHz=getSwingHz(qCeil(swingLengthOne),2,topFloor.totalStayTime);
    s=0;
    //层内每一道的电流
    float weldCurrent[weldNum];
    //层内每一道的电压
    float weldVoltage[weldNum];
    //层内每一道的送丝速度
    float weldFeedSpeed[weldNum];
    //层内每一道的焊接速度
    float weldTravelSpeed[weldNum];
    //z轴收缩
    startArcz-=3;
    for(j=0;j<weldNum;j++){
        weldCurrent[j]=solveI(&topFloor,j,weldNum);
        weldVoltage[j]=getVoltage(weldCurrent[j]);
        weldFeedSpeed[j]=getFeedSpeed(weldCurrent[j]);
        weldTravelSpeed[j]=(meltingCoefficientValue*60*weldWireSquare*weldFeedSpeed[j])/(swingHz*topFloor.totalStayTime*weldFill[j]*100);
        //保证焊接速度不大于最大焊接速度 否则减小电流
        if(weldTravelSpeed[j]>topFloor.maxWeldSpeed){
            weldTravelSpeed[j]=qRound(weldTravelSpeed[j]);
            while(weldTravelSpeed[j]>topFloor.maxWeldSpeed){
                weldCurrent[j]-=10;
                weldVoltage[j]=getVoltage(weldCurrent[j]);
                weldFeedSpeed[j]=getFeedSpeed(weldCurrent[j]);
                weldTravelSpeed[j]=(meltingCoefficientValue*60*weldWireSquare*weldFeedSpeed[j])/(swingHz*topFloor.totalStayTime*weldFill[j]*100);
                weldTravelSpeed[j]=qRound(weldTravelSpeed[j]);
            }
        }else if((weldFill[j]>topFloor.maxFillMetal)||(weldTravelSpeed[j]<topFloor.minWeldSpeed)){
            weldTravelSpeed[j]=qCeil(weldTravelSpeed[j]);
        }else{
            weldTravelSpeed[j]=qRound(weldTravelSpeed[j]);
        }
        //重新计算焊道面积
        weldFill[j]=(meltingCoefficientValue*60*weldWireSquare*weldFeedSpeed[j])/(weldTravelSpeed[j]*swingHz*100*topFloor.totalStayTime);
        //重新计算层面积
        s+=weldFill[j];
    }
    h=grooveHeight-hUsed+2*(s+sUsed-((grooveHeight-p)*(grooveHeight-p)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap*grooveHeight))/(((grooveAngel1Tan+grooveAngel2Tan)*(grooveHeight-p)+rootGap+2*ba));
    //中线偏移Y
    float  weldLineY=weldLineYUesd ;
    //迭代中线偏移Y
    weldLineYUesd=weldLineY+ float(qRound(10*h))/10;
    //重新计算
    float  reSwingLeftLength= (((hUsed+h/2-p)*(grooveAngel1Tan+grooveAngel2Tan)+rootGap-weldNum*swingLengthOne-(weldNum-1)*fillFloor.weldSwingSpacing)*(fillFloor.swingLeftLength))/(fillFloor.swingLeftLength+fillFloor.swingRightLength);
    for(j=0;j<weldNum;j++){
        //中线偏移X 取一位小数
        float weldLineX= float(qRound(10*(reSwingLeftLength+swingLengthOne/2+(swingLengthOne+topFloor.weldSwingSpacing)*(j)-qMax(float(0),(hUsed+h/2-p)*grooveAngel1Tan)-rootGap/2)))/10;
        currentWeldNum++;
        //全部参数计算完成
        value.clear();
        value<<status<<QString::number(currentWeldNum)<<QString::number(floorNum)+"/"+QString::number(j+1)<<QString::number(weldCurrent[j])<<QString::number(weldVoltage[j])<<QString::number(swingLengthOne/2)
            <<QString::number(swingHz)<<QString::number(weldTravelSpeed[j]/10)<<QString::number(weldLineX)<<QString::number(weldLineY)
           <<QString::number(topFloor.swingLeftStayTime)<<QString::number(topFloor.swingRightStayTime)<<"1"
          <<QString::number(float(qRound(s*10))/10)<<QString::number(float(qRound(weldFill[j]*10))/10)<<QString::number(weldLineX)<<QString::number(weldLineY) <<QString::number(0);;

        emit weldRulesChanged(value);
    }
}

int WeldMath::weldMathFunction(){
    //当前道号
    currentWeldNum=0;
    floorNum=1;
    QStringList value;
    float current=solveI(&bottomFloor,0,1);
    bottomFloor.height=bottomFloor.maxHeight;
    //角度变量
    grooveAngel1Tan=qTan(grooveAngel1*PI/180);
    grooveAngel2Tan=qTan(grooveAngel2*PI/180);
    //焊丝橫截面积
    weldWireSquare=(wireDValue==4?1.2*1.2:1.6*1.6)*PI/4;
    //起弧z位置
    startArcz=0;
    //状态为successed
    status="Successed";
    //最大摆动频率
    bottomFloor.maxSwingHz=getSwingHz(1,0,bottomFloor.totalStayTime);
    //最小摆动频率
    bottomFloor.minSwingHz=getSwingHz(20,0,bottomFloor.totalStayTime);
    //底层最大填充量
    bottomFloor.maxFillMetal=(meltingCoefficientValue*weldWireSquare*
                              getFeedSpeed(bottomFloor.current_middle)*60)/(bottomFloor.minWeldSpeed*bottomFloor.totalStayTime
                                                                     *bottomFloor.minSwingHz*100);
    //底层最小填充量
    bottomFloor.minFillMetal=(meltingCoefficientValue*weldWireSquare*
                              getFeedSpeed(bottomFloor.current_middle)*60)/(bottomFloor.maxWeldSpeed*bottomFloor.totalStayTime
                                                                     *bottomFloor.maxSwingHz*100);
    //最大摆动频率
    secondFloor.maxSwingHz=getSwingHz(1,1,secondFloor.totalStayTime);
    //最小摆动频率
    secondFloor.minSwingHz=getSwingHz(20,1,secondFloor.totalStayTime);
    //底层最大填充量
    secondFloor.maxFillMetal=(meltingCoefficientValue*weldWireSquare*
                              getFeedSpeed(secondFloor.current_middle)*60)/(secondFloor.minWeldSpeed*secondFloor.totalStayTime
                                                                     *secondFloor.minSwingHz*100);
    //底层最小填充量
    secondFloor.minFillMetal=(meltingCoefficientValue*weldWireSquare*
                              getFeedSpeed(secondFloor.current_middle)*60)/(secondFloor.maxWeldSpeed*secondFloor.totalStayTime
                                                                     *secondFloor.maxSwingHz*100);
    //最大摆动频率
    fillFloor.maxSwingHz=getSwingHz(1,2,fillFloor.totalStayTime);
    //最小摆动频率
    fillFloor.minSwingHz=getSwingHz(20,2,fillFloor.totalStayTime);
    //填充层最大填充量
    fillFloor.maxFillMetal=(meltingCoefficientValue*weldWireSquare*
                            getFeedSpeed(fillFloor.current_middle)*60)/(fillFloor.minWeldSpeed*fillFloor.totalStayTime
                                                                 *fillFloor.minSwingHz*100);
    //填充层最小填充量
    fillFloor.minFillMetal=(meltingCoefficientValue*weldWireSquare*
                            getFeedSpeed(fillFloor.current_middle)*60)/(fillFloor.maxWeldSpeed*fillFloor.totalStayTime
                                                                 *fillFloor.maxSwingHz*100);
    //最大摆动频率
    topFloor.maxSwingHz=getSwingHz(1,3,topFloor.totalStayTime);
    //最小摆动频率
    topFloor.minSwingHz=getSwingHz(20,3,topFloor.totalStayTime);
    //顶层最大填充量
    topFloor.maxFillMetal=(meltingCoefficientValue*weldWireSquare*
                           getFeedSpeed(topFloor.current_middle)*60)/(topFloor.minWeldSpeed*topFloor.totalStayTime
                                                               *topFloor.minSwingHz*100);
    //顶层最小填充量
    topFloor.minFillMetal=(meltingCoefficientValue*weldWireSquare*
                           getFeedSpeed(topFloor.current_middle)*60)/(topFloor.maxWeldSpeed*topFloor.totalStayTime
                                                               *topFloor.maxSwingHz*100);


    /************************计算打底层*********************************************************/
    //计算填充面积
    float s=((bottomFloor.height-p)*(bottomFloor.height-p)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap*bottomFloor.height)*bottomFloor.fillCoefficient;
    //打底填充面积不可小于单道最小面积
    while(s<bottomFloor.minFillMetal){
        bottomFloor.height+=0.5;
        s=((bottomFloor.height-p)*(bottomFloor.height-p)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap*bottomFloor.height)*bottomFloor.fillCoefficient;
    }
    //打底层填充面积不可大于单道最大填充面积
    while(s>bottomFloor.maxFillMetal){
        if(bottomFloor.height>5)
            bottomFloor.height-=1;
        else
            bottomFloor.height-=0.5;
        s=((bottomFloor.height-p)*(bottomFloor.height-p)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap*bottomFloor.height)*bottomFloor.fillCoefficient;
    }
    //求取摆宽宽 摆宽为 填充高度的1/2位置
    float swingLength=qMax(float(0),(bottomFloor.height/2-p))*(grooveAngel1Tan+grooveAngel2Tan)+rootGap-bottomFloor.swingLeftLength-bottomFloor.swingRightLength;
    //保留一位整数 小数位为偶数
    float swingLengthOne;
    swingLengthOne=float(qRound(swingLength*5))/5;
    //计算摆动频率
    int swingHz=getSwingHz(qCeil(swingLengthOne),0,bottomFloor.totalStayTime);
    //计算电压
    int voltage=getVoltage(current);
    //计算送丝速度
    int feedSpeed=getFeedSpeed(current);
    //计算最大焊接速度 溶敷系数*摆动周期*焊丝橫截面积*送丝速度
    float weldSpeed=(meltingCoefficientValue*60*weldWireSquare*feedSpeed)/(swingHz*bottomFloor.totalStayTime*s*100);
    //保证焊接速度不大于最大焊接速度 否则减小电流
    if(weldSpeed>bottomFloor.maxWeldSpeed){
        while(weldSpeed>bottomFloor.maxWeldSpeed){
            current-=10;
            voltage=getVoltage(current);
            feedSpeed=getFeedSpeed(current);
            weldSpeed=(meltingCoefficientValue*60*weldWireSquare*feedSpeed)/(swingHz*bottomFloor.totalStayTime*s*100);
            weldSpeed=qRound(weldSpeed);
        }
    }else if((s>=bottomFloor.maxFillMetal)||(weldSpeed<bottomFloor.minWeldSpeed)){
        weldSpeed=qCeil(weldSpeed);
    }else{
        weldSpeed=qRound(weldSpeed);
    }
    //重新计算s
    s=((meltingCoefficientValue*60*weldWireSquare*feedSpeed)/(weldSpeed*swingHz*100*bottomFloor.totalStayTime))/bottomFloor.fillCoefficient;
    float aa=(grooveAngel1Tan+grooveAngel2Tan)/2;
    float bb=rootGap-p*(grooveAngel1Tan+grooveAngel2Tan);
    float cc=(p*p)*(grooveAngel1Tan+grooveAngel2Tan)/2-s;
    //重新计算h
    bottomFloor.height=(qSqrt(bb*bb-4*aa*cc)-bb)/(2*aa);
    //重新计算 摆动范围据坡口左右侧壁的距离 为了精确计算 X偏移
    float reSwingLeftLength= ((qMax(float(0),(bottomFloor.height/2-p))*(grooveAngel1Tan+grooveAngel2Tan)+rootGap-swingLengthOne)*(bottomFloor.swingLeftLength))/(bottomFloor.swingLeftLength+bottomFloor.swingRightLength);
    //中线偏移
    //float weldLineY=float(qRound(10*h/2))/10;
    float weldLineY=0;
    //中线偏移X 取一位小数
    float weldLineX= float(qRound(10*(reSwingLeftLength+swingLengthOne/2-qMax(float(0),(bottomFloor.height/2-p)*grooveAngel1Tan)-rootGap/2)))/10;
    currentWeldNum++;
    //循环迭代层面积
    sUsed=s;
    //循环迭代层高
    hUsed=h=bottomFloor.height;
    //循环迭代Y中线
    weldLineYUesd=float(qRound(10*h))/10;//2*weldLineY;
    //全部参数计算完成
    value.clear();
    value<<status<<QString::number(currentWeldNum)<<"1/1"<<QString::number(current)<<QString::number(voltage)<<QString::number(swingLengthOne/2)
        <<QString::number(swingHz)<<QString::number(weldSpeed/10)<<QString::number(weldLineX)<<QString::number(weldLineY)
       <<QString::number(bottomFloor.swingLeftStayTime)<<QString::number(bottomFloor.swingRightStayTime)<<"1"
      <<QString::number(float(qRound(s*10))/10)<<QString::number(float(qRound(s*10))/10)<<QString::number(weldLineX)<<QString::number(weldLineY)
     <<QString::number(startArcz);
    emit weldRulesChanged(value);
    startArcz=0;

    /**********************************************************************
     * 计算层数
     ************************************************************************/
    float hre=grooveHeight+reinforcementValue-hUsed;
    int res=solveN(&hre);
    /**计算第二层***********************************************/
    if(secondFloor.num>0){
        FloorFunc(&secondFloor);
    }
    if(fillFloor.num>0){
        FloorFunc(&fillFloor);
    }
    if(topFloor.num>0){
        topFloorFunc();
    }
    value.clear();
    value.append("Finish");
    emit grooveRulesChanged(value);
    return res;
}

int  WeldMath::getSwingHz(int swing,int floor,float stayTime){
    Q_UNUSED(floor);
    int swingHz=0;
    if(stayTime>1.21){
        status="停留时间不在范围内！";
    }
    else if(stayTime>=1.1){
        switch(swing){
        case 1:swingHz=38;break;
        case 2:swingHz=36;break;
        case 3:swingHz=34;break;
        case 4:swingHz=32;break;
        case 5:swingHz=31;break;
        case 6:swingHz=30;break;
        case 7:swingHz=29;break;
        case 8:swingHz=28;break;
        case 9:swingHz=27;break;
        case 10:swingHz=26;break;
        case 11:swingHz=25;break;
        case 12:swingHz=24;break;
        case 13:swingHz=23;break;
        case 14:swingHz=22;break;
        case 15:swingHz=21;break;
        case 16:swingHz=20;break;
        case 17:swingHz=19;break;
        case 18:swingHz=18;break;
        case 19:swingHz=17;break;
        default:swingHz=16;break;
        }}else if(stayTime>=0.9){
        switch(swing){
        case 1:swingHz=44;break;
        case 2:swingHz=41;break;
        case 3:swingHz=38;break;
        case 4:swingHz=36;break;
        case 5:swingHz=34;break;
        case 6:swingHz=33;break;
        case 7:swingHz=31;break;
        case 8:swingHz=30;break;
        case 9:swingHz=29;break;
        case 10:swingHz=28;break;
        case 11:swingHz=27;break;
        case 12:swingHz=26;break;
        case 13:swingHz=25;break;
        case 14:swingHz=24;break;
        case 15:swingHz=23;break;
        case 16:swingHz=22;break;
        case 17:swingHz=21;break;
        case 18:swingHz=20;break;
        case 19:swingHz=19;break;
        default:swingHz=17;break;
        }
    }else if(stayTime>=0.7){
        switch(swing){
        case 1:swingHz=52;break;
        case 2:swingHz=48;break;
        case 3:swingHz=43;break;
        case 4:swingHz=41;break;
        case 5:swingHz=38;break;
        case 6:swingHz=37;break;
        case 7:swingHz=36;break;
        case 8:swingHz=34;break;
        case 9:swingHz=33;break;
        case 10:swingHz=31;break;
        case 11:swingHz=30;break;
        case 12:swingHz=29;break;
        case 13:swingHz=27;break;
        case 14:swingHz=26;break;
        case 15:swingHz=25;break;
        case 16:swingHz=24;break;
        case 17:swingHz=23;break;
        case 18:swingHz=21;break;
        case 19:swingHz=20;break;
        default:swingHz=18;break;
        }
    }else if(stayTime>=0.5){
        switch(swing){
        case 1:swingHz=64;break;
        case 2:swingHz=58;break;
        case 3:swingHz=52;break;
        case 4:swingHz=48;break;
        case 5:swingHz=46;break;
        case 6:swingHz=45;break;
        case 7:swingHz=43;break;
        case 8:swingHz=42;break;
        case 9:swingHz=40;break;
        case 10:swingHz=38;break;
        case 11:swingHz=36;break;
        case 12:swingHz=34;break;
        case 13:swingHz=32;break;
        case 14:swingHz=31;break;
        case 15:swingHz=30;break;
        case 16:swingHz=29;break;
        case 17:swingHz=27;break;
        case 18:swingHz=26;break;
        case 19:swingHz=24;break;
        default:swingHz=22;break;
        }
    }else{
        status="停留时间不在范围内！";
    }
    return swingHz;
}

float WeldMath::getVoltage(int current){
    float voltage=18;
    if((gasValue)&&(pulseValue==0)&&(wireTypeValue==0)&&(wireDValue==4)){
        switch(current){
        case 90:
        case 100:voltage=14;break;
        case 110:voltage=15;break;
        case 120:voltage=16;break;
        case 130:voltage=17;break;
        case 140:voltage=17;break;
        case 150:voltage=18;break;
        case 160:voltage=18.5;break;
        case 170:voltage=19;break;
        case 180:voltage=20;break;
            //defalut:voltage=20;break;
        }
    }else if((gasValue)&&(pulseValue)&&(wireTypeValue==0)&&(wireDValue==4)){
        switch(current){
        case 60:voltage=16;break;
        case 70:voltage=17;break;
        case 80:voltage=18;break;
        case 90:voltage=19;break;
        case 100:voltage=20;break;
        case 110:voltage=21;break;
        case 120:voltage=22;break;
        case 130:voltage=23;break;
        case 140:voltage=24;break;
            //defalut: voltage=25;break;
        }
    }else {
        return -1;
    }
    return voltage;
}

int WeldMath::getFeedSpeed(int current){
    int feedspeed;
    const int FeedSpeedNum[3][35]={
        {1240,1280,1320,1360,1400,1536,1673,1845,2027,2215,
         2408,2600,2878,3155,3427,3700,4200,4645,5055,5478,
         5922,6367,6811,7155,7473,7960,8538,9100,9550,10000,
         10850,11700,12350,13000,14000},
        {300,600,900,1200,1600,2000,2400,2800,3199,3600,
         4000,4400,4800,5200,5600,6000,6500,7000,7400,7800,
         8300,8800,9300,9800,10300,10800,11300,11800,12300,12800,
         13400,14000,14600,15200,15900},
        {900,1000,1100,1200,1300,1400,1550,1700,1867,2050,
         2300,2562,2875,3200,3533,3867,4225,4600,5100,5871,
         6300,6762,7223,7750,8375,8833,9250,9725,10288,10800,
         11314,11886,12375,12844,13312}};
    if((gasValue>0)&&(pulseValue==0)&&(wireTypeValue==0)&&(wireDValue==4)){
        //MAG D 实芯 1.2
        feedspeed=0;
    }else if((gasValue>0)&&(pulseValue)&&(wireTypeValue==0)&&(wireDValue==4)){
        //MAG P 实芯 1.2
        feedspeed=1;
    }else if((gasValue==0)&&(pulseValue==0)&&(wireTypeValue==0)&&(wireDValue==4)){
        //CO2 D 实芯 1.2
        feedspeed=2;
    }else{
        status="暂不支持当前设置下的送丝速度规划！";
        return -1;
    }
    return FeedSpeedNum[feedspeed][current/10-1];
}

//求解 道面积 存储到pFill开始的内存里
void WeldMath::solveA(float *pFill,FloorCondition *p,int num,float s){
    int j;
    for( j=0;j<num;j++){
        if(num==1)
            *pFill=s;
        else if(j<(num-1))
            *(pFill+j)=s/(num-1+p->k);
        else if(j==(num-1))
            *(pFill+j)=*(pFill+j-1)*p->k;
    }
}
int WeldMath::solveI(FloorCondition *pI, int num,int total){
    if(total==1){
        pI->current=pI->current_middle;
    }else if(num==0){
        pI->current=pI->current_left;
    }else if(num<(total-1)){
        pI->current=pI->current_middle;
    }else if(num==(total-1)){
        pI->current=pI->current_right;
    }else{
        status="电流选择num大于total！";
    }
    return pI->current;
}
//分层
int WeldMath::solveN(float *pH){
    float tempH,tempHav;
    int fillFloor_MaxNum=0;
    int fillFloor_MinNum=0;

    int res=0;

    if(qRound(*pH)<=0){
        fillFloor.num=topFloor.num=secondFloor.num=0;
        bottomFloor.height=grooveHeight+reinforcementValue;
        //调用重新匹配第一层
#if ENABLE_SOLVE_FIRST ==1
        firstFloorFunc();
        res=1;
#endif
    }else if(qRound(*pH)<=topFloor.maxHeight){
        fillFloor.num=secondFloor.num=0;
        topFloor.num=1;
        if(*pH>=topFloor.minHeight){
            topFloor.height=*pH;
        }else{
            topFloor.height=topFloor.minHeight;
            tempH=bottomFloor.height+*pH-topFloor.height;
            if(tempH<bottomFloor.minHeight){
                status="错误，层高分配无法满足要求！";
            }else
                bottomFloor.height=tempH;
            //调用重新匹配第一层
#if ENABLE_SOLVE_FIRST ==1
            firstFloorFunc();
            res=2;
#endif
        }
    }else if(qRound(*pH)<=(secondFloor.maxHeight+topFloor.maxHeight)){
        secondFloor.num=1;
        fillFloor.num=0;
        topFloor.num=1;
        if(*pH>=(secondFloor.minHeight+topFloor.minHeight)){
            topFloor.height=*pH*(topFloor.minHeight+topFloor.maxHeight)/(topFloor.minHeight+topFloor.maxHeight+secondFloor.minHeight+secondFloor.maxHeight);
            secondFloor.height=*pH-topFloor.height;
            if(topFloor.height<topFloor.minHeight){
                topFloor.height=topFloor.minHeight;
                secondFloor.height=*pH-topFloor.height;
            }else if(secondFloor.height<secondFloor.minHeight){
                secondFloor.height=secondFloor.minHeight;
                topFloor.height=*pH-secondFloor.height;
            }
        }else{
            secondFloor.height=secondFloor.minHeight;
            topFloor.height=topFloor.minHeight;
            tempH=grooveHeight+reinforcementValue-secondFloor.height-topFloor.height;
            if(tempH<bottomFloor.minHeight){
                bottomFloor.height= bottomFloor.minHeight;
                status="错误，层高分配无法满足要求！";
            }else{
                bottomFloor.height=tempH;
            }
            //调用重新匹配第一层
#if ENABLE_SOLVE_FIRST ==1
            firstFloorFunc();
            *pH=grooveHeight+reinforcementValue-hUsed;
            secondFloor.height=*pH*(secondFloor.minHeight+secondFloor.maxHeight)/(topFloor.minHeight+topFloor.maxHeight+secondFloor.minHeight+secondFloor.maxHeight);
            topFloor.height=*pH-secondFloor.height;
            if(secondFloor.height<secondFloor.minHeight){
                secondFloor.height=secondFloor.minHeight;
                topFloor.height=*pH-secondFloor.height;
            }else if(topFloor.height<topFloor.minHeight){
                topFloor.height=topFloor.minHeight;
                secondFloor.height=*pH-topFloor.height;
            }
            res=3;
#endif
        }
    }else{
        topFloor.num=secondFloor.num=1;
        fillFloor_MinNum=qCeil((*pH-topFloor.maxHeight-secondFloor.maxHeight)/fillFloor.maxHeight);
        fillFloor_MaxNum=qFloor((*pH-topFloor.minHeight-secondFloor.minHeight)/fillFloor.minHeight);
        if(fillFloor_MinNum<=fillFloor_MaxNum){
            fillFloor.num=fillFloor_MinNum;
            tempHav=*pH/(fillFloor.num+2);
            topFloor.height=secondFloor.height=float(qRound(tempHav*5))/5;
            if((topFloor.height<topFloor.minHeight)||(topFloor.height>topFloor.maxHeight)){
                topFloor.height=topFloor.height<topFloor.minHeight?topFloor.minHeight:topFloor.maxHeight;
                secondFloor.height=float(qRound(((*pH-topFloor.height)/(fillFloor.num+1))*5))/5;
            }
            if((secondFloor.height<secondFloor.minHeight)||(secondFloor.height>secondFloor.maxHeight)){
                secondFloor.height=secondFloor.height<secondFloor.minHeight?secondFloor.minHeight:secondFloor.maxHeight;
                //判断盖面层层高是最小值或最大值不能更改，否则，盖面层和填充层一起计算平均层高。
                if((topFloor.height==topFloor.minHeight)||(topFloor.height==topFloor.maxHeight)){
                    topFloor.height=float(qRound(((*pH-secondFloor.height)/(fillFloor.num+1))*5))/5;
                    topFloor.height=topFloor.height<topFloor.minHeight?topFloor.minHeight:topFloor.height>topFloor.maxHeight?topFloor.maxHeight:topFloor.height;
                }
            }
            fillFloor.height=(*pH-secondFloor.height-topFloor.height)/fillFloor.num;
        }else{
            fillFloor.num=fillFloor_MinNum;
            secondFloor.height=secondFloor.minHeight;
            topFloor.height=topFloor.minHeight;
            fillFloor.height=fillFloor.minHeight;
            tempH=grooveHeight+reinforcementValue-secondFloor.height-topFloor.height-fillFloor.num*fillFloor.height;
            if(tempH<bottomFloor.minHeight){
                bottomFloor.height=bottomFloor.minHeight;
                status="错误，层高分配无法满足要求！";
            }else{
                bottomFloor.height=tempH;
            }
            //调用重新匹配第一层
#if ENABLE_SOLVE_FIRST ==1
            firstFloorFunc();
            *pH=grooveHeight+reinforcementValue-hUsed;
            fillFloor.height=(*pH-secondFloor.height-topFloor.height)/fillFloor.num;
            res=4;
#endif
        }

    }
    qDebug()<<bottomFloor.height<<secondFloor.height<<fillFloor.height<<topFloor.height;
    return res;
}

int WeldMath::reinforcement(){
    return reinforcementValue;
}
void WeldMath::setReinforcement(int value){
    reinforcementValue=value;
}
int WeldMath::meltingCoefficient(){
    return meltingCoefficientValue;
}
void WeldMath::setMeltingCoefficient(int value){
    meltingCoefficientValue=value;
}

QStringList WeldMath::weldRules(){
    QString s="weld,rules";
    return s.split(",");
}

void WeldMath::setWeldRules(QStringList value){
    Q_UNUSED(value)

}

QStringList WeldMath::grooveRules(){
    QString s="groove,rules";
    return s.split(",");
}

void WeldMath::setGrooveRules(QStringList value){
    qDebug()<<"WeldMath::setGrooveRules "<<value;
    //数组有效
    if(value.count()){
        grooveHeight=value.at(0).toFloat();
        grooveHeightError=value.at(1).toFloat();
        rootGap=value.at(2).toFloat();
        grooveAngel2=value.at(3).toFloat();
       float temp=value.at(4).toFloat();
        grooveAngel1=-temp;
        qDebug()<<grooveAngel1<<grooveAngel2;
        pulseValue=0;
    }
    value.clear();
    value.append("Clear");
    emit grooveRulesChanged(value);
    //计算排道
    weldMathFunction();
}

int WeldMath::gas(){
    return gasValue;
}

void WeldMath::setGas(int value){
    gasValue=value;
}

int WeldMath::pulse(){
    return pulseValue;
}

void WeldMath::setPulse(int value){
    pulseValue=value;
}

int WeldMath::wireType(){
    return wireTypeValue;
}

void WeldMath::setWireType(int value){
    wireTypeValue=value;
}

int WeldMath::wireD(){
    return wireDValue;
}

void WeldMath::setWireD(int value){
    wireDValue=value;
}

QStringList WeldMath::limited(){
    QStringList Here;
    Here<<"WeldMath"<<"limited"<<"return";
    return Here;
}
void WeldMath::setLimited(QStringList value){
    qDebug()<<"WeldMath::setLimited value "<<value;
    //底层限制条件 选取电流中间侧
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
    bottomFloor.fillCoefficient=0.9;
    bottomFloor.current=bottomFloor.current_left;
    //第二层限制条件
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
    secondFloor.fillCoefficient=0.9;
    secondFloor.current=secondFloor.current_left;
    secondFloor.maxWeldSpeed=value.at(SECOND+MAX_SPEED).toFloat();
    secondFloor.minWeldSpeed=value.at(SECOND+MIN_SPEED).toFloat();
    //填充层限制条件
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
    fillFloor.fillCoefficient=1.0;
    fillFloor.current= fillFloor.current_left;
    fillFloor.maxWeldSpeed=value.at(FILL+MAX_SPEED).toFloat();
    fillFloor.minWeldSpeed=value.at(FILL+MIN_SPEED).toFloat();
    //表层限制条件
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
    topFloor.fillCoefficient=1.0;
    topFloor.maxWeldSpeed=value.at(TOP+MAX_SPEED).toFloat();
    topFloor.minWeldSpeed=value.at(TOP+MIN_SPEED).toFloat();
}
