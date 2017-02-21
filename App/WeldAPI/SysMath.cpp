#include "SysMath.h"

SysMath::SysMath()
{

}

SysMath::~SysMath(){

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
float getFloorHeight(FloorCondition *pF,float leftAngel,float rightAngel,float hused,float sused,float *s,float rootFace,float rootGap){
    if(pF->name=="ceramicBackFloor"){
        //陶瓷衬垫 的面积计算
        *s-=GET_CERAMICBACK_AREA(rootGap,1.5);
    }
    float grooveAngel1Tan=qTan(leftAngel*PI/180);
    float grooveAngel2Tan=qTan(rightAngel*PI/180);
    float aa=(grooveAngel1Tan+grooveAngel2Tan)/2;
    float bb=rootGap+(hused-rootFace)*(grooveAngel1Tan+grooveAngel2Tan);
    float cc=(hused-rootFace)*(hused-rootFace)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap*hused-sused-*s;
    return (qSqrt(bb*bb-4*aa*cc)-bb)/(2*aa);
}
//坐标转换
void getXYPosition(float angel,float *x1,float *y1,float x2,float y2){
    //转换为角度
    if(y2==0){
        *x1=x2/qCos(angel*PI/180);
        *y1=0;
    }else if(x2==0){
        *x1=y2*qSin(angel*PI/180);
        *y1=y2*qCos(angel*PI/180);
    }else if(x2<0){
        float arcTan=qAtan((y2/qAbs(x2)))*180/PI;
        float temp=qSin((arcTan-90+angel)*PI/180);
        *x1=qSqrt(x2*x2+y2*y2)*temp;
        *y1=*x1/qTan((arcTan-90+angel)*PI/180);
    }else{
        float arcTan=qAtan((y2/qAbs(x2)))*180/PI;
        float temp=qCos((arcTan-angel)*PI/180);
        *x1=qSqrt(x2*x2+y2*y2)*temp;
        *y1=*x1*qTan((arcTan-angel)*PI/180);
    }
    *x1=float(qRound(10**x1))/10;
    *y1=float(qRound(10**y1))/10;
    //y1为负值则迁移坐标使y值为正值
    qDebug()<<"angel"<<angel<<"x1"<<*x1<<"*y1"<<*y1<<"x2"<<x2<<"y2"<<y2;
}

float SysMath::getTravelSpeed(FloorCondition *pF,QString str,int *weldCurrent,float *weldVoltage,float *weldFeedSpeed,float *swingSpeed,float *weldTravelSpeed,float *weldFill,QString *status,float swingLengthOne,float *swingHz){
    float temp1;
    int temp;
    //获取电压 为0 则自动生成电压 否则 采用限制条件电压
    if(pF->voltage==0){
        temp1=getVoltage(*weldCurrent);
        if(temp1==-1){*status=str+"焊接电流过小或此焊接条件下焊接电流不存在导致焊接电压不能获取。";return -1;}
        else *weldVoltage=temp1;
    }
    else
        *weldVoltage=pF->voltage;
    //获取送丝速度
    temp=getFeedSpeed(*weldCurrent);
    if(temp==-1){*status=str+"焊接电流过小或此焊接条件下焊接电流不存在导致送丝速度不能获取。";return -1;}
    else *weldFeedSpeed=temp;
    //获取焊速 立焊从此处获取焊速 现有摆速才能求取填充量才能计算 焊接速度
    if(weldStyleName=="立焊"){
        //焊速必须有数 否则无法进入 求摆速函数
        temp=getSwingSpeed(swingLengthOne/2,pF->swingLeftStayTime,pF->swingRightStayTime,100,swingLengthOne>10?WAVE_MAX_VERTICAL_SPEED-60*swingLengthOne+600:WAVE_MAX_VERTICAL_SPEED,swingHz);
        //判断返回数据
        if(temp==-1){
            QString tempStr=*status;
            tempStr.insert(0,str);
            *status=tempStr;
            return -1;
        }
        else
            *swingSpeed= temp;
        *weldTravelSpeed=GET_VERTICAL_TRAVERLSPEED(meltingCoefficientValue,weldWireSquare,*weldFeedSpeed,*weldFill,pF->fillCoefficient,*swingHz,pF->totalStayTime);
    }else
        *weldTravelSpeed=GET_TRAVELSPEED(meltingCoefficientValue,weldWireSquare,*weldFeedSpeed,*weldFill,pF->fillCoefficient);
    if(*weldTravelSpeed<=0) {*status=str+"焊接速度出现负值。";return -1;}
    else
        return 1;

}

int SysMath::getWeldNum(FloorCondition *pF,int *weldCurrent,float *weldVoltage,float *weldFeedSpeed,float *swingSpeed,float *weldTravelSpeed,float *weldFill,float *s,int count,int weldNum,int weldFloor,QString *status,float swingLengthOne){
    int temp;
    float swingHz;
    QString str="计算第"+QString::number(weldFloor)+"层第"+QString::number(weldNum)+"道时，";
    //获取电流
    temp=solveI(pF,count,weldNum);
    if(temp==-1){*status=str+"焊接电流不能正常分配。";return -1;}
    else *weldCurrent=temp;
    if(getTravelSpeed(pF,str,weldCurrent,weldVoltage,weldFeedSpeed,swingSpeed,weldTravelSpeed,weldFill,status,swingLengthOne,&swingHz)==-1) return -1;
    //保证焊接速度不大于最大焊接速度 否则减小电流
    if(*weldTravelSpeed>pF->maxWeldSpeed){
        while(*weldTravelSpeed>pF->maxWeldSpeed){
            *weldCurrent-=10;
            // if(tempCurrent-*weldCurrent>CURRENT_COUNT_DEC) {*status=str+"焊接电流相对预置"}
            //如果带脉冲焊接
            if(*weldCurrent<currentMin){*status=str+"焊接电流超过最小值。";return -1;}
            if(getTravelSpeed(pF,str,weldCurrent,weldVoltage,weldFeedSpeed,swingSpeed,weldTravelSpeed,weldFill,status,swingLengthOne,&swingHz)==-1) return -1;
        }
        *weldTravelSpeed=qRound(*weldTravelSpeed);
    }else if((*weldFill>pF->maxFillMetal)||(*weldTravelSpeed<pF->minWeldSpeed)){
        *weldTravelSpeed=qCeil(*weldTravelSpeed);
    }else{
        *weldTravelSpeed=qRound(*weldTravelSpeed);
    }
    if(*weldTravelSpeed<=0) {*status=str+"焊接速度出现负值。";return -1;}
    //获取摆动速度 非立焊在这里获取摆动速度 因为摆速要受到 焊速制约。
    if(weldStyleName!="立焊"){
        temp=getSwingSpeed(swingLengthOne/2,pF->swingLeftStayTime,pF->swingRightStayTime,*weldTravelSpeed,WAVE_MAX_SPEED,&swingHz);
        //判断返回数据
        if(temp==-1){
            QString tempStr=*status;
            tempStr.insert(0,str);
            *status=tempStr;
            return -1;
        }
        else
            *swingSpeed= temp;
    }
    //重新计算焊道面积 立焊需要单独算焊道
    if(weldStyleName!="立焊")
        *weldFill=GET_WELDFILL_AREA(meltingCoefficientValue,weldWireSquare,*weldFeedSpeed,*weldTravelSpeed,pF->fillCoefficient);
    else
        *weldFill=GET_VERTICAL_WELDFILL_AREA(meltingCoefficientValue,weldWireSquare,*weldFeedSpeed,*weldTravelSpeed,pF->fillCoefficient,swingHz,pF->totalStayTime);
    //重新计算层面积
    *s+=*weldFill;
    return 1;
}

int SysMath::getWeldFloor(FloorCondition *pF,float *hused,float *sused,float *weldLineYUesd,float *startArcZ,int *currentFloor,int *currentWeldNum){
    float s,swingLength,swingLengthOne,reSwingLeftLength;
    int weldNum,i;
    QStringList value;
    //打底层清空
    if((pF->name=="bottomFloor")||(pF->name=="ceramicBackFloor")){
        *currentWeldNum=0;
        *hused=0;
        *sused=0;
        *weldLineYUesd=0;
        *startArcZ=0;
        *currentFloor=1;
        if(grooveHeight<pF->minHeight){
            status="计算第1层时，最小层高限制超过板厚。请检查输入坡口参数！";
            return -1;
        }
    }
    QString str="计算第"+QString::number(*currentFloor)+"层时，";
    float ba=1.5;
    //前面应该对输入参数进行校验 否则不能进入函数
    //计算层面积
    if(pF->name=="topFloor"){
        pF->height=grooveHeight+reinforcementValue-*hused;
        //面积为 坡口剩余面积+余高*（间隙+两侧坡口角度+覆盖坡口外益面积）/2
        s=(grooveHeight-rootFace)*(grooveHeight-rootFace)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap*grooveHeight;
        s-=*sused;
        if(grooveStyleName=="V形坡口")
            s+=reinforcementValue*(2*(grooveHeight-rootFace)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap+2*ba)/2;
        else
            s+=(reinforcementValue)*(2*(grooveHeight-rootFace)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap+ba)/2;
    }else
        s=((*hused+pF->height-rootFace)*(*hused+pF->height-rootFace)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap*(*hused+pF->height)-*sused)*pF->fillCoefficient;
    if(pF->name=="ceramicBackFloor"){
        //陶瓷衬垫 的面积计算
        s+=GET_CERAMICBACK_AREA(rootGap,1.5);
    }
    //计算h/2处摆宽
    swingLength=(*hused+pF->height/2-rootFace)*(grooveAngel1Tan+grooveAngel2Tan)+rootGap;
    //如果摆宽小于两端间隔则 不变
    if(swingLength>(pF->swingLeftLength+pF->swingRightLength))
        swingLength-=pF->swingLeftLength+pF->swingRightLength;
    //计算分多少道  *************此处有问题 应该采用枚举法分道
    weldNum=qCeil((swingLength+pF->weldSwingSpacing)/(pF->maxSwingLength+pF->weldSwingSpacing));
    //创建 weldnum  的数组 必须要加3 否则 数组溢出
    float *weldFill=new float[weldNum];
    //初始化数组
    solveA(weldFill,pF,weldNum,s);
    if(*weldFill>pF->maxFillMetal){
        weldNum+=1;
        //数组发生改变则 相应的也要发生改变 防止数组越界；
        weldFill=array(weldFill,weldNum);
        solveA(weldFill,pF,weldNum,s);
    }
    if(*(weldFill+weldNum-1)<pF->minFillMetal){
        if(weldNum>1){
            weldNum-=1;
            weldFill=array(weldFill,weldNum);
            solveA(weldFill,pF,weldNum,s);
        }else{
            //填充量过小允许调整层高 以最小填充量计算层高
            *weldFill=pF->minFillMetal;
            pF->height=getFloorHeight(pF,grooveAngel1,grooveAngel2,*hused,*sused,weldFill,rootFace,rootGap);
            if(pF->height>=10){
                status=str+"以最小填充量来计算层高，层高超过10mm。";
                return -1;
            }else{
                //重新计算摆宽
                swingLength=(*hused+pF->height/2-rootFace)*(grooveAngel1Tan+grooveAngel2Tan)+rootGap-pF->swingLeftLength-pF->swingRightLength;
            }
        }
    }
    //计算单道摆宽
    swingLengthOne=float(qRound(5*(swingLength-(weldNum-1)*pF->weldSwingSpacing)/weldNum))/5;
    //如果摆宽过小则 不需要摆动
    if((swingLengthOne<=0.5)){
        swingLengthOne=0;
    }
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
            return -1;
        }
    }
    //重新计算层高
    pF->height=getFloorHeight(pF,grooveAngel1,grooveAngel2,*hused,*sused,&s,rootFace,rootGap);
    //重新计算 距离前侧
    reSwingLeftLength= (((*hused+pF->height/2-rootFace)*(grooveAngel1Tan+grooveAngel2Tan)+rootGap-weldNum*swingLengthOne-(weldNum-1)*pF->weldSwingSpacing)*(pF->swingLeftLength))/(pF->swingLeftLength+pF->swingRightLength);
    float *weldLineX=new float[weldNum];
    float *startArcX=new float[weldNum];
    float *startArcY=new float[weldNum];
    float *weldLineY=new float[weldNum];
    //坡口侧从外往内焊  主要针对单边V
    for(i=0;i<weldNum;i++){
        //中线偏移Y
        if(wireTypeValue)
            *(weldLineY+i)=float(qRound(10*(*weldLineYUesd+pF->height/2)))/10;
        else
            *(weldLineY+i)=float(qRound(10*(*weldLineYUesd)))/10;
        //中线偏移X 取一位小数
        *(weldLineX+i)= float(qRound(10*(reSwingLeftLength+swingLengthOne/2+(swingLengthOne+pF->weldSwingSpacing)*(i)-qMax(float(0),(*hused+pF->height/2-rootFace)*grooveAngel1Tan)-rootGap/2)))/10;
        //如果是陶瓷衬垫且为打底层
        if(pF->name=="ceramicBackFloor"){
            //如果在坡口侧
            if(!grooveDirValue){
                //前侧为- 内侧为正
                *(startArcX+i)=rootGap/2+(pF->height/2-rootFace)*grooveAngel2Tan;
            }else{
                *(startArcX+i)=0-rootGap/2-(pF->height/2-rootFace)*grooveAngel1Tan;
            }
            *(startArcX+i)=float(qRound(10**(startArcX+i)))/10;
            *(startArcY+i)=*(weldLineY+i)+qMax(float(0),(pF->height/2-rootFace));
            *(startArcY+i)=float(qRound(10**(startArcY+i)))/10;
        }else{
            *(startArcX+i)=*(weldLineX+i);
            *(startArcY+i)=*(weldLineY+i);
        }
        if(weldStyleName=="水平角焊"){//角焊翻转坐标系  尚未翻转
            getXYPosition(angel,startArcX+i,startArcY+i,*(weldLineX+i),*(weldLineY+i));
            *(weldLineX+i)=*(startArcX+i);
            *(weldLineY+i)=*(startArcY+i);
        }
        if((grooveStyleName=="单边V形坡口")&&(wireTypeValue)){ //提高干伸后同样也要缩枪 药芯有效
            if(!grooveDirValue){//非坡口侧
                *(weldLineX+i)-=pF->height/2*(tan((grooveAngel2/2)*PI/180));
            }else{//坡口侧
                *(weldLineX+i)+=pF->height/2*(tan((grooveAngel1/2)*PI/180));
            }
            *(weldLineX+i)=float(qRound(10*(*(weldLineX+i))))/10;
            *(startArcX+i)=*(weldLineX+i);
        }
    }
    for(i=0;i<weldNum;i++){
        int temp;
        float temp1,temp2;
        //外负内正
        if(weldStyleName!="仰焊")
            temp=!grooveDirValue?i:weldNum-1-i;
        else//仰焊 基数从一侧开始焊偶数从另一侧开始焊
            temp=i%2?grooveDirValue?i/2:weldNum-1-i/2:!grooveDirValue?i/2:weldNum-1-i/2;
        str=i==(weldNum-1)?"永久":"5";
        //焊道数增加
        *currentWeldNum=*currentWeldNum+1;
        temp1=!grooveDirValue?pF->swingRightStayTime:pF->swingLeftStayTime;
        temp2=!grooveDirValue?pF->swingLeftStayTime:pF->swingRightStayTime;

        //全部参数计算完成
        value.clear();
        value<<status<<QString::number(*currentWeldNum)<<QString::number(*currentFloor)+"/"+QString::number(i+1)<<QString::number(*(weldCurrent+i))
            <<QString::number(*(weldVoltage+i))<<QString::number(((weldStyleName=="横焊")||(weldStyleName=="水平角焊"&&((pF->name!="bottomFloor")&&(pF->name!="ceramicBackFloor"))))?0:swingLengthOne/2)
           <<QString::number(*(swingSpeed+i))<<QString::number(*(weldTravelSpeed+i)/10)
          <<QString::number(*(weldLineX+temp))<<QString::number(*(weldLineY+temp))<<QString::number(temp1)<<QString::number(temp2)<<str
         <<QString::number(float(qRound(s*10))/10)<<QString::number(float(qRound(*(weldFill+i)*10))/10)
        << QString::number(*(startArcX+temp))<<QString::number(*(startArcY+temp)) <<QString::number(*startArcZ);
        emit weldRulesChanged(value);
    }
    //迭代中线偏移Y
    *weldLineYUesd+= float(qRound(10*pF->height))/10;
    *hused+=pF->height;
    *sused+=s;
    *startArcZ-=3;
    *currentFloor=*currentFloor+1;
    return 1;
}

