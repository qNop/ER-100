#include "flatmath.h"

flatMath::flatMath()
{

}
flatMath::~flatMath(){

}

float *arrayFlat(float *oldData,int num){
    int length=sizeof(oldData)/sizeof(oldData[0]);
    if(num>length){
        delete oldData;
        return new float[num];
    }else {
        return oldData;
    }
}

//输入参数解析 hused 已经使用的高度 sused已经使用的面积 s当前层面积 p 顿边 rootGap 根部间隙
float getFlatFloorHeight(FloorCondition *pF,float leftAngel,float rightAngel,float hused,float sused,float *s,float p,float rootGap){
    if(pF->name=="ceramicBackFloor"){
        //陶瓷衬垫 的面积计算
        *s-=GET_CERAMICBACK_AREA(rootGap,1.5);
    }
    float grooveAngel1Tan=qTan(leftAngel*PI/180);
    float grooveAngel2Tan=qTan(rightAngel*PI/180);
    float aa=(grooveAngel1Tan+grooveAngel2Tan)/2;
    float bb=rootGap+(hused-p)*(grooveAngel1Tan+grooveAngel2Tan);
    float cc=(hused-p)*(hused-p)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap*hused-sused-*s;
    return (qSqrt(bb*bb-4*aa*cc)-bb)/(2*aa);
}

int flatMath::getWeldNum(FloorCondition *pF,int *weldCurrent,float *weldVoltage,float *weldFeedSpeed,float *swingSpeed,float *weldTravelSpeed,float *weldFill,float *s,int count,int weldNum,int weldFloor,QString *status,float swingLengthOne){
    int temp;
    QString str="计算第"+QString::number(weldFloor)+"层第"+QString::number(weldNum)+"道时，";
    //获取电流
    temp=solveI(pF,count,weldNum);
    if(temp==-1){*status=str+"焊接电流不能正常分配。";return -1;}
    else *weldCurrent=temp;
    //获取电压
    temp=getVoltage(*weldCurrent);
    if(temp==-1){*status=str+"焊接电流过小或此焊接条件下焊接电流不存在导致焊接电压不能获取。";return -1;}
    else *weldVoltage=temp;
    //获取送丝速度
    temp=getFeedSpeed(*weldCurrent);
    if(temp==-1){*status=str+"焊接电流过小或此焊接条件下焊接电流不存在导致送丝速度不能获取。";return -1;}
    else *weldFeedSpeed=temp;
    *weldTravelSpeed=GET_TRAVELSPEED(meltingCoefficientValue,weldWireSquare,*weldFeedSpeed,*weldFill);//(meltingCoefficientValue*weldWireSquare**weldFeedSpeed)/(*weldFill*100);
    if(*weldTravelSpeed<=0) {*status=str+"焊接速度出现负值。";return -1;}
    //保证焊接速度不大于最大焊接速度 否则减小电流
    if(*weldTravelSpeed>pF->maxWeldSpeed){
        while(*weldTravelSpeed>pF->maxWeldSpeed){
            *weldCurrent-=10;
            if(*weldCurrent<CURRENT_MIN){*status=str+"焊接电流超过最小值。";return -1;}
            //获取电压
            temp=getVoltage(*weldCurrent);
            if(temp==-1){*status=str+"焊接电流过小或此焊接条件下焊接电流不存在导致焊接电压不能获取。";return -1;}
            else *weldVoltage=temp;
            //获取送丝速度
            temp=getFeedSpeed(*weldCurrent);
            if(temp==-1){*status=str+"焊接电流过小或此焊接条件下焊接电流不存在导致送丝速度不能获取。";return -1;}
            else *weldFeedSpeed=temp;
            *weldTravelSpeed=GET_TRAVELSPEED(meltingCoefficientValue,weldWireSquare,*weldFeedSpeed,*weldFill);//(meltingCoefficientValue*weldWireSquare**weldFeedSpeed)/(*weldFill*100);
            if(*weldTravelSpeed<=0) {*status=str+"焊接速度出现负值。";return -1;}
        }
        *weldTravelSpeed=qRound(*weldTravelSpeed);
    }else if((*weldFill>pF->maxFillMetal)||(*weldTravelSpeed<pF->minWeldSpeed)){
        *weldTravelSpeed=qCeil(*weldTravelSpeed);
    }else{
        *weldTravelSpeed=qRound(*weldTravelSpeed);
    }
    if(*weldTravelSpeed<=0) {*status=str+"焊接速度出现负值。";return -1;}

    temp=getSwingSpeed(swingLengthOne/2,pF->swingLeftStayTime,pF->swingRightStayTime,*weldTravelSpeed,WAVE_MAX_SPEED);
    if(temp==-1){
        QString tempStr=*status;
        tempStr.insert(0,str);
        *status=tempStr;
        return -1;
    }
    else
        *swingSpeed= temp;
    //重新计算焊道面积
    *weldFill=GET_WELDFILL_AREA(meltingCoefficientValue,weldWireSquare,*weldFeedSpeed,*weldTravelSpeed,pF->fillCoefficient);//(meltingCoefficientValue*weldWireSquare**weldFeedSpeed)/(*weldTravelSpeed*100)/pF->fillCoefficient;
    //重新计算层面积
    *s+=*weldFill;
    return 1;
}

