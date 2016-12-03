#include "flatmath.h"

#define ENABLE_SOLVE_FIRST                              1
#define CURRENT_COUNT_DEC                            20
#define CURRENT_COUNT_PLUAS                        20
#define CURRENT_MAX                                         300
#define CURRENT_MIN                                         150
#define WAVE_MIN_SPEED                                 1200

flatMath::flatMath()
{

}
flatMath::~flatMath(){

}

float *array(float *oldData,int num){
    int length=sizeof(oldData)/sizeof(oldData[0]);
    if(num>length){
        delete oldData;
        return new float[num];
    }else {
        return oldData;
    }
}

//输入参数解析 hused 已经使用的高度 sused已经使用的面积 s当前层面积 p 顿边 rootGap 根部间隙
float getFloorHeight(FloorCondition *pF,float leftAngel,float rightAngel,float hused,float sused,float s,float p,float rootGap){
    if(pF->name=="ceramicBackFloor"){
        //陶瓷衬垫 的面积计算
        s-=GET_CERAMICBACK_AREA(rootGap,1.5);
    }
    float grooveAngel1Tan=qTan(leftAngel*PI/180);
    float grooveAngel2Tan=qTan(rightAngel*PI/180);
    float aa=(grooveAngel1Tan+grooveAngel2Tan)/2;
    float bb=rootGap+(hused-p)*(grooveAngel1Tan+grooveAngel2Tan);
    float cc=(hused-p)*(hused-p)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap*hused-sused-s;
    return (qSqrt(bb*bb-4*aa*cc)-bb)/(2*aa);
}

int flatMath::getWeldNum(FloorCondition *pF,int *weldCurrent,float *weldVoltage,float *weldFeedSpeed,float *swingSpeed,float *weldTravelSpeed,float *weldFill,float *s,int count,int weldNum,int weldFloor,QString *status,float swingLengthOne){
    int temp;
    //获取电流
    temp=solveI(pF,count,weldNum);
    if(temp==-1){*status="计算第"+QString::number(weldFloor)+"层第"+QString::number(weldNum)+"道时，焊接电流不能正常分配。";return -1;}
    else *weldCurrent=temp;
    //获取电压
    temp=getVoltage(*weldCurrent);
    if(temp==-1){*status="计算第"+QString::number(weldFloor)+"层第"+QString::number(weldNum)+"道时，焊接电流过小或此焊接条件下焊接电流不存在导致焊接电压不能获取。";return -1;}
    else *weldVoltage=temp;
    //获取送丝速度
    temp=getFeedSpeed(*weldCurrent);
    if(temp==-1){*status="计算第"+QString::number(weldFloor)+"层第"+QString::number(weldNum)+"道时，焊接电流过小或此焊接条件下焊接电流不存在导致送丝速度不能获取。";return -1;}
    else *weldFeedSpeed=temp;
    *weldTravelSpeed=(meltingCoefficientValue*weldWireSquare**weldFeedSpeed)/(*weldFill*100);
    if(*weldTravelSpeed<=0) {*status="计算第"+QString::number(weldFloor)+"层第"+QString::number(weldNum)+"道时，焊接速度出现负值。";return -1;}
    //保证焊接速度不大于最大焊接速度 否则减小电流
    if(*weldTravelSpeed>pF->maxWeldSpeed){
        while(*weldTravelSpeed>pF->maxWeldSpeed){
            *weldCurrent-=10;
            if(*weldCurrent<CURRENT_MIN){*status="计算第"+QString::number(weldFloor)+"层第"+QString::number(weldNum)+"道时，焊接电流超过最小值。";return -1;}
            //获取电压
            temp=getVoltage(*weldCurrent);
            if(temp==-1){*status="计算第"+QString::number(weldFloor)+"层第"+QString::number(weldNum)+"道时，焊接电流过小或此焊接条件下焊接电流不存在导致焊接电压不能获取。";return -1;}
            else *weldVoltage=temp;
            //获取送丝速度
            temp=getFeedSpeed(*weldCurrent);
            if(temp==-1){*status="计算第"+QString::number(weldFloor)+"层第"+QString::number(weldNum)+"道时，焊接电流过小或此焊接条件下焊接电流不存在导致送丝速度不能获取。";return -1;}
            else *weldFeedSpeed=temp;
            *weldTravelSpeed=(meltingCoefficientValue*weldWireSquare**weldFeedSpeed)/(*weldFill*100);
            if(*weldTravelSpeed<=0) {*status="计算第"+QString::number(weldFloor)+"层第"+QString::number(weldNum)+"道时，焊接速度出现负值。";return -1;}
        }
        *weldTravelSpeed=qRound(*weldTravelSpeed);
    }else if((*weldFill>pF->maxFillMetal)||(*weldTravelSpeed<pF->minWeldSpeed)){
        *weldTravelSpeed=qCeil(*weldTravelSpeed);
    }else{
        *weldTravelSpeed=qRound(*weldTravelSpeed);
    }
    if(*weldTravelSpeed<=0) {*status="计算第"+QString::number(weldFloor)+"层第"+QString::number(weldNum)+"道时，焊接速度出现负值。";return -1;}
    *swingSpeed= getSwingSpeed(swingLengthOne/2,pF->swingLeftStayTime,pF->swingRightStayTime,*weldTravelSpeed,WAVE_MAX_SPEED);
    //重新计算焊道面积
    *weldFill=(meltingCoefficientValue*weldWireSquare**weldFeedSpeed)/(*weldTravelSpeed*100)/pF->fillCoefficient;
    //重新计算层面积
    *s+=*weldFill;
    return 1;
}