int SysMath::getFillMetal(FloorCondition *pF){
    float swingHz=0;
    float weldTravelSpeed=100;
    int temp;
    QString str;
    pF->current=pF->current_middle;
    //获取送丝速度
    int feedSpeed=getFeedSpeed(pF->current);
    if(feedSpeed!=-1){
        if(weldStyleName=="立焊"){
            //求最小摆频 最大摆宽/2
            temp=getSwingSpeed(pF->maxSwingLength/2,pF->swingLeftStayTime,pF->swingRightStayTime,weldTravelSpeed,1000,&swingHz);
            //判断返回数据
            if(temp==-1){
                QString tempStr=status;
                str=((pF->name=="bottomFloor")||(pF->name=="ceramicBackFloor"))?"打底层":pF->name=="secondFloor"?"第二层":pF->name=="fillFloor"?"填充层":"盖面层";
                str+="层计算最大填充量时";
                tempStr.insert(0,str);
                status=tempStr;
                return -1;
            }
            pF->maxFillMetal=GET_VERTICAL_WELDFILL_AREA(meltingCoefficientValue,weldWireSquare,feedSpeed,pF->minWeldSpeed,pF->fillCoefficient,swingHz,pF->totalStayTime);
        }else
            pF->maxFillMetal=GET_WELDFILL_AREA(meltingCoefficientValue,weldWireSquare,feedSpeed,pF->minWeldSpeed,pF->fillCoefficient);
        if(weldStyleName=="立焊"){
            //求最大摆频 最小摆宽/2
            temp=getSwingSpeed(0.5,pF->swingLeftStayTime,pF->swingRightStayTime,weldTravelSpeed,WAVE_MAX_VERTICAL_SPEED,&swingHz);
            //判断返回数据
            if(temp==-1){
                QString tempStr=status;
                str=((pF->name=="bottomFloor")||(pF->name=="ceramicBackFloor"))?"打底层":pF->name=="secondFloor"?"第二层":pF->name=="fillFloor"?"填充层":"盖面层";
                str+="层计算最大填充量时";
                tempStr.insert(0,str);
                status=tempStr;
                return -1;
            }
            pF->minFillMetal=GET_VERTICAL_WELDFILL_AREA(meltingCoefficientValue,weldWireSquare,feedSpeed,pF->maxWeldSpeed,pF->fillCoefficient,swingHz,pF->totalStayTime);
        }else
            pF->minFillMetal=GET_WELDFILL_AREA(meltingCoefficientValue,weldWireSquare,feedSpeed,pF->maxWeldSpeed,pF->fillCoefficient);
    }else{
        status=((pF->name=="bottomFloor")||(pF->name=="ceramicBackFloor"))?"打底层":pF->name=="secondFloor"?"第二层":pF->name=="fillFloor"?"填充层":"盖面层";
        status+="层计算最小填充量时获取送丝速度错误！";
        return -1;
    }
    return 1;
}