int flatMath::getWeldFloor(FloorCondition *pF,float *hused,float *sused,float *weldLineYUesd,float *startArcZ,int *currentFloor,int *currentWeldNum){
    float s,swingLength,weldLineY,weldLineX,swingLengthOne,reSwingLeftLength,startArcX,startArcY;
    int weldNum,i;
    QString str="计算第"+QString::number(*currentFloor)+"层时，";
    QStringList value;
    float ba=1.5;
    //前面应该对输入参数进行校验 否则不能进入函数
    //计算层面积
    if(pF->name=="topFloor"){
        pF->height=grooveHeight+reinforcementValue-*hused;
        s=(grooveHeight-p)*(grooveHeight-p)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap*grooveHeight+
                reinforcementValue*(2*(grooveHeight-p)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap+2*ba)/2-*sused;
    }
    else
        s=((*hused+pF->height-p)*(*hused+pF->height-p)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap*(*hused+pF->height)-*sused)*pF->fillCoefficient;
    if(pF->name=="ceramicBackFloor"){
        //陶瓷衬垫 的面积计算
        s+=GET_CERAMICBACK_AREA(rootGap,1.5);
    }
    //计算h/2处摆宽
    swingLength=(*hused+pF->height/2-p)*(grooveAngel1Tan+grooveAngel2Tan)+rootGap-pF->swingLeftLength-pF->swingRightLength;
    //保留一位整数 小数位为偶数
    //swingLengthOne=float(qRound(swingLength*5))/5;
    //计算分多少道
    weldNum=qCeil((swingLength+pF->weldSwingSpacing)/(pF->maxSwingLength+pF->weldSwingSpacing));
    //创建 weldnum  的数组 必须要加3 否则 数组溢出
    float *weldFill=new float[weldNum];
    //初始化数组
    solveA(weldFill,pF,weldNum,s);
    // for(i=0;i<3;i++){
    if(*weldFill>pF->maxFillMetal){
        weldNum+=1;
        //数组发生改变则 相应的也要发生改变 防止数组越界；
        weldFill=arrayFlat(weldFill,weldNum);
        solveA(weldFill,pF,weldNum,s);
    }//else {
    //       break;
    //    }
    // }
    // if(i==3){
    //    status=str+"分道超过最大允许填充面积！";
    //    return -1;
    // }
    //for(i=0;i<3;i++){
    if(*(weldFill+weldNum-1)<pF->minFillMetal){
        if(weldNum>1){
            weldNum-=1;
            weldFill=arrayFlat(weldFill,weldNum);
            solveA(weldFill,pF,weldNum,s);
        }}//else{
    //  break;
    // }
    //   }else
    //        break;
    //    }
    //   if(i==3){
    //       status=str+"分道超过最小允许填充面积！";
    //     return -1;
    //  }
    //计算单道摆宽
    swingLengthOne=float(qRound(5*(swingLength-(weldNum-1)*pF->weldSwingSpacing)/weldNum))/5;
    //层内每一道的电流
    int *weldCurrent=new int[weldNum];
    //层内每一道的电压
    float *weldVoltage=new float[weldNum];
    //层内每一道的送丝速度
    float *weldFeedSpeed=new float[weldNum];
    //层内每一道的焊接速度
    float *weldTravelSpeed=new float[weldNum];
    //层内每一道的摆动速度
    float *swingSpeed=new float[weldNum];
    s=0;
    for(i=0;i<weldNum;i++){
        if(getWeldNum(pF,weldCurrent+i,weldVoltage+i,weldFeedSpeed+i,swingSpeed+i,weldTravelSpeed+i,weldFill+i
                      ,&s,i,weldNum,*currentFloor,&status,swingLengthOne)==-1){
            //删除数组数据
            delete weldFill;
            delete weldCurrent;
            delete weldVoltage;
            delete weldFeedSpeed;
            delete weldTravelSpeed;
            delete swingSpeed;
            return -1;
        }
    }
    //重新计算层高
    pF->height=getFlatFloorHeight(pF,grooveAngel1,grooveAngel2,*hused,*sused,&s,p,rootGap);
    //中线偏移Y
    weldLineY=*weldLineYUesd;
    //迭代中线偏移Y
    *weldLineYUesd=weldLineY+ float(qRound(10*pF->height))/10;
    //重新计算 距离前侧
    reSwingLeftLength= (((*hused+pF->height/2-p)*(grooveAngel1Tan+grooveAngel2Tan)+rootGap-weldNum*swingLengthOne-(weldNum-1)*pF->weldSwingSpacing)*(pF->swingLeftLength))/(pF->swingLeftLength+pF->swingRightLength);
    //非坡口侧
    if(((!grooveDirValue)&&(pF->name!="topFloor"))||((grooveDirValue)&&(pF->name=="topFloor"))){
        for(i=0;i<weldNum;i++){
            str=i==(weldNum-1)?"永久":"5";
            //焊道数增加
            *currentWeldNum=*currentWeldNum+1;
            //中线偏移X 取一位小数
            weldLineX= float(qRound(10*(reSwingLeftLength+swingLengthOne/2+(swingLengthOne+pF->weldSwingSpacing)*(i)-qMax(float(0),(*hused+pF->height/2-p)*grooveAngel1Tan)-rootGap/2)))/10;
            //如果是陶瓷衬垫且为打底层
            if(pF->name=="ceramicBackFloor"){
                //如果在坡口侧
                if(!grooveDirValue){
                    //前侧为- 内侧为正
                    startArcX=rootGap/2+(pF->height/2-p)*grooveAngel2Tan;
                }else{
                    startArcX=0-rootGap/2-(pF->height/2-p)*grooveAngel1Tan;
                }
                startArcX=float(qRound(10*startArcX))/10;
                startArcY=weldLineY+qMax(float(0),(pF->height/2-p));
                startArcY=float(qRound(10*startArcY))/10;
            }else{
                startArcX=weldLineX;
                startArcY=weldLineY;
            }
            //全部参数计算完成
            value.clear();
            value<<status<<QString::number(*currentWeldNum)<<QString::number(*currentFloor)+"/"+QString::number(i+1)<<QString::number(*(weldCurrent+i))<<QString::number(*(weldVoltage+i))<<QString::number(swingLengthOne/2)
                <<QString::number(*(swingSpeed+i))<<QString::number(*(weldTravelSpeed+i)/10)<<QString::number(weldLineX)<<QString::number(weldLineY)
               <<QString::number(pF->swingLeftStayTime)<<QString::number(pF->swingRightStayTime)<<str
              <<QString::number(float(qRound(s*10))/10)<<QString::number(float(qRound(*(weldFill+i)*10))/10)<<QString::number(startArcX)<<QString::number(startArcY) <<QString::number(*startArcZ);
            emit weldRulesChanged(value);
        }
    }else{
        for(i=(weldNum-1);i>=0;i--){
            str=i==0?"永久":"5";
            //焊道数增加
            *currentWeldNum=*currentWeldNum+1;
            //中线偏移X 取一位小数
            weldLineX= float(qRound(10*(reSwingLeftLength+swingLengthOne/2+(swingLengthOne+pF->weldSwingSpacing)*(i)-qMax(float(0),(*hused+pF->height/2-p)*grooveAngel1Tan)-rootGap/2)))/10;
            //如果是陶瓷衬垫且为打底层
            if(pF->name=="ceramicBackFloor"){
                //如果在坡口侧
                if(!grooveDirValue){
                    //前侧为- 内侧为正
                    startArcX=rootGap/2+(pF->height/2-p)*grooveAngel2Tan;
                }else{
                    startArcX=0-rootGap/2-(pF->height/2-p)*grooveAngel1Tan;
                }
                startArcX=float(qRound(10*startArcX))/10;
                startArcY=weldLineY+qMax(float(0),(pF->height/2-p));
                startArcY=float(qRound(10*startArcY))/10;
            }else{
                startArcX=weldLineX;
                startArcY=weldLineY;
            }
            //全部参数计算完成
            value.clear();
            value<<status<<QString::number(*currentWeldNum)<<QString::number(*currentFloor)+"/"+QString::number(weldNum-i)<<QString::number(*(weldCurrent+i))<<QString::number(*(weldVoltage+i))<<QString::number(swingLengthOne/2)
                <<QString::number(*(swingSpeed+i))<<QString::number(*(weldTravelSpeed+i)/10)<<QString::number(weldLineX)<<QString::number(weldLineY)
               <<QString::number(pF->swingLeftStayTime)<<QString::number(pF->swingRightStayTime)<<str
              <<QString::number(float(qRound(s*10))/10)<<QString::number(float(qRound(*(weldFill+i)*10))/10)<<QString::number(startArcX)<<QString::number(startArcY) <<QString::number(*startArcZ);
            emit weldRulesChanged(value);
        }
    }
    *hused+=pF->height;
    *sused+=s;
    *startArcZ-=3;
    *currentFloor=*currentFloor+1;
    return 1;
}

