#include "weldmath.h"

//weldMath
WeldMath::WeldMath()
{
    meltingCoefficientValue=105;
    pulseValue=1;
    if(pulseValue){
        //底层限制条件
        bottomFloor.current=100;
        bottomFloor.height=6;
        bottomFloor.k=1.0;
        bottomFloor.maxSwingLength=20;
        bottomFloor.swingLeftLength=1.5;
        bottomFloor.swingRightLength=1.5;
        bottomFloor.swingLeftStayTime=0.5;
        bottomFloor.swingRightStayTime=0.5;
        bottomFloor.totalStayTime=bottomFloor.swingLeftStayTime+bottomFloor.swingRightStayTime;
        bottomFloor.weldSwingSpacing=20;

        //第二层限制条件
        secondFloor.current=110;
        secondFloor.height=6;
        secondFloor.k=1.0;
        secondFloor.maxSwingLength=16;
        secondFloor.swingLeftLength=1.5;
        secondFloor.swingRightLength=1.5;
        secondFloor.swingLeftStayTime=0.6;
        secondFloor.swingRightStayTime=0.6;
        secondFloor.totalStayTime=secondFloor.swingLeftStayTime+secondFloor.swingRightStayTime;
        secondFloor.weldSwingSpacing=3;

        //填充层限制条件
        fillFloor.current=120;
        fillFloor.height=6;
        fillFloor.k=0.95;
        fillFloor.maxSwingLength=16;
        fillFloor.swingLeftLength=2;
        fillFloor.swingRightLength=2;
        fillFloor.swingLeftStayTime=0.5;
        fillFloor.swingRightStayTime=0.5;
        fillFloor.totalStayTime=fillFloor.swingLeftStayTime+fillFloor.swingRightStayTime;
        fillFloor.weldSwingSpacing=3;

        //表层限制条件
        topFloor.current=110;
        topFloor.height=6;
        topFloor.k=1.0;
        topFloor.maxSwingLength=18;
        topFloor.swingLeftLength=1.2;
        topFloor.swingRightLength=1.2;
        topFloor.swingLeftStayTime=0.4;
        topFloor.swingRightStayTime=0.4;
        topFloor.totalStayTime=topFloor.swingLeftStayTime+topFloor.swingRightStayTime;
        topFloor.weldSwingSpacing=3;
    }else{
        bottomFloor.current=140;
        bottomFloor.height=5;
        bottomFloor.k=1.0;
        bottomFloor.maxSwingLength=20;
        bottomFloor.swingLeftLength=1.2;
        bottomFloor.swingRightLength=1.2;
        bottomFloor.swingLeftStayTime=0.5;
        bottomFloor.swingRightStayTime=0.5;
        bottomFloor.totalStayTime=bottomFloor.swingLeftStayTime+bottomFloor.swingRightStayTime;
        bottomFloor.weldSwingSpacing=20;

        secondFloor.current=150;
        secondFloor.height=5;
        secondFloor.k=1.0;
        secondFloor.maxSwingLength=20;
        secondFloor.swingLeftLength=1.2;
        secondFloor.swingRightLength=1.2;
        secondFloor.swingLeftStayTime=0.6;
        secondFloor.swingRightStayTime=0.6;
        secondFloor.totalStayTime=secondFloor.swingLeftStayTime+secondFloor.swingRightStayTime;
        secondFloor.weldSwingSpacing=2;

        //填充层限制条件
        fillFloor.current=150;
        fillFloor.height=5;
        fillFloor.k=0.95;
        fillFloor.maxSwingLength=16;
        fillFloor.swingLeftLength=1.2;
        fillFloor.swingRightLength=1.2;
        fillFloor.swingLeftStayTime=0.5;
        fillFloor.swingRightStayTime=0.5;
        fillFloor.totalStayTime=fillFloor.swingLeftStayTime+fillFloor.swingRightStayTime;
        fillFloor.weldSwingSpacing=2;

        //表层限制条件
        topFloor.current=130;
        topFloor.height=5;
        topFloor.k=1.0;
        topFloor.maxSwingLength=18;
        topFloor.swingLeftLength=1.2;
        topFloor.swingRightLength=1.2;
        topFloor.swingLeftStayTime=0.4;
        topFloor.swingRightStayTime=0.4;
        topFloor.totalStayTime=topFloor.swingLeftStayTime+topFloor.swingRightStayTime;
        topFloor.weldSwingSpacing=2;
    }
    //最大焊接速度
    maxWeldSpeed=250;
    //最小焊接速度
    minWeldSpeed=80;
    //
    p=0;
    //
}