int flatMath::getWeldFloor(FloorCondition *pF,float *hused,float *sused,float *weldLineYUesd,float *startArcZ,int *currentFloor,int *currentWeldNum){
    float s,swingLength,weldLineY,weldLineX,swingLengthOne,reSwingLeftLength,startArcX,startArcY;
    int weldNum,i;
    QString str;
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
    swingLengthOne=float(qRound(swingLength*5))/5;
    //计算分多少道
    weldNum=qCeil((swingLength+pF->weldSwingSpacing)/(pF->maxSwingLength+pF->weldSwingSpacing));
    //创建 weldnum  的数组 必须要加3 否则 数组溢出
    float *weldFill=new float[weldNum];
    //初始化数组
    solveA(weldFill,pF,weldNum,s);
    for(i=0;i<3;i++){
        if(*weldFill>pF->maxFillMetal){
            weldNum+=1;
            //数组发生改变则 相应的也要发生改变 防止数组越界；
            weldFill=array(weldFill,weldNum);
            solveA(weldFill,pF,weldNum,s);
        }else {
            break;
        }
    }
    if(i==3){
        status="计算第"+QString::number(*currentFloor)+"层时,分道超过最大允许填充面积！";
        return -1;
    }
    for(i=0;i<3;i++){
        if(*(weldFill+weldNum-1)<pF->minFillMetal){
            if(weldNum>1){
                weldNum-=1;
                weldFill=array(weldFill,weldNum);
                solveA(weldFill,pF,weldNum,s);
            }else{
                break;
            }
        }else
            break;
    }
    if(i==3){
        status="计算第"+QString::number(*currentFloor)+"层时,分道超过最小允许填充面积！";
        return -1;
    }
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
    pF->height=getFloorHeight(pF,grooveAngel1,grooveAngel2,*hused,*sused,s,p,rootGap);
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
            value<<status<<QString::number(*currentWeldNum)<<QString::number(*currentFloor)+"/"+QString::number(2-i)<<QString::number(*(weldCurrent+i))<<QString::number(*(weldVoltage+i))<<QString::number(swingLengthOne/2)
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
/*
//打底层函数计算
void flatMath::firstFloorFunc(){
    QStringList value;
    h=bottomFloor->height;
    float current=solveI(bottomFloor,0,1);
    //计算填充面积
    float s=((h-p)*(h-p)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap*h)*bottomFloor->fillCoefficient;
    //求取摆宽宽 摆宽为 填充高度的1/2位置
    float swingLength=qMax(float(0),(h/2-p))*(grooveAngel1Tan+grooveAngel2Tan)+rootGap-bottomFloor->swingLeftLength-bottomFloor->swingRightLength;
    //保留一位整数 小数位为偶数
    float swingLengthOne=float(qRound(swingLength*5))/5;
    //计算电压
    float voltage=getVoltage(current);
    //计算送丝速度
    int feedSpeed=getFeedSpeed(current);
    //计算最大焊接速度 溶敷系数*焊丝橫截面积*送丝速度/焊道面积
    float weldSpeed=(meltingCoefficientValue*weldWireSquare*feedSpeed)/(s*100);
    //保证焊接速度不大于最大焊接速度 否则减小电流
    if(weldSpeed>bottomFloor->maxWeldSpeed){
        while(weldSpeed>bottomFloor->maxWeldSpeed){
            current-=10;
            voltage=getVoltage(current);
            feedSpeed=getFeedSpeed(current);
            weldSpeed=(meltingCoefficientValue*weldWireSquare*feedSpeed)/(s*100);
            weldSpeed=qRound(weldSpeed);
            // if()此处尚且存在争议未决。
            if(current==0){
                status="输入条件错误";
                break;
            }
        }
    }else if((s>=bottomFloor->maxFillMetal)||(weldSpeed<bottomFloor->minWeldSpeed)){
        weldSpeed=qCeil(weldSpeed);
    }else{
        weldSpeed=qRound(weldSpeed);
    }
    //重新计算s
    s=((meltingCoefficientValue*weldWireSquare*feedSpeed)/(weldSpeed*100))/bottomFloor->fillCoefficient;
    float swingSpeed= getSwingSpeed(swingLengthOne/2,bottomFloor->swingLeftStayTime,bottomFloor->swingRightStayTime,weldSpeed,WAVE_MAX_SPEED);
    float aa=(grooveAngel1Tan+grooveAngel2Tan)/2;
    float bb=rootGap-p*(grooveAngel1Tan+grooveAngel2Tan);
    float cc=(p*p)*(grooveAngel1Tan+grooveAngel2Tan)/2-s;
    //重新计算h
    h=(qSqrt(bb*bb-4*aa*cc)-bb)/(2*aa);
    //重新计算 摆动范围据坡口左右侧壁的距离 为了精确计算 X偏移
    float reSwingLeftLength= ((qMax(float(0),(h/2-p))*(grooveAngel1Tan+grooveAngel2Tan)+rootGap-swingLengthOne)*(bottomFloor->swingLeftLength))/(bottomFloor->swingLeftLength+bottomFloor->swingRightLength);
    float weldLineY=0;
    weldLineYUesd=float(qRound(10*h))/10;
    //中线偏移X 取一位小数
    float weldLineX= float(qRound(10*(reSwingLeftLength+swingLengthOne/2-qMax(float(0),(h/2-p)*grooveAngel1Tan)-rootGap/2)))/10;
    float startArcX,startArcY;
    if(ceramicBack==1){
        //如果在坡口侧
        if(!grooveDirValue){
            //前侧为- 内侧为正
            startArcX=0-rootGap/2-2*grooveAngel2Tan;
        }else{
            startArcX=rootGap/2+2*grooveAngel1Tan;
        }
        startArcX=float(qRound(10*startArcX))/10;
        startArcY=weldLineY+qMax(float(0),(bottomFloor->height/2-p));
        startArcY=float(qRound(10*startArcY))/10;
    }else{
        startArcX=weldLineX;
        startArcY=weldLineY;
    }
    //循环迭代层面积
    sUsed=s;
    //循环迭代层高
    hUsed=h;
    //全部参数计算完成
    value.clear();
    value<<status<<QString::number(currentWeldNum)<<"1/1"<<QString::number(current)<<QString::number(voltage)<<QString::number(swingLengthOne/2)
        <<QString::number(swingSpeed)<<QString::number(weldSpeed/10)<<QString::number(weldLineX)<<QString::number(weldLineY)
       <<QString::number(bottomFloor->swingLeftStayTime)<<QString::number(bottomFloor->swingRightStayTime)<<"5"
      <<QString::number(float(qRound(s*10))/10)<<QString::number(float(qRound(s*10))/10)<<QString::number(startArcX)<<QString::number(startArcY)
     <<QString::number(startArcZ);
    emit weldRulesChanged(value);
}

//计算第二层
void flatMath::FloorFunc(FloorCondition *pF){
    int i,j,k;
    float s,swingLength,aa,bb,cc,weldLineY,weldLineX,swingLengthOne,reSwingLeftLength;

    int weldNum;
    QStringList value;
    QString str;
    for(i=0;i<pF->num;i++){
        startArcZ-=3;
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
        for(k=0;k<5;k++){
            if(weldFill[0]>pF->maxFillMetal){
                weldNum+=1;
                solveA(&weldFill[0],pF,weldNum,s);
            }else {
                break;
            }
        }
        for(k=0;k<5;k++){
            if(weldFill[weldNum-1]<pF->minFillMetal){
                if(weldNum>1){
                    weldNum-=1;
                    solveA(&weldFill[0],pF,weldNum,s);
                }else{
                    break;
                }
            }
            //else //分道过小
            //return -1;
        }
        swingLengthOne=float(qRound(5*(swingLength-(weldNum-1)*pF->weldSwingSpacing)/weldNum))/5;
        float swingSpeed[weldNum];
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
            weldTravelSpeed[j]=(meltingCoefficientValue*weldWireSquare*weldFeedSpeed[j])/(weldFill[j]*100);
            //保证焊接速度不大于最大焊接速度 否则减小电流
            if(weldTravelSpeed[j]>pF->maxWeldSpeed){
                while(weldTravelSpeed[j]>pF->maxWeldSpeed){
                    weldCurrent[j]-=10;
                    weldVoltage[j]=getVoltage(weldCurrent[j]);
                    weldFeedSpeed[j]=getFeedSpeed(weldCurrent[j]);
                    weldTravelSpeed[j]=(meltingCoefficientValue*weldWireSquare*weldFeedSpeed[j])/(weldFill[j]*100);
                }
                weldTravelSpeed[j]=qRound(weldTravelSpeed[j]);
            }else if((weldFill[j]>pF->maxFillMetal)||(weldTravelSpeed[j]<pF->minWeldSpeed)){
                weldTravelSpeed[j]=qCeil(weldTravelSpeed[j]);
            }else{
                weldTravelSpeed[j]=qRound(weldTravelSpeed[j]);
            }
            swingSpeed[j]= getSwingSpeed(swingLengthOne/2,pF->swingLeftStayTime,pF->swingRightStayTime,weldTravelSpeed[j],WAVE_MAX_SPEED);
            //重新计算焊道面积
            weldFill[j]=(meltingCoefficientValue*weldWireSquare*weldFeedSpeed[j])/(weldTravelSpeed[j]*100)/pF->fillCoefficient;
            //重新计算层面积
            s+=weldFill[j];
        }
        aa=(grooveAngel1Tan+grooveAngel2Tan)/2;
        bb=rootGap+(hUsed-p)*(grooveAngel1Tan+grooveAngel2Tan);
        cc=(hUsed-p)*(hUsed-p)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap*hUsed-sUsed-s;
        //重新计算h
        h=(qSqrt(bb*bb-4*aa*cc)-bb)/(2*aa);
        //重新计算
        reSwingLeftLength= (((hUsed+h/2-p)*(grooveAngel1Tan+grooveAngel2Tan)+rootGap-weldNum*swingLengthOne-(weldNum-1)*pF->weldSwingSpacing)*(pF->swingLeftLength))/(pF->swingLeftLength+pF->swingRightLength);
        //中线偏移Y
        weldLineY=weldLineYUesd ;
        //迭代中线偏移Y
        weldLineYUesd=weldLineY+ float(qRound(10*h))/10;
        //单层内所有道计算完成 依次发送数据
        for(j=0;j<weldNum;j++){
            if(j==(weldNum-1)){
                str="永久";
            }else{
                str="5";
            }
            //焊道数增加
            currentWeldNum++;
            //中线偏移X 取一位小数
            weldLineX= float(qRound(10*(reSwingLeftLength+swingLengthOne/2+(swingLengthOne+pF->weldSwingSpacing)*(j)-qMax(float(0),(hUsed+h/2-p)*grooveAngel1Tan)-rootGap/2)))/10;
            //全部参数计算完成
            value.clear();
            value<<status<<QString::number(currentWeldNum)<<QString::number(floorNum)+"/"+QString::number(j+1)<<QString::number(weldCurrent[j])<<QString::number(weldVoltage[j])<<QString::number(swingLengthOne/2)
                <<QString::number(swingSpeed[j])<<QString::number(weldTravelSpeed[j]/10)<<QString::number(weldLineX)<<QString::number(weldLineY)
               <<QString::number(pF->swingLeftStayTime)<<QString::number(pF->swingRightStayTime)<<str
              <<QString::number(float(qRound(s*10))/10)<<QString::number(float(qRound(weldFill[j]*10))/10)<<QString::number(weldLineX)<<QString::number(weldLineY) <<QString::number(startArcZ);;
            emit weldRulesChanged(value);

        }
        //迭代赋值
        sUsed+=s;
        hUsed+=h;
    }
}
void flatMath::topFloorFunc(){
    int j,k;
    QStringList value;
    float ba=1.5;
    QString str;
    floorNum+=1;
    h=grooveHeight+reinforcementValue-hUsed;

    float s=(grooveHeight-p)*(grooveHeight-p)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap*grooveHeight+
            reinforcementValue*(2*(grooveHeight-p)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap+2*ba)/2-sUsed;

    float swingLength=(hUsed+h/2-p)*(grooveAngel1Tan+grooveAngel2Tan)+rootGap-topFloor->swingLeftLength-topFloor->swingRightLength;

    int weldNum=qCeil((swingLength+topFloor->weldSwingSpacing)/(topFloor->maxSwingLength+topFloor->weldSwingSpacing));

    //获取每一道填充
    float weldFill[weldNum];
    //初始化数组
    solveA(&weldFill[0],topFloor,weldNum,s);
    //分道后面积过小，减少一条焊道，在一定程度上增大单道摆动宽度
    for( k=0;k<5;k++){
        if(weldFill[0]>topFloor->maxFillMetal){
            weldNum+=1;
            solveA(&weldFill[0],topFloor,weldNum,s);
        }else {
            break;
        }
    }
    for(k=0;k<5;k++){
        if(weldFill[weldNum-1]<topFloor->minFillMetal){
            if(weldNum>1){
                weldNum-=1;
                solveA(&weldFill[0],topFloor,weldNum,s);
            }else{
                break;
            }
        }
        //else //分道过小
        //return -1;
    }
    float swingLengthOne=float(qRound(5*(swingLength-(weldNum-1)*topFloor->weldSwingSpacing)/weldNum))/5;
    float swingSpeed[weldNum];
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
    startArcZ-=3;
    for(j=0;j<weldNum;j++){
        weldCurrent[j]=solveI(topFloor,j,weldNum);
        weldVoltage[j]=getVoltage(weldCurrent[j]);
        weldFeedSpeed[j]=getFeedSpeed(weldCurrent[j]);
        weldTravelSpeed[j]=(meltingCoefficientValue*weldWireSquare*weldFeedSpeed[j])/(weldFill[j]*100);
        //保证焊接速度不大于最大焊接速度 否则减小电流
        if(weldTravelSpeed[j]>topFloor->maxWeldSpeed){
            weldTravelSpeed[j]=qRound(weldTravelSpeed[j]);
            while(weldTravelSpeed[j]>topFloor->maxWeldSpeed){
                weldCurrent[j]-=10;
                weldVoltage[j]=getVoltage(weldCurrent[j]);
                weldFeedSpeed[j]=getFeedSpeed(weldCurrent[j]);
                weldTravelSpeed[j]=(meltingCoefficientValue*weldWireSquare*weldFeedSpeed[j])/(weldFill[j]*100);
                weldTravelSpeed[j]=qRound(weldTravelSpeed[j]);
            }
        }else if((weldFill[j]>topFloor->maxFillMetal)||(weldTravelSpeed[j]<topFloor->minWeldSpeed)){
            weldTravelSpeed[j]=qCeil(weldTravelSpeed[j]);
        }else{
            weldTravelSpeed[j]=qRound(weldTravelSpeed[j]);
        }
        swingSpeed[j]= getSwingSpeed(swingLengthOne/2,topFloor->swingLeftStayTime,topFloor->swingRightStayTime,weldTravelSpeed[j],WAVE_MAX_SPEED);
        //重新计算焊道面积
        weldFill[j]=(meltingCoefficientValue*weldWireSquare*weldFeedSpeed[j])/(weldTravelSpeed[j]*100);
        //重新计算层面积
        s+=weldFill[j];
    }
    h=grooveHeight-hUsed+2*(s+sUsed-((grooveHeight-p)*(grooveHeight-p)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap*grooveHeight))/(((grooveAngel1Tan+grooveAngel2Tan)*(grooveHeight-p)+rootGap+2*ba));
    //中线偏移Y
    float  weldLineY=weldLineYUesd ;
    //迭代中线偏移Y
    weldLineYUesd=weldLineY+ float(qRound(10*h))/10;
    //重新计算
    float  reSwingLeftLength= (((hUsed+h/2-p)*(grooveAngel1Tan+grooveAngel2Tan)+rootGap-weldNum*swingLengthOne-(weldNum-1)*topFloor->weldSwingSpacing)*(topFloor->swingLeftLength))/(topFloor->swingLeftLength+topFloor->swingRightLength);
    for(j=0;j<weldNum;j++){
        if(j==(weldNum-1)){
            str="永久";
        }else{
            str="5";
        }
        //中线偏移X 取一位小数
        float weldLineX= float(qRound(10*(reSwingLeftLength+swingLengthOne/2+(swingLengthOne+topFloor->weldSwingSpacing)*(j)-qMax(float(0),(hUsed+h/2-p)*grooveAngel1Tan)-rootGap/2)))/10;
        currentWeldNum++;
        //全部参数计算完成
        value.clear();
        value<<status<<QString::number(currentWeldNum)<<QString::number(floorNum)+"/"+QString::number(j+1)<<QString::number(weldCurrent[j])<<QString::number(weldVoltage[j])<<QString::number(swingLengthOne/2)
            <<QString::number(swingSpeed[j])<<QString::number(weldTravelSpeed[j]/10)<<QString::number(weldLineX)<<QString::number(weldLineY)
           <<QString::number(topFloor->swingLeftStayTime)<<QString::number(topFloor->swingRightStayTime)<<str
          <<QString::number(float(qRound(s*10))/10)<<QString::number(float(qRound(weldFill[j]*10))/10)<<QString::number(weldLineX)<<QString::number(weldLineY) <<QString::number(startArcZ);

        emit weldRulesChanged(value);
    }
}
*/
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
    /************************计算打底层*********************************************************/
    /*float current=solveI(bottomFloor,0,1);
    bottomFloor->height=bottomFloor->maxHeight;
    //计算填充面积
    float s=((bottomFloor->height-p)*(bottomFloor->height-p)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap*bottomFloor->height)*bottomFloor->fillCoefficient;
    //陶瓷衬垫 填充面积要加上 根部间隙*2个的填充量
    if(ceramicBack==1){
        //陶瓷衬垫 的面积计算
        s+=GET_CERAMICBACK_AREA(rootGap,1.5);
    }
    //打底填充面积不可小于单道最小面积
    while(s<bottomFloor->minFillMetal){
        bottomFloor->height+=0.5;
        s=((bottomFloor->height-p)*(bottomFloor->height-p)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap*bottomFloor->height)*bottomFloor->fillCoefficient;
        if(ceramicBack==1){
            //陶瓷衬垫的 面积计算
            s+=GET_CERAMICBACK_AREA(rootGap,1.5);
        }
    }
    //打底层填充面积不可大于单道最大填充面积
    while(s>bottomFloor->maxFillMetal){
        if(bottomFloor->height>5)
            bottomFloor->height-=1;
        else
            bottomFloor->height-=0.5;
        s=((bottomFloor->height-p)*(bottomFloor->height-p)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap*bottomFloor->height)*bottomFloor->fillCoefficient;
        if(ceramicBack==1){
            s+=GET_CERAMICBACK_AREA(rootGap,1.5);
        }
    }
    //求取摆宽宽 摆宽为 填充高度的1/2位置
    float swingLength=qMax(float(0),(bottomFloor->height/2-p))*(grooveAngel1Tan+grooveAngel2Tan)+rootGap-bottomFloor->swingLeftLength-bottomFloor->swingRightLength;
    //保留一位整数 小数位为偶数
    float swingLengthOne;
    swingLengthOne=float(qRound(swingLength*5))/5;
    //计算电压
    float voltage=getVoltage(current);
    //
    if(voltage==-1){
        value<<status;
        emit weldRulesChanged(value);
        return -1;
    }
    //计算送丝速度
    int feedSpeed=getFeedSpeed(current);
    //计算最大焊接速度 溶敷系数*焊丝橫截面积*送丝速度/焊道面积
    float weldSpeed=(meltingCoefficientValue*weldWireSquare*feedSpeed)/(s*100);
    //保证焊接速度不大于最大焊接速度 否则减小电流
    if(weldSpeed>bottomFloor->maxWeldSpeed){
        while(weldSpeed>bottomFloor->maxWeldSpeed){
            current-=10;
            voltage=getVoltage(current);
            feedSpeed=getFeedSpeed(current);
            weldSpeed=(meltingCoefficientValue*weldWireSquare*feedSpeed)/(s*100);
            weldSpeed=qRound(weldSpeed);
        }
    }else if((s>=bottomFloor->maxFillMetal)||(weldSpeed<bottomFloor->minWeldSpeed)){
        weldSpeed=qCeil(weldSpeed);
    }else{
        weldSpeed=qRound(weldSpeed);
    }
    float  swingSpeed= getSwingSpeed(swingLengthOne/2,bottomFloor->swingLeftStayTime,bottomFloor->swingRightStayTime,weldSpeed,WAVE_MAX_SPEED);
    //重新计算s
    s=((meltingCoefficientValue*weldWireSquare*feedSpeed)/(weldSpeed*100))/bottomFloor->fillCoefficient;
    //也得把之前陶瓷衬垫加进去的减掉
    if(ceramicBack==1){
        s-=GET_CERAMICBACK_AREA(rootGap,1.5);
    }
    float aa=(grooveAngel1Tan+grooveAngel2Tan)/2;
    float bb=rootGap-p*(grooveAngel1Tan+grooveAngel2Tan);
    float cc=(p*p)*(grooveAngel1Tan+grooveAngel2Tan)/2-s;
    //重新计算h
    bottomFloor->height=(qSqrt(bb*bb-4*aa*cc)-bb)/(2*aa);
    //重新计算 摆动范围据坡口左侧壁的距离 为了精确计算 X偏移
    float reSwingLeftLength= ((qMax(float(0),(bottomFloor->height/2-p))*(grooveAngel1Tan+grooveAngel2Tan)+rootGap-swingLengthOne)*(bottomFloor->swingLeftLength))/(bottomFloor->swingLeftLength+bottomFloor->swingRightLength);
    float weldLineY=0;
    //中线偏移X 取一位小数
    float weldLineX= float(qRound(10*(reSwingLeftLength+swingLengthOne/2-qMax(float(0),(bottomFloor->height/2-p)*grooveAngel1Tan)-rootGap/2)))/10;

    float startArcX,startArcY;
    //陶瓷衬垫
    if(ceramicBack==1){
        //如果在坡口侧
        if(!grooveDirValue){
            //距离右侧壁距离
            startArcX=0-rootGap/2-2*grooveAngel2Tan;
        }else{
            startArcX=rootGap/2+2*grooveAngel1Tan;
        }
        startArcX=float(qRound(10*startArcX))/10;
        startArcY=weldLineY+qMax(float(0),(bottomFloor->height/2-p));
        startArcY=float(qRound(10*startArcY))/10;
    }else{
        startArcX=weldLineX;
        startArcY=weldLineY;
    }
    currentWeldNum++;
    //循环迭代层面积
    sUsed=s;
    //循环迭代层高
    hUsed=h=bottomFloor->height;
    //循环迭代Y中线
    weldLineYUesd=float(qRound(10*h))/10;
    //全部参数计算完成
    value.clear();
    startArcZ=0;
    value<<status<<QString::number(currentWeldNum)<<"1/1"<<QString::number(current)<<QString::number(voltage)<<QString::number(swingLengthOne/2)
        <<QString::number(swingSpeed)<<QString::number(weldSpeed/10)<<QString::number(weldLineX)<<QString::number(weldLineY)
       <<QString::number(bottomFloor->swingLeftStayTime)<<QString::number(bottomFloor->swingRightStayTime)<<"5"
      <<QString::number(float(qRound(s*10))/10)<<QString::number(float(qRound(s*10))/10)<<QString::number(startArcX)<<QString::number(startArcY)
     <<QString::number(startArcZ);
    emit weldRulesChanged(value);*/
    /**********************************************************************
     * 计算层数
     ************************************************************************/
    bottomFloor->height=bottomFloor->maxHeight;
    if(getWeldFloor(bottomFloor,&hUsed,&sUsed,&weldLineYUesd,&startArcZ,&floorNum,&currentWeldNum)==-1){
        return -1;
    }
    float hre=grooveHeight+reinforcementValue-hUsed;
    int res=solveN(&hre,&hUsed,&sUsed,&weldLineYUesd,&startArcZ,&floorNum,&currentWeldNum);
    if(res==-1) return -1;
    /**计算第二层***********************************************/
    if(secondFloor->num>0){
        // FloorFunc(secondFloor);
    }
    if(fillFloor->num>0){
        // FloorFunc(fillFloor);
    }
    if(topFloor->num>0){
        // topFloorFunc();
    }
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
    //定义总时间
    float t;
    //定义停留时间
    float t_temp0 = ((swingLeftStayTime+swingRightStayTime)*1000)/4;
    //定义加速度时间
    float t_temp1=0;
    //定义匀速时间
    float t_temp2=0;
    //定义摆动速度
    float swingSpeed=0;
    qDebug()<<"swing:"<<swing;
    qDebug()<<"weldSpeed"<<weldSpeed;
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
                status="以最大摆速也达不到最大距离。";
                //超过最大距离也没有达到最大速度退出
                return -1;
            }
        }
        //t_temp2 存在 则证明 匀速存在
        t=((t_temp0+t_temp1+t_temp2)*4)/60000;
        A=t*weldSpeed;
        qDebug()<<"flatMath::getSwingSpeed::T"<<t<<" t_temp0"<<t_temp0<<" t_temp1"<<t_temp1<<" t_temp2"<<t_temp2;
        qDebug()<<"flatMath::getSwingSpeed::Hz"<<1/(t);
        qDebug()<<"flatMath::getSwingSpeed::A"<<A;
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
    }else {
        return -1;
    }
    return voltage;
}

int flatMath::getFeedSpeed(int current){
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
    if((gasValue)&&(!pulseValue)&&(wireTypeValue==0)&&(wireDValue==4)){
        //MAG D 实芯 1.2
        feedspeed=0;
    }else if((gasValue)&&(pulseValue)&&(wireTypeValue==0)&&(wireDValue==4)){
        //MAG P 实芯 1.2
        feedspeed=1;
    }else if((!gasValue)&&(!pulseValue)&&(wireTypeValue==0)&&(wireDValue==4)){
        //CO2 D 实芯 1.2
        feedspeed=2;
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
                if((topFloor->height==topFloor->minHeight)||(topFloor->height==topFloor->maxHeight)){
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