int flatMath::getFillMetal(FloorCondition *pF){
    //焊丝橫截面积
    weldWireSquare=(wireDValue==4?1.2*1.2:1.6*1.6)*PI/4;
    if((pF->current_middle+CURRENT_COUNT_PLUAS)>CURRENT_MAX){
        pF->current=CURRENT_MAX;
    }else
        pF->current=pF->current_middle+CURRENT_COUNT_PLUAS;
    //获取送丝速度
    int feedSpeed=getFeedSpeed(pF->current);
    if(feedSpeed!=-1){
        //底层最小填充量  ***是否有问题  最小填充量是否应该用最小电流来计算
        pF->maxFillMetal=(meltingCoefficientValue*weldWireSquare*feedSpeed)/(pF->minWeldSpeed*100);
    }else{
        status=((pF->name=="bottomFloor")||(pF->name=="ceramicBackFloor"))?"打底层":pF->name=="secondFloor"?"第二层":pF->name=="fillFloor"?"填充层":"盖面层";
        status+="计算最大填充量时获取送丝速度错误！";
        return -1;
    }
    if((pF->current_middle-CURRENT_COUNT_DEC)<CURRENT_MIN){
        pF->current=CURRENT_MIN;
    }else
        pF->current=pF->current_middle-CURRENT_COUNT_DEC;
    feedSpeed=getFeedSpeed(pF->current);
    if(feedSpeed!=-1){
        //底层最小填充量  ***是否有问题  最小填充量是否应该用最小电流来计算
        pF->minFillMetal=(meltingCoefficientValue*weldWireSquare*feedSpeed)/(pF->maxWeldSpeed*100);
    }else{
        status=pF->name+"层计算最小填充量时获取送丝速度错误！";
        return -1;
    }
    return 1;
}