int WeldMath::weldMathFunction(){
    //当前道号
    int currentWeldNum=0;
    QStringList value;
    float current=bottomFloor.current;
    float h=bottomFloor.height;
    //角度变量
    float grooveAngel1Tan=qTan(grooveAngel1*PI/180);
    float grooveAngel2Tan=qTan(grooveAngel2*PI/180);
    //焊丝橫截面积
    float weldWireSquare=(wireDValue==4?1.2*1.2:1.6*1.6)*PI/4;
    //起弧z位置
    float startArcz=0;
    //最大摆动频率
    maxSwingHz=getSwingHz(1,0,bottomFloor.totalStayTime);
    //最小摆动频率
    minSwingHz=getSwingHz(20,0,bottomFloor.totalStayTime);
    //底层最大填充量
    bottomFloor.maxFillMetal=(meltingCoefficientValue*weldWireSquare*
                              getFeedSpeed(bottomFloor.current)*60)/(minWeldSpeed*bottomFloor.totalStayTime
                                                                     *minSwingHz*100);
    //底层最小填充量
    bottomFloor.minFillMetal=(meltingCoefficientValue*weldWireSquare*
                              getFeedSpeed(bottomFloor.current)*60)/(maxWeldSpeed*bottomFloor.totalStayTime
                                                                     *maxSwingHz*100);
    //最大摆动频率
    maxSwingHz=getSwingHz(1,1,secondFloor.totalStayTime);
    //最小摆动频率
    minSwingHz=getSwingHz(20,1,secondFloor.totalStayTime);
    //底层最大填充量
    secondFloor.maxFillMetal=(meltingCoefficientValue*weldWireSquare*
                              getFeedSpeed(secondFloor.current)*60)/(minWeldSpeed*secondFloor.totalStayTime
                                                                     *minSwingHz*100);
    //底层最小填充量
    secondFloor.minFillMetal=(meltingCoefficientValue*weldWireSquare*
                              getFeedSpeed(secondFloor.current)*60)/(maxWeldSpeed*secondFloor.totalStayTime
                                                                     *maxSwingHz*100);
    //最大摆动频率
    maxSwingHz=getSwingHz(1,2,fillFloor.totalStayTime);
    //最小摆动频率
    minSwingHz=getSwingHz(20,2,fillFloor.totalStayTime);
    //填充层最大填充量
    fillFloor.maxFillMetal=(meltingCoefficientValue*weldWireSquare*
                            getFeedSpeed(fillFloor.current)*60)/(minWeldSpeed*fillFloor.totalStayTime
                                                                 *minSwingHz*100);
    //填充层最小填充量
    fillFloor.minFillMetal=(meltingCoefficientValue*weldWireSquare*
                            getFeedSpeed(fillFloor.current)*60)/(maxWeldSpeed*fillFloor.totalStayTime
                                                                 *maxSwingHz*100);
    //最大摆动频率
    maxSwingHz=getSwingHz(1,3,topFloor.totalStayTime);
    //最小摆动频率
    minSwingHz=getSwingHz(20,3,topFloor.totalStayTime);
    //顶层最大填充量
    topFloor.maxFillMetal=(meltingCoefficientValue*weldWireSquare*
                           getFeedSpeed(topFloor.current)*60)/(minWeldSpeed*topFloor.totalStayTime
                                                               *minSwingHz*100);
    //顶层最小填充量
    topFloor.minFillMetal=(meltingCoefficientValue*weldWireSquare*
                           getFeedSpeed(topFloor.current)*60)/(maxWeldSpeed*topFloor.totalStayTime
                                                               *maxSwingHz*100);
    /************************计算打底层*********************************************************/
    //计算填充面积
    float s=((h-p)*(h-p)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap*h)*0.9;
    //打底填充面积不可小于单道最小面积
    while(s<bottomFloor.minFillMetal){
        h+=0.5;
        s=((h-p)*(h-p)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap*h)*0.9;
    }
    //打底层填充面积不可大于单道最大填充面积
    while(s>bottomFloor.maxFillMetal){
        if(h>5)
            h-=1;
        else
            h-=0.5;
        s=((h-p)*(h-p)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap*h)*0.9;
    }
    //求取摆宽宽 摆宽为 填充高度的1/2位置
    float swingLength=qMax(float(0),(h/2-p))*(grooveAngel1Tan+grooveAngel2Tan)+rootGap-bottomFloor.swingLeftLength-bottomFloor.swingRightLength;
    //保留一位整数 小数位为偶数
    float swingLengthOne;
    //计算打底范围
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
    if(weldSpeed>maxWeldSpeed){
        while(weldSpeed>maxWeldSpeed){
            current-=10;
            voltage=getVoltage(current);
            feedSpeed=getFeedSpeed(current);
            weldSpeed=(meltingCoefficientValue*60*weldWireSquare*feedSpeed)/(swingHz*bottomFloor.totalStayTime*s*100);
        }
        weldSpeed=qRound(weldSpeed);
    }else if((s>bottomFloor.maxFillMetal)||(weldSpeed<minWeldSpeed)){
        weldSpeed=qCeil(weldSpeed);
    }else{
        weldSpeed=qRound(weldSpeed);
    }
    //重新计算s
    s=((meltingCoefficientValue*60*weldWireSquare*feedSpeed)/(weldSpeed*swingHz*100*bottomFloor.totalStayTime))/0.9;
    float aa=(grooveAngel1Tan+grooveAngel2Tan)/2;
    float bb=rootGap-p*(grooveAngel1Tan+grooveAngel2Tan);
    float cc=(p*p)*(grooveAngel1Tan+grooveAngel2Tan)/2-s;
    //重新计算h
    h=(qSqrt(bb*bb-4*aa*cc)-bb)/(2*aa);
    //重新计算 摆动范围据坡口左右侧壁的距离 为了精确计算 X偏移
    float reSwingLeftLength= (qMax(float(0),(h/2-p))*(grooveAngel1Tan+grooveAngel2Tan)+rootGap-swingLengthOne)/2;
    //中线偏移
    //float weldLineY=float(qRound(10*h/2))/10;
    float weldLineY=0;
    //中线偏移X 取一位小数
    float weldLineX= float(qRound(10*(reSwingLeftLength+swingLengthOne/2-qMax(float(0),(h/2-p)*grooveAngel1Tan)-rootGap/2)))/10;
    currentWeldNum++;
    //全部参数计算完成
    value.clear();
    value<<QString::number(currentWeldNum)<<"1/1"<<QString::number(current)<<QString::number(voltage)<<QString::number(swingLengthOne/2)
        <<QString::number(swingHz)<<QString::number(weldSpeed/10)<<QString::number(weldLineX)<<QString::number(weldLineY)
       <<QString::number(bottomFloor.swingLeftStayTime)<<QString::number(bottomFloor.swingRightStayTime)<<"1"
      <<QString::number(float(qRound(s*10))/10)<<QString::number(float(qRound(s*10))/10)<<QString::number(weldLineX)<<QString::number(weldLineY)
     <<QString::number(startArcz);
    qDebug()<<value;
    emit weldRulesChanged(value);
    startArcz-=3;
    /**计算第二层***********************************************/
    /**计算中间填充层***********************************************/
    //计算分层数
    int floorNum=qCeil((grooveHeight+reinforcementValue-h-topFloor.height)/fillFloor.height);
    //计算平均层高
    float fillFloorH=(grooveHeight+reinforcementValue-h)/(floorNum+1);
    //胡建文也不清楚怎么回事儿
    fillFloorH=qMin(fillFloor.height,(fillFloorH-qFloor(fillFloorH*2)/2)/floorNum+fillFloorH);
    //计算盖面层高
    float topFloorH=grooveHeight+reinforcementValue-h-fillFloorH*floorNum;
    //判断盖面层高 是否最小
    if(topFloorH>topFloor.height){
        topFloorH=topFloor.height;
        fillFloorH=(grooveHeight+reinforcementValue-h-topFloorH)/floorNum;
    }
    else if(topFloorH<(reinforcementValue+1.6)){
        while(topFloorH<(reinforcementValue+1.5)){
            topFloorH+=0.5;
        }
        fillFloorH=(grooveHeight+reinforcementValue-h-topFloorH)/floorNum;
        if(topFloorH<(reinforcementValue+1.6)){
            topFloorH+=0.5;
            fillFloorH=(grooveHeight+reinforcementValue-h-topFloorH)/floorNum;
            if(fillFloorH<3.5){
                fillFloorH=3.5;
                topFloorH=grooveHeight+reinforcementValue-h-fillFloorH*floorNum;
            }
        }
    }
    //计算第二层层高
    float secondFloorH=0;
    if(fillFloorH<=secondFloor.height){
        secondFloorH=fillFloorH;
    }else{
        secondFloorH=secondFloor.height;
        topFloorH+=fillFloorH-secondFloorH;
        if(topFloorH>topFloor.height){
            topFloorH=topFloor.height;
            fillFloorH=(grooveHeight+reinforcementValue-h-topFloorH-secondFloorH)/(floorNum-1);
            if(fillFloorH>fillFloor.height){
                floorNum+=1;
                fillFloorH=(grooveHeight+reinforcementValue-h-topFloorH-secondFloorH)/(floorNum-1);
                if(fillFloorH<3.5){
                    qDebug()<<"错误分配层高不合适。";
                }
            }
        }
    }
    //循环迭代Y中线
    float weldLineYUesd=float(qRound(10*h))/10;//2*weldLineY;
    //循环迭代层面积
    float sUsed=s;
    //循环迭代层高
    float hUsed=h;
    // 循环迭代出各层参数
    int i,j;
    //每层循环
    for( i=0;i<1;i++){
        h=secondFloorH;
        s=((hUsed+h-p)*(hUsed+h-p)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap*(hUsed+h)-sUsed)*0.9;
        swingLength=(hUsed+h/2-p)*(grooveAngel1Tan+grooveAngel2Tan)+rootGap-secondFloor.swingLeftLength-secondFloor.swingRightLength;
        int weldNum=qCeil((swingLength+secondFloor.weldSwingSpacing)/(secondFloor.maxSwingLength+secondFloor.weldSwingSpacing));
        //获取每一道填充
        float weldFill[weldNum];
        //初始化数组
        for( j=0;j<weldNum;j++){
            if(weldNum==1)
                weldFill[0]=s;
            else if(j<(weldNum-1))
                weldFill[j]=s/(weldNum-1+secondFloor.k);
            else if(j==weldNum-1)
                weldFill[j]=weldFill[j-1]*secondFloor.k;
        }
        //分道后面积过小，减少一条焊道，在一定程度上增大单道摆动宽度
        if(weldFill[0]<secondFloor.minFillMetal){
            if(weldNum>1){
                weldNum-=1;
                for( j=0;j<weldNum;j++){
                    if(weldNum==1)
                        weldFill[0]=s;
                    else if(j<(weldNum-1))
                        weldFill[j]=s/(weldNum-1+secondFloor.k);
                    else if(j==weldNum-1)
                        weldFill[j]=weldFill[j-1]*secondFloor.k;
                }
            }
            //            else //分道过小
            //                return -1;
        }
        swingLengthOne=float(qRound(5*(swingLength-(weldNum-1)*secondFloor.weldSwingSpacing)/weldNum))/5;
        swingHz=getSwingHz(qCeil(swingLengthOne),1,secondFloor.totalStayTime);
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
            weldCurrent[j]=secondFloor.current;
            weldVoltage[j]=getVoltage(weldCurrent[j]);
            weldFeedSpeed[j]=getFeedSpeed(weldCurrent[j]);
            weldTravelSpeed[j]=(meltingCoefficientValue*60*weldWireSquare*weldFeedSpeed[j])/(swingHz*secondFloor.totalStayTime*weldFill[j]*100);
            //保证焊接速度不大于最大焊接速度 否则减小电流
            if(weldTravelSpeed[j]>maxWeldSpeed){
                while(weldTravelSpeed[j]>maxWeldSpeed){
                    weldCurrent[j]-=10;
                    weldVoltage[j]=getVoltage(weldCurrent[j]);
                    weldFeedSpeed[j]=getFeedSpeed(weldCurrent[j]);
                    weldTravelSpeed[j]=(meltingCoefficientValue*60*weldWireSquare*weldFeedSpeed[j])/(swingHz*secondFloor.totalStayTime*weldFill[j]*100);
                }
                weldTravelSpeed[j]=qRound(weldTravelSpeed[j]);
            }else if((weldFill[j]>secondFloor.maxFillMetal)||(weldTravelSpeed[j]<minWeldSpeed)){
                weldTravelSpeed[j]=qCeil(weldTravelSpeed[j]);
            }else{
                weldTravelSpeed[j]=qRound(weldTravelSpeed[j]);
            }
            //重新计算焊道面积
            weldFill[j]=(meltingCoefficientValue*60*weldWireSquare*weldFeedSpeed[j])/(weldTravelSpeed[j]*swingHz*100*secondFloor.totalStayTime)/0.9;
            //重新计算层面积
            s+=weldFill[j];
        }
        float aa=(grooveAngel1Tan+grooveAngel2Tan)/2;
        float bb=rootGap+(hUsed-p)*(grooveAngel1Tan+grooveAngel2Tan);
        float cc=(hUsed-p)*(hUsed-p)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap*hUsed-sUsed-s;
        //重新计算h
        h=(qSqrt(bb*bb-4*aa*cc)-bb)/(2*aa);
        //重新计算
        reSwingLeftLength= ((hUsed+h/2-p)*(grooveAngel1Tan+grooveAngel2Tan)+rootGap-weldNum*swingLengthOne-(weldNum-1)*secondFloor.weldSwingSpacing)/2;
        //中线偏移Y
        float weldLineY=weldLineYUesd ;//+ float(qRound(10*h/2))/10;
        //迭代中线偏移Y
        weldLineYUesd=weldLineY+ float(qRound(10*h))/10;//weldLineY*2-weldLineYUesd;
        //单层内所有道计算完成 依次发送数据
        for(j=0;j<weldNum;j++){
            //焊道数增加
            currentWeldNum++;
            //中线偏移X 取一位小数
            float weldLineX= float(qRound(10*(reSwingLeftLength+swingLengthOne/2+(swingLengthOne+secondFloor.weldSwingSpacing)*(j)-qMax(float(0),(hUsed+h/2-p)*grooveAngel1Tan)-rootGap/2)))/10;
            //全部参数计算完成
            value.clear();
            value<<QString::number(currentWeldNum)<<QString::number(i+2)+"/"+QString::number(j+1)<<QString::number(weldCurrent[j])<<QString::number(weldVoltage[j])<<QString::number(swingLengthOne/2)
                <<QString::number(swingHz)<<QString::number(weldTravelSpeed[j]/10)<<QString::number(weldLineX)<<QString::number(weldLineY)
               <<QString::number(secondFloor.swingLeftStayTime)<<QString::number(secondFloor.swingRightStayTime)<<"1"
              <<QString::number(float(qRound(s*10))/10)<<QString::number(float(qRound(weldFill[j]*10))/10)<<QString::number(weldLineX)<<QString::number(weldLineY) <<QString::number(startArcz);;
            qDebug()<<value;
            emit weldRulesChanged(value);
        }
        //迭代赋值
        sUsed+=s;
        hUsed+=h;
    }
    //每层循环
    for( i=1;i<floorNum;i++){
        h=fillFloorH;
        s=(hUsed+h-p)*(hUsed+h-p)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap*(hUsed+h)-sUsed;
        swingLength=(hUsed+h/2-p)*(grooveAngel1Tan+grooveAngel2Tan)+rootGap-fillFloor.swingLeftLength-fillFloor.swingRightLength;
        int weldNum=qCeil((swingLength+fillFloor.weldSwingSpacing)/(fillFloor.maxSwingLength+fillFloor.weldSwingSpacing));
        //获取每一道填充
        float weldFill[weldNum];
        //初始化数组
        for( j=0;j<weldNum;j++){
            if(weldNum==1)
                weldFill[0]=s;
            else if(j<(weldNum-1))
                weldFill[j]=s/(weldNum-1+fillFloor.k);
            else if(j==weldNum-1)
                weldFill[j]=weldFill[j-1]*fillFloor.k;
        }
        //分道后面积过小，减少一条焊道，在一定程度上增大单道摆动宽度
        if(weldFill[0]<fillFloor.minFillMetal){
            if(weldNum>1){
                weldNum-=1;
                for( j=0;j<weldNum;j++){
                    if(weldNum==1)
                        weldFill[0]=s;
                    else if(j<(weldNum-1))
                        weldFill[j]=s/(weldNum-1+fillFloor.k);
                    else if(j==weldNum-1)
                        weldFill[j]=weldFill[j-1]*fillFloor.k;
                }
            }
            //            else //分道过小
            //                return -1;
        }
        swingLengthOne=float(qRound(5*(swingLength-(weldNum-1)*fillFloor.weldSwingSpacing)/weldNum))/5;
        swingHz=getSwingHz(qCeil(swingLengthOne),1,fillFloor.totalStayTime);
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
        //z轴方向收缩
        startArcz-=3;
        for(j=0;j<weldNum;j++){
            weldCurrent[j]=fillFloor.current;
            weldVoltage[j]=getVoltage(weldCurrent[j]);
            weldFeedSpeed[j]=getFeedSpeed(weldCurrent[j]);
            weldTravelSpeed[j]=(meltingCoefficientValue*60*weldWireSquare*weldFeedSpeed[j])/(swingHz*fillFloor.totalStayTime*weldFill[j]*100);
            //保证焊接速度不大于最大焊接速度 否则减小电流
            if(weldTravelSpeed[j]>maxWeldSpeed){
                while(weldTravelSpeed[j]>maxWeldSpeed){
                    weldCurrent[j]-=10;
                    weldVoltage[j]=getVoltage(weldCurrent[j]);
                    weldFeedSpeed[j]=getFeedSpeed(weldCurrent[j]);
                    weldTravelSpeed[j]=(meltingCoefficientValue*60*weldWireSquare*weldFeedSpeed[j])/(swingHz*fillFloor.totalStayTime*weldFill[j]*100);
                }
                weldTravelSpeed[j]=qRound(weldTravelSpeed[j]);
            }else if((weldFill[j]>fillFloor.maxFillMetal)||(weldTravelSpeed[j]<minWeldSpeed)){
                weldTravelSpeed[j]=qCeil(weldTravelSpeed[j]);
            }else{
                weldTravelSpeed[j]=qRound(weldTravelSpeed[j]);
            }
            //重新计算焊道面积
            weldFill[j]=(meltingCoefficientValue*60*weldWireSquare*weldFeedSpeed[j])/(weldTravelSpeed[j]*swingHz*100*fillFloor.totalStayTime);
            //重新计算层面积
            s+=weldFill[j];
        }
        float aa=(grooveAngel1Tan+grooveAngel2Tan)/2;
        float bb=rootGap+(hUsed-p)*(grooveAngel1Tan+grooveAngel2Tan);
        float cc=(hUsed-p)*(hUsed-p)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap*hUsed-sUsed-s;
        //重新计算h
        h=(qSqrt(bb*bb-4*aa*cc)-bb)/(2*aa);
        //重新计算
        reSwingLeftLength= ((hUsed+h/2-p)*(grooveAngel1Tan+grooveAngel2Tan)+rootGap-weldNum*swingLengthOne-(weldNum-1)*fillFloor.weldSwingSpacing)/2;
        //中线偏移Y
        float weldLineY=weldLineYUesd ;//+ float(qRound(10*h/2))/10;
        //迭代中线偏移Y
        weldLineYUesd=weldLineY+ float(qRound(10*h))/10;//weldLineY*2-weldLineYUesd;
        //单层内所有道计算完成 依次发送数据
        for(j=0;j<weldNum;j++){
            //焊道数增加
            currentWeldNum++;
//            float weldLineY=weldLineYUesd + float(qRound(10*h/2))/10;
//            //迭代中线偏移Y
//            weldLineYUesd=weldLineY*2-weldLineYUesd;
            //中线偏移X 取一位小数
            float weldLineX= float(qRound(10*(reSwingLeftLength+swingLengthOne/2+(swingLengthOne+fillFloor.weldSwingSpacing)*(j)-qMax(float(0),(hUsed+h/2-p)*grooveAngel1Tan)-rootGap/2)))/10;
            //全部参数计算完成
            value.clear();
            value<<QString::number(currentWeldNum)<<QString::number(i+2)+"/"+QString::number(j+1)<<QString::number(weldCurrent[j])<<QString::number(weldVoltage[j])<<QString::number(swingLengthOne/2)
                <<QString::number(swingHz)<<QString::number(weldTravelSpeed[j]/10)<<QString::number(weldLineX)<<QString::number(weldLineY)
               <<QString::number(fillFloor.swingLeftStayTime)<<QString::number(fillFloor.swingRightStayTime)<<"1"
              <<QString::number(float(qRound(s*10))/10)<<QString::number(float(qRound(weldFill[j]*10))/10)<<QString::number(weldLineX)<<QString::number(weldLineY) <<QString::number(startArcz);;
            qDebug()<<value;
            emit weldRulesChanged(value);
        }
        //迭代赋值
        sUsed+=s;
        hUsed+=h;
    }
    /**计算盖面层***********************************************/
    float ba=1.5;
    h=grooveHeight+reinforcementValue-hUsed;

    s=(grooveHeight-p)*(grooveHeight-p)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap*grooveHeight+
            reinforcementValue*(2*(grooveHeight-p)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap+2*ba)/2-sUsed;

    swingLength=(hUsed+h/2-p)*(grooveAngel1Tan+grooveAngel2Tan)+rootGap-topFloor.swingLeftLength-topFloor.swingRightLength;

    int weldNum=qCeil((swingLength+topFloor.weldSwingSpacing)/(topFloor.maxSwingLength+topFloor.weldSwingSpacing));

    //获取每一道填充
    float weldFill[weldNum];
    //初始化数组
    for( j=0;j<weldNum;j++){
        if(weldNum==1)
            weldFill[0]=s;
        else if(j<(weldNum-1))
            weldFill[j]=s/(weldNum-1+topFloor.k);
        else if(j==weldNum-1)
            weldFill[j]=weldFill[j-1]*topFloor.k;

    }
    //分道后面积过小，减少一条焊道，在一定程度上增大单道摆动宽度
    if(weldFill[0]<topFloor.minFillMetal){
        if(weldNum>1){
            weldNum-=1;
            for( j=0;j<weldNum;j++){
                if(weldNum==1)
                    weldFill[0]=s;
                else if(j<(weldNum-1))
                    weldFill[j]=s/(weldNum-1+topFloor.k);
                else if(j==weldNum-1)
                    weldFill[j]=weldFill[j-1]*topFloor.k;
            }
        }
        //        else //分道过小
        //        {
        //            return -1;
        //        }
    }
    swingLengthOne=float(qRound(5*(swingLength-(weldNum-1)*topFloor.weldSwingSpacing)/weldNum))/5;
    swingHz=getSwingHz(qCeil(swingLengthOne),2,topFloor.totalStayTime);
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
        weldCurrent[j]=topFloor.current;
        weldVoltage[j]=getVoltage(weldCurrent[j]);
        weldFeedSpeed[j]=getFeedSpeed(weldCurrent[j]);
        weldTravelSpeed[j]=(meltingCoefficientValue*60*weldWireSquare*weldFeedSpeed[j])/(swingHz*topFloor.totalStayTime*weldFill[j]*100);
        //保证焊接速度不大于最大焊接速度 否则减小电流
        if(weldTravelSpeed[j]>maxWeldSpeed){
            while(weldTravelSpeed[j]>maxWeldSpeed){
                weldCurrent[j]-=10;
                weldVoltage[j]=getVoltage(weldCurrent[j]);
                weldFeedSpeed[j]=getFeedSpeed(weldCurrent[j]);
                weldTravelSpeed[j]=(meltingCoefficientValue*60*weldWireSquare*weldFeedSpeed[j])/(swingHz*topFloor.totalStayTime*weldFill[j]*100);
            }
            weldTravelSpeed[j]=qRound(weldTravelSpeed[j]);
        }else if((weldFill[j]>topFloor.maxFillMetal)||(weldTravelSpeed[j]<minWeldSpeed)){
            weldTravelSpeed[j]=qCeil(weldTravelSpeed[j]);
        }else{
            weldTravelSpeed[j]=qRound(weldTravelSpeed[j]);
        }
        //重新计算焊道面积
        weldFill[j]=(meltingCoefficientValue*60*weldWireSquare*weldFeedSpeed[j])/(weldTravelSpeed[j]*swingHz*100*topFloor.totalStayTime);
        //重新计算层面积
        s+=weldFill[j];
    }
    //    float aa=(grooveAngel1Tan+grooveAngel2Tan)/2;
    //    float bb=rootGap+(hUsed-p)*(grooveAngel1Tan+grooveAngel2Tan);
    //    float cc=(hUsed-p)*(hUsed-p)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap*hUsed-sUsed-s;
    //    //重新计算h
    //    h=(qSqrt(bb*bb-4*aa*cc)-bb)/(2*aa);
    h=grooveHeight-hUsed+2*(s+sUsed-((grooveHeight-p)*(grooveHeight-p)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap*grooveHeight))/(((grooveAngel1Tan+grooveAngel2Tan)*(grooveHeight-p)+rootGap+2*ba));
    //中线偏移Y
    weldLineY=weldLineYUesd ;//+ float(qRound(10*h/2))/10;
    //迭代中线偏移Y
    weldLineYUesd=weldLineY+ float(qRound(10*h))/10;//weldLineY*2-weldLineYUesd;
    //重新计算
    reSwingLeftLength= ((hUsed+h/2-p)*(grooveAngel1Tan+grooveAngel2Tan)+rootGap-weldNum*swingLengthOne-(weldNum-1)*fillFloor.weldSwingSpacing)/2;
    for(j=0;j<weldNum;j++){
        //中线偏移Y
//        float weldLineY=weldLineYUesd + float(qRound(10*h/2))/10;
//        //迭代中线偏移Y
//        weldLineYUesd=weldLineY*2-weldLineYUesd;
        //中线偏移X 取一位小数
        float weldLineX= float(qRound(10*(topFloor.swingLeftLength+swingLengthOne/2+(swingLengthOne+topFloor.weldSwingSpacing)*(j)-qMax(float(0),(hUsed+h/2-p)*grooveAngel1Tan)-rootGap/2)))/10;
        currentWeldNum++;
        //全部参数计算完成
        value.clear();
        value<<QString::number(currentWeldNum)<<QString::number(floorNum+2)+"/"+QString::number(j+1)<<QString::number(weldCurrent[j])<<QString::number(weldVoltage[j])<<QString::number(swingLengthOne/2)
            <<QString::number(swingHz)<<QString::number(weldTravelSpeed[j]/10)<<QString::number(weldLineX)<<QString::number(weldLineY)
           <<QString::number(topFloor.swingLeftStayTime)<<QString::number(topFloor.swingRightStayTime)<<"1"
          <<QString::number(float(qRound(s*10))/10)<<QString::number(float(qRound(weldFill[j]*10))/10)<<QString::number(weldLineX)<<QString::number(weldLineY) <<QString::number(startArcz);;
        qDebug()<<"顶层"<<value;
        emit weldRulesChanged(value);
    }
    value.clear();
    value.append("Finish");
    emit grooveRulesChanged(value);
    return 1;
}

int  WeldMath::getSwingHz(int swing,int floor,float stayTime){
    Q_UNUSED(floor);
    int swingHz=0;
        if(stayTime>=1.1){
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
            qDebug()<<"停留时间不再范围内";
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
            // defalut:voltage=20;break;
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
        return -1;
    }
    return FeedSpeedNum[feedspeed][current/10-1];
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
        grooveAngel1=value.at(3).toFloat();
        grooveAngel2=value.at(4).toFloat();
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