int SysMath::weldMath(){
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
    if(secondFloor->name!="secondFloor"){
        status="限制条件不存在,或未赋值。";
        return -1;
    }
    //角度变量
    grooveAngel1Tan=qTan(grooveAngel1*PI/180);
    grooveAngel2Tan=qTan(grooveAngel2*PI/180);
    weldWireSquare=(wireDValue==4?1.2*1.2:1.6*1.6)*PI/4;
    //获取底层 第二层 填充层 盖面层 最大最小填充量限制
    if(weldStyleName=="平焊"){
        if(pulseValue){
            currentMax=300;
            currentMin=50;
        } else{
            currentMax=300;
            currentMin=150;}
    }else if(weldStyleName=="立焊"){
        if(pulseValue){
            currentMax=300;
            currentMin=50;
        }else  if(wireTypeValue==4){//药芯
            currentMax=240;
            currentMin=180;
        }else{
            currentMax=300;
            currentMin=80;}
    }else if(weldStyleName=="横焊"){
        if(pulseValue){
            currentMax=300;
            currentMin=50;
        } else{
            currentMax=300;
            currentMin=80;}
    }
    else
        if(pulseValue){
            currentMax=300;
            currentMin=50;
        } else{
            currentMax=300;
            currentMin=80;}
    if(getFillMetal(bottomFloor)==-1) return -1;
    if(getFillMetal(secondFloor)==-1) return -1;
    if(getFillMetal(fillFloor)==-1) return -1;
    if(getFillMetal(topFloor)==-1) return -1;
    bottomFloor->height=bottomFloor->maxHeight;
    float lastReinforcementValue;
    if(grooveStyleName=="单边V形坡口"){
        lastReinforcementValue=reinforcementValue;
        reinforcementValue=0;
    }
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
    if(grooveStyleName=="单边V形坡口"){
        overFloor->height=overFloor->maxHeight;
        if(getWeldFloor(overFloor,&hUsed,&sUsed,&weldLineYUesd,&startArcZ,&floorNum,&currentWeldNum)==-1){
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
float SysMath::getSwingSpeed(float swing,float swingLeftStayTime,float swingRightStayTime,float weldSpeed,float maxSpeed,float *swingHz){
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
    if((swing<=0)||(weldSpeed<=0)){
        return  0;
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
                t=((t_temp0+t_temp1+t_temp2)*4)/60000;
                *swingHz=1/t;
                qDebug()<<"SysMath::getSwingSpeed::Hz"<<1/(t);
                return GET_WAVE_SPEED(swingSpeed);
            }
        }
        //t_temp2 存在 则证明 匀速存在
        t=((t_temp0+t_temp1+t_temp2)*4)/60000;
        *swingHz=1/t;
        A=t*weldSpeed;
        // qDebug()<<"SysMath::getSwingSpeed::T"<<t<<" t_temp0"<<t_temp0<<" t_temp1"<<t_temp1<<" t_temp2"<<t_temp2;
        qDebug()<<"SysMath::getSwingSpeed::Hz"<<1/(t);
        //qDebug()<<"SysMath::getSwingSpeed::A"<<A;
        if((((A<3.5)&&(swingLeftStayTime!=0)&&(swingRightStayTime!=0))||((A<2.5)&&(swingLeftStayTime==0)&&(swingRightStayTime==0)))&&(weldStyleName!="立焊")){
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

float SysMath::getVoltage(int current){
    float voltage=18;
    if((current>300)&&(current<10))
        return -1;
    if((gasValue)&&(!pulseValue)&&(wireTypeValue==0)&&(wireDValue==4)){
        //MAG D 实芯 1.2
        if (current<=200){
            voltage=14+0.05*current-2;
        }else{
            voltage=14+0.05*current+2;
        }
    }else if((gasValue)&&(pulseValue)&&(wireTypeValue==0)&&(wireDValue==4)){
        //MAG P 实芯 1.2
        if (current<=200){
            if(weldStyleName=="仰焊")
                voltage=14+0.05*current-1.5;
            else
                voltage=14+0.05*current;
        }else{
            voltage=14+0.05*current+2;
        }
    }else if((!gasValue)&&(!pulseValue)&&(wireTypeValue==0)&&(wireDValue==4)){
        //CO2 D 实芯 1.2
        if (current<=200){
            voltage=14+0.05*current-1;
        }
        else
            voltage=14+0.05*current+2;
    }else if((!gasValue)&&(!pulseValue)&&(wireTypeValue==4)&&(wireDValue==4)){
        //CO2 D 药芯 1.2
        if (current<=200){
            voltage=14+0.05*current;
        }
        else
            voltage=14+0.05*current;
    }else {
        return -1;
    }
    return voltage;
}

int SysMath::getFeedSpeed(int current){
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
    if((current>300)||(current<10))
        return -1;
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
void SysMath::solveA(float *pFill,FloorCondition *p,int num,float s){
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
int SysMath::solveI(FloorCondition *pI, int num,int total){
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
int SysMath::solveN(float *pH,float *hused,float *sused,float *weldLineYUesd,float *startArcZ,int *currentFloor,int *currentWeldNum){
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
                return -1;
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
                return -1;
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
        //都应该是一样的四舍五入取整 否则会变成 小的大于大的
        fillFloor_MinNum=qCeil((*pH-topFloor->maxHeight-secondFloor->maxHeight)/fillFloor->maxHeight);
        fillFloor_MaxNum=qFloor((*pH-topFloor->minHeight-secondFloor->minHeight)/fillFloor->minHeight);
        //如果最小层数小于最大层数
        if(fillFloor_MinNum<=fillFloor_MaxNum){
            fillFloor->num=fillFloor_MinNum;
            //以最小层数进行平均 获取最高层及第二层层高
            tempHav=*pH/(fillFloor->num+2);
            topFloor->height=secondFloor->height=float(qRound(tempHav*5))/5;
            //如果顶层层高不再范围内则优先保证顶层层高
            if((topFloor->height<topFloor->minHeight)||(topFloor->height>topFloor->maxHeight)){
                //限制盖面层高 为预置最大或最小层高
                topFloor->height=topFloor->height<topFloor->minHeight?topFloor->minHeight:topFloor->maxHeight;
                //保证盖面层层高的情况下第二层和填充层平均分配层高
                secondFloor->height=float(qRound(((*pH-topFloor->height)/(fillFloor->num+1))*5))/5;
            }
            //如果第二层层高不在范围内
            if((secondFloor->height<secondFloor->minHeight)||(secondFloor->height>secondFloor->maxHeight)){
                //第二层取最大最小层高
                secondFloor->height=secondFloor->height<secondFloor->minHeight?secondFloor->minHeight:secondFloor->maxHeight;
                //判断盖面层层高是最小值或最大值不能更改，否则，盖面层和填充层一起计算平均层高。
                if((topFloor->height!=topFloor->minHeight)&&(topFloor->height!=topFloor->maxHeight)){
                    topFloor->height=float(qRound(((*pH-secondFloor->height)/(fillFloor->num+1))*5))/5;
                    //如果超过最大 则给最大值 如果超过最小则给最小值
                    topFloor->height=topFloor->height<topFloor->minHeight?topFloor->minHeight:topFloor->height>topFloor->maxHeight?topFloor->maxHeight:topFloor->height;
                }
            }
            //将分剩的层高转移给填充层
            fillFloor->height=(*pH-secondFloor->height-topFloor->height)/fillFloor->num;
        }else{
            //
            fillFloor->num=fillFloor_MinNum;
            secondFloor->height=secondFloor->minHeight;
            topFloor->height=topFloor->minHeight;
            fillFloor->height=fillFloor->minHeight;
            tempH=grooveHeight+reinforcementValue-secondFloor->height-topFloor->height-fillFloor->num*fillFloor->height;
            if(tempH<bottomFloor->minHeight){
                bottomFloor->height=bottomFloor->minHeight;
                status="错误，层高分配无法满足要求！";
                return -1;
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
int SysMath::setGrooveRules(QStringList value){
    //数组有效
    if(value.count()){
        if(weldStyleName!="水平角焊"){
            grooveHeight=value.at(0).toFloat();
            grooveHeightError=value.at(1).toFloat();
            rootGap=value.at(2).toFloat();
            grooveAngel2=value.at(3).toFloat();
            float temp=value.at(4).toFloat();
            grooveAngel1=-temp;
        }else{
            grooveHeight=value.at(0).toFloat();
            grooveHeightError=value.at(1).toFloat();
            angel=qAtan(grooveHeight/grooveHeightError)*180/PI;
            grooveHeight*=qCos(angel*PI/180);
            rootGap=0;//value.at(2).toFloat();
            grooveAngel2=value.at(3).toFloat()-angel;
            float temp=value.at(4).toFloat();
            grooveAngel1=-temp+angel;
        }
    }
    value.clear();
    value.append("Clear");
    emit weldRulesChanged(value);
    return weldMath();
}