int flatMath::weldMath(){
    int i;
    float sUsed=0;
    float hUsed=0;
    int currentWeldNum=0;
    int floorNum=1;
    //起弧z位置 每次都往里面缩进3mm
    float startArcZ=0;
    float weldLineYUesd=0;
    controlWeld=false;
    QStringList value;
    //状态为successed
    status="Successed";
    //角度变量
    grooveAngel1Tan=qTan(grooveAngel1*PI/180);
    grooveAngel2Tan=qTan(grooveAngel2*PI/180);
    //获取底层 第二层 填充层 盖面层 最大最小填充量限制
    if(getFillMetal(bottomFloor)==-1) return -1;
    if(getFillMetal(secondFloor)==-1) return -1;
    if(getFillMetal(fillFloor)==-1) return -1;
    if(getFillMetal(topFloor)==-1) return -1;
    bottomFloor->height=bottomFloor->maxHeight;
    if(getWeldFloor(bottomFloor,&hUsed,&sUsed,&weldLineYUesd,&startArcZ,&floorNum,&currentWeldNum)==-1){
        return -1;
    }
    float hre=grooveHeight+reinforcementValue-hUsed;
    int res=solveN(&hre,&hUsed,&sUsed,&weldLineYUesd,&startArcZ,&floorNum,&currentWeldNum);
    if(res==-1) return -1;
    for(i=0;i<secondFloor->num;i++){
        if(getWeldFloor(secondFloor,&hUsed,&sUsed,&weldLineYUesd,&startArcZ,&floorNum,&currentWeldNum)==-1){
            return -1;
        }
    }
    for(i=0;i<fillFloor->num;i++){
        if(getWeldFloor(fillFloor,&hUsed,&sUsed,&weldLineYUesd,&startArcZ,&floorNum,&currentWeldNum)==-1){
            return -1;
        }
    }
    for(i=0;i<topFloor->num;i++){
        if(getWeldFloor(topFloor,&hUsed,&sUsed,&weldLineYUesd,&startArcZ,&floorNum,&currentWeldNum)==-1){
            return -1;
        }
    }
    value.clear();
    value.append("Finish");
    emit weldRulesChanged(value);
    return 1;
}
/*
 * swing  摆动幅度  pf 当前层条件  weldSpeed 焊接速度
 */
float flatMath::getSwingSpeed(float swing,float swingLeftStayTime,float swingRightStayTime,float weldSpeed,float maxSpeed){
    //定义摆动间隔
    float A;
    //定义总时间  单位分钟
    float t;
    //定义停留时间
    float t_temp0 = ((swingLeftStayTime+swingRightStayTime)*1000)/4;
    //定义加速度时间
    float t_temp1=0;
    //定义匀速时间
    float t_temp2=0;
    //定义摆动速度
    float swingSpeed=0;
    if((swing<=0)||(weldSpeed<=0)){
        status="摆速或者焊接速度为零。";
        return  -1;
    }
    //脉冲叠加数量
    float S_MAX=swing*10*WAVE_CODE_NUM;
    for(;;){
        //定义加速度时间
        t_temp1=0;
        //定义匀速时间
        t_temp2=0;
        //求取到达最大速度的时间及路程
        for(int i=0;;i++){
            swingSpeed=WAVE_SPEED_START_STOP+WAVE_SPEED_ACCE_DECE*i;
            if(swingSpeed>GET_WAVE_PULSE(maxSpeed)){
                t_temp1+=10000/swingSpeed;
                t_temp2=(S_MAX-(i+1)*10)*1000/swingSpeed;
                //加速时间路程
                break;
            }
            t_temp1+=10000/swingSpeed;
            if(((i+1)*10)>S_MAX){
                //超过最大距离也没有达到最大速度退出返回当前速度
                return GET_WAVE_SPEED(swingSpeed);
            }
        }
        //t_temp2 存在 则证明 匀速存在
        t=((t_temp0+t_temp1+t_temp2)*4)/60000;
        A=t*weldSpeed;
        qDebug()<<"flatMath::getSwingSpeed::T"<<t<<" t_temp0"<<t_temp0<<" t_temp1"<<t_temp1<<" t_temp2"<<t_temp2;
        qDebug()<<"flatMath::getSwingSpeed::Hz"<<1/(t);
        //qDebug()<<"flatMath::getSwingSpeed::A"<<A;
        if(((A<3.5)&&(swingLeftStayTime!=0)&&(swingRightStayTime!=0))||((A<2.5)&&(swingLeftStayTime==0)&&(swingRightStayTime==0))){
            maxSpeed-=100;
            //最大值 不能小于1200
            if(maxSpeed<WAVE_MIN_SPEED){
                return GET_WAVE_SPEED(swingSpeed);
            }
        }
        else
            return GET_WAVE_SPEED(swingSpeed);
    }
}

float flatMath::getVoltage(int current){
    float voltage=18;
    if((gasValue)&&(!pulseValue==0)&&(wireTypeValue==0)&&(wireDValue==4)){
        if (current<CURRENT_MIN){
            return -1;
        }else{
            voltage=14+0.05*current;
        }

    }else if((gasValue)&&(pulseValue)&&(wireTypeValue==0)&&(wireDValue==4)){
        if (current<CURRENT_MIN){
            return -1;
        }else{
            voltage=10+0.1*current;
        }
    }else if((!gasValue)&&(!pulseValue)&&(wireTypeValue==0)&&(wireDValue==4)){
        if (current<CURRENT_MIN){
            return -1;
        }
        else
            voltage=14+0.05*current+2;
    }else if((!gasValue)&&(!pulseValue)&&(wireTypeValue==4)&&(wireDValue==4)){
        if (current<CURRENT_MIN){
            return -1;
        }
        else
            voltage=14+0.05*current+2;
    }else {
        return -1;
    }
    return voltage;
}

int flatMath::getFeedSpeed(int current){
    int feedspeed;
    const int FeedSpeedNum[4][35]={
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
         11314,11886,12375,12844,13312},
        {950,1100,1250,1400,1550,1700,2200,2700,3033, 3367,
         3700, 4100, 4500,5300, 5850,6400,6850,7300,7850,8400,
         9200,10000,10650,11300,11900,12500,13750,15000,15750,16500,
         17250,18000,18800,19600,20400} };
    if((gasValue)&&(!pulseValue)&&(wireTypeValue==0)&&(wireDValue==4)){
        //MAG D 实芯 1.2
        feedspeed=0;
    }else if((gasValue)&&(pulseValue)&&(wireTypeValue==0)&&(wireDValue==4)){
        //MAG P 实芯 1.2
        feedspeed=1;
    }else if((!gasValue)&&(!pulseValue)&&(wireTypeValue==0)&&(wireDValue==4)){
        //CO2 D 实芯 1.2
        feedspeed=2;
    }else if((!gasValue)&&(!pulseValue)&&(wireTypeValue==4)&&(wireDValue==4)){
        //CO2 D 药芯 1.2
        feedspeed=3;
    }else{
        return -1;
    }
    return FeedSpeedNum[feedspeed][current/10-1];
}

//求解 道面积 存储到pFill开始的内存里
void flatMath::solveA(float *pFill,FloorCondition *p,int num,float s){
    int j;
    for( j=0;j<num;j++){
        if(num==1)
            *pFill=s;
        else if(j<(num-1)){
            if(j==0){
                if(controlWeld)
                    *(pFill+j)=*(pFill+j-1)*p->k;
                else
                    *(pFill+j)=s/(num-1+p->k);
            }else
                *(pFill+j)=s/(num-1+p->k);
        }
        else if(j==(num-1)){
            if(controlWeld)
                *(pFill+j)=s/(num-1+p->k);
            else
                *(pFill+j)=*(pFill+j-1)*p->k;
        }
    }
}
int flatMath::solveI(FloorCondition *pI, int num,int total){
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
        return -1;
    }
    return pI->current;
}
//分层
int flatMath::solveN(float *pH,float *hused,float *sused,float *weldLineYUesd,float *startArcZ,int *currentFloor,int *currentWeldNum){
    float tempH,tempHav;
    int fillFloor_MaxNum=0;
    int fillFloor_MinNum=0;

    int res=0;

    if(qRound(*pH)<=0){
        fillFloor->num=topFloor->num=secondFloor->num=0;
        bottomFloor->height=grooveHeight+reinforcementValue;
        //调用重新匹配第一层
#if ENABLE_SOLVE_FIRST ==1
        //  firstFloorFunc();
        if(getWeldFloor(bottomFloor,hused,sused,weldLineYUesd,startArcZ,currentFloor,currentWeldNum)==-1){
            return -1;
        }
        res=1;
#endif
    }else if(qRound(*pH)<=topFloor->maxHeight){
        fillFloor->num=secondFloor->num=0;
        topFloor->num=1;
        if(*pH>=topFloor->minHeight){
            topFloor->height=*pH;
        }else{
            topFloor->height=topFloor->minHeight;
            tempH=bottomFloor->height+*pH-topFloor->height;
            if(tempH<bottomFloor->minHeight){
                status="错误，层高分配无法满足要求！";
            }else
                bottomFloor->height=tempH;
            //调用重新匹配第一层
#if ENABLE_SOLVE_FIRST ==1
            //firstFloorFunc();
            if(getWeldFloor(bottomFloor,hused,sused,weldLineYUesd,startArcZ,currentFloor,currentWeldNum)==-1){
                return -1;
            }
            res=2;
#endif
        }
    }else if(qRound(*pH)<=(secondFloor->maxHeight+topFloor->maxHeight)){
        secondFloor->num=1;
        fillFloor->num=0;
        topFloor->num=1;
        if(*pH>=(secondFloor->minHeight+topFloor->minHeight)){
            topFloor->height=*pH*(topFloor->minHeight+topFloor->maxHeight)/(topFloor->minHeight+topFloor->maxHeight+secondFloor->minHeight+secondFloor->maxHeight);
            secondFloor->height=*pH-topFloor->height;
            if(topFloor->height<topFloor->minHeight){
                topFloor->height=topFloor->minHeight;
                secondFloor->height=*pH-topFloor->height;
            }else if(secondFloor->height<secondFloor->minHeight){
                secondFloor->height=secondFloor->minHeight;
                topFloor->height=*pH-secondFloor->height;
            }
        }else{
            secondFloor->height=secondFloor->minHeight;
            topFloor->height=topFloor->minHeight;
            tempH=grooveHeight+reinforcementValue-secondFloor->height-topFloor->height;
            if(tempH<bottomFloor->minHeight){
                bottomFloor->height= bottomFloor->minHeight;
                status="错误，层高分配无法满足要求！";
            }else{
                bottomFloor->height=tempH;
            }
            //调用重新匹配第一层
#if ENABLE_SOLVE_FIRST ==1
            //firstFloorFunc();
            if(getWeldFloor(bottomFloor,hused,sused,weldLineYUesd,startArcZ,currentFloor,currentWeldNum)==-1){
                return -1;
            }
            *pH=grooveHeight+reinforcementValue-*hused;
            secondFloor->height=*pH*(secondFloor->minHeight+secondFloor->maxHeight)/(topFloor->minHeight+topFloor->maxHeight+secondFloor->minHeight+secondFloor->maxHeight);
            topFloor->height=*pH-secondFloor->height;
            if(secondFloor->height<secondFloor->minHeight){
                secondFloor->height=secondFloor->minHeight;
                topFloor->height=*pH-secondFloor->height;
            }else if(topFloor->height<topFloor->minHeight){
                topFloor->height=topFloor->minHeight;
                secondFloor->height=*pH-topFloor->height;
            }
            res=3;
#endif
        }
    }else{
        topFloor->num=secondFloor->num=1;
        fillFloor_MinNum=qCeil((*pH-topFloor->maxHeight-secondFloor->maxHeight)/fillFloor->maxHeight);
        fillFloor_MaxNum=qFloor((*pH-topFloor->minHeight-secondFloor->minHeight)/fillFloor->minHeight);
        if(fillFloor_MinNum<=fillFloor_MaxNum){
            fillFloor->num=fillFloor_MinNum;
            tempHav=*pH/(fillFloor->num+2);
            topFloor->height=secondFloor->height=float(qRound(tempHav*5))/5;
            if((topFloor->height<topFloor->minHeight)||(topFloor->height>topFloor->maxHeight)){
                topFloor->height=topFloor->height<topFloor->minHeight?topFloor->minHeight:topFloor->maxHeight;
                secondFloor->height=float(qRound(((*pH-topFloor->height)/(fillFloor->num+1))*5))/5;
            }
            if((secondFloor->height<secondFloor->minHeight)||(secondFloor->height>secondFloor->maxHeight)){
                secondFloor->height=secondFloor->height<secondFloor->minHeight?secondFloor->minHeight:secondFloor->maxHeight;
                //判断盖面层层高是最小值或最大值不能更改，否则，盖面层和填充层一起计算平均层高。
                if((topFloor->height!=topFloor->minHeight)&&(topFloor->height!=topFloor->maxHeight)){
                    topFloor->height=float(qRound(((*pH-secondFloor->height)/(fillFloor->num+1))*5))/5;
                    topFloor->height=topFloor->height<topFloor->minHeight?topFloor->minHeight:topFloor->height>topFloor->maxHeight?topFloor->maxHeight:topFloor->height;
                }
            }
            fillFloor->height=(*pH-secondFloor->height-topFloor->height)/fillFloor->num;
        }else{
            fillFloor->num=fillFloor_MinNum;
            secondFloor->height=secondFloor->minHeight;
            topFloor->height=topFloor->minHeight;
            fillFloor->height=fillFloor->minHeight;
            tempH=grooveHeight+reinforcementValue-secondFloor->height-topFloor->height-fillFloor->num*fillFloor->height;
            if(tempH<bottomFloor->minHeight){
                bottomFloor->height=bottomFloor->minHeight;
                status="错误，层高分配无法满足要求！";
            }else{
                bottomFloor->height=tempH;
            }
            //调用重新匹配第一层
#if ENABLE_SOLVE_FIRST ==1
            // firstFloorFunc();
            if(getWeldFloor(bottomFloor,hused,sused,weldLineYUesd,startArcZ,currentFloor,currentWeldNum)==-1){
                return -1;
            }
            *pH=grooveHeight+reinforcementValue-*hused;
            fillFloor->height=(*pH-secondFloor->height-topFloor->height)/fillFloor->num;
            res=4;
#endif
        }
    }
    qDebug()<<bottomFloor->height<<secondFloor->height<<fillFloor->height<<topFloor->height;
    return res;
}
int flatMath::setGrooveRules(QStringList value){
    //数组有效
    if(value.count()){
        grooveHeight=value.at(0).toFloat();
        grooveHeightError=value.at(1).toFloat();
        rootGap=value.at(2).toFloat();
        grooveAngel2=value.at(3).toFloat();
        float temp=value.at(4).toFloat();
        grooveAngel1=-temp;
    }
    value.clear();
    value.append("Clear");
    emit weldRulesChanged(value);
    return weldMath();
}