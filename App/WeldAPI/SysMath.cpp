#include "SysMath.h"

SysMath::SysMath()
{

}

SysMath::~SysMath(){

}
/**
 * @brief array  数组长度变换
 * @param oldData  老的数组
 * @param num 新的数组的个数
 * @return
 */
weldDataType *array(weldDataType *oldData,int num){
    int length=sizeof(oldData)/sizeof(oldData[0]);
    if(num>length){
        delete oldData;
        return new weldDataType[num];
    }else {
        return oldData;
    }
}
/**
 * @brief getFloorHeight
 * @param pF
 * @param leftAngel 左侧角度
 * @param rightAngel
 * @param hused1
 * @param sused 已经使用的面积
 * @param s s当前层面积
 * @param rootFace 顿边
 * @param rootGap 根部间隙
 * @return
 */
float getFloorHeight(FloorCondition *pF,float leftAngel,float rightAngel,float hused,float sused,float *s,float rootFace,float rootGap){
    if(pF->name=="ceramicBackFloor"){
        //陶瓷衬垫 的面积计算
        *s-=GET_CERAMICBACK_AREA(rootGap,1.6);
    }
    float grooveAngel1Tan=qTan(leftAngel*PI/180);
    float grooveAngel2Tan=qTan(rightAngel*PI/180);
    float aa=(grooveAngel1Tan+grooveAngel2Tan)/2;
    float bb=rootGap+qMax(float(0),(hused-rootFace)*(grooveAngel1Tan+grooveAngel2Tan));
    float cc=qMax(float(0),(hused-rootFace))*qMax(float(0),(hused-rootFace)*(grooveAngel1Tan+grooveAngel2Tan)/2)+rootGap*hused-sused-*s;
    return (qSqrt(bb*bb-4*aa*cc)-bb)/(2*aa);
}
/**
 * @brief getXYPosition
 * @param angel  角度
 * @param x1    未转换坐标系X坐标
 * @param y1
 * @param x2    目标区域内坐标
 * @param y2
 *
 * s =  os = oa + as = x cos(theta) + y sin(theta)   cos=a/c  sin=b/c tan=b/a  (a/b)*(a/c)=a2/bc (a2+b2)/bc
    t =  ot = ay – ab = y cos(theta) – x sin(theta)
    y=(s-xcos())/sin()
    t= (s-xcos())cos()/sin()-xsin() =s/tan -x(cos()/tan()+sin())
    s/tan-t=x(cos/tan+sin)
    x=(s/tan-t)/(cos/tan+sin)=(s-t*tan)/(cos+sintan)
    x=
 */
void getXY(float angel,float *x1,float *y1,float x2,float y2){
    *x1=x2*qCos(angel*PI/180)-y2*qSin(angel*PI/180);
    *y1=x2*qSin(angel*PI/180)+y2*qCos(angel*PI/180);
    //    *x1=float(qRound(10**x1))/10;
    //    *y1=float(qRound(10**y1))/10;
    qDebug()<<"angel"<<angel<<"x1"<<*x1<<"*y1"<<*y1<<"x2"<<x2<<"y2"<<y2;
}

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
        if(arcTan-90+angel){
            *y1=*x1/qTan((arcTan-90+angel)*PI/180);
        }
    }else{
        float arcTan=qAtan((y2/qAbs(x2)))*180/PI;
        float temp=qCos((arcTan-angel)*PI/180);
        *x1=qSqrt(x2*x2+y2*y2)*temp;
        *y1=*x1*qTan((arcTan-angel)*PI/180);
    }
    //   *x1=float(qRound(10**x1))/10;
    //   *y1=float(qRound(10**y1))/10;
    //y1为负值则迁移坐标使y值为正值
    qDebug()<<"angel"<<angel<<"x1"<<*x1<<"*y1"<<*y1<<"x2"<<x2<<"y2"<<y2;
}

float SysMath::getTravelSpeed(FloorCondition *pF,QString str,weldDataType *pWeldData,QString *status){
    float temp1;
    int temp;
    //获取电压 为0 则自动生成电压 否则 采用限制条件电压
    if(pF->voltage==0){
        temp1=getVoltage((*pWeldData).weldCurrent);
        if(temp1==-1){*status=str+"焊接电流过小或此焊接条件下焊接电流不存在导致焊接电压不能获取。";return -1;}
        else (*pWeldData).weldVoltage=temp1;
    }
    else
        (*pWeldData).weldVoltage=pF->voltage;
    //获取送丝速度
    temp=getFeedSpeed((*pWeldData).weldCurrent);
    if(temp==-1){*status=str+"焊接电流过小或此焊接条件下焊接电流不存在导致送丝速度不能获取。";return -1;}
    else (*pWeldData).weldFeedSpeed=temp;
#ifdef DEBUG_VERTICAL
    //获取焊速 立焊从此处获取焊速 现有摆速才能求取填充量才能计算 焊接速度
    if(weldStyleName=="立焊"){
        //焊速必须有数 否则无法进入 求摆速函数
        temp1=pF->swingLength>6?qMax(1570-31*pF->swingLength,float(600)):WAVE_MAX_VERTICAL_SPEED;
        if(pF->swingLength!=0){//不摆动 的情况算作特例
            temp=getSwingSpeed(pF->swingLength/2,pF->swingLeftStayTime,pF->swingRightStayTime,100,temp1,swingHz);
            //判断返回数据
            if(temp==-1){
                QString tempStr=*status;
                tempStr.insert(0,str);
                *status=tempStr;
                return -1;
            }
            else
                *swingSpeed= temp;
            *weldTravelSpeed=GET_VERTICAL_TRAVERLSPEED(meltingCoefficientValue,weldWireSquare,*weldFeedSpeed,*weldFill,*swingHz,pF->totalStayTime);
        }else{
            *swingSpeed=1000;
            *weldTravelSpeed=GET_TRAVELSPEED(meltingCoefficientValue,weldWireSquare,*weldFeedSpeed,*weldFill);
        }
    }else
        *weldTravelSpeed=GET_TRAVELSPEED(meltingCoefficientValue,weldWireSquare,*weldFeedSpeed,*weldFill);
#else
    (*pWeldData).weldTravelSpeed=GET_TRAVELSPEED(meltingCoefficientValue,weldWireSquare,(*pWeldData).weldFeedSpeed,(*pWeldData).weldFill);
#endif
    if((*pWeldData).weldTravelSpeed<=0) {
        *status=str+"焊接速度出现负值。";return -1;
    }else
        return 1;
}
//优化函数输入参数结构
int SysMath::getWeldNum(FloorCondition *pF,weldDataType *pWeldData,float *s,int currentWeldNum,int weldNum,int weldFloor,QString *status){
    int temp;
    //float swingHz;
    QString str="计算第"+QString::number(weldFloor)+"层第"+QString::number(currentWeldNum+1)+"道时，";
    //获取电流
    temp=solveI(pF,currentWeldNum,weldNum);
    if(temp==-1){*status=str+"焊接电流不能正常分配。";return -1;}
    else (*pWeldData).weldCurrent=temp;
    //计算焊接速度
    if(getTravelSpeed(pF,str,pWeldData,status)==-1) return -1;
    //保证焊接速度不大于最大焊接速度 否则减小电流 5A
    if((*pWeldData).weldTravelSpeed>pF->maxWeldSpeed){
        while((*pWeldData).weldTravelSpeed>pF->maxWeldSpeed){
            (*pWeldData).weldCurrent-=5;
            if((*pWeldData).weldCurrent<=currentMin){*status=str+"焊接电流超过最小值。";return -1;}
            //重新获取行走速度
            if(getTravelSpeed(pF,str,pWeldData,status)==-1) return -1;
        }
    }else if((*pWeldData).weldTravelSpeed<pF->minWeldSpeed){//焊速小于最小速度加电流 5A
        while((*pWeldData).weldTravelSpeed<pF->minWeldSpeed){
            (*pWeldData).weldCurrent+=5;
            if((*pWeldData).weldCurrent>=currentMax){*status=str+"焊接电流超过最大值。";return -1;}
            //重新获取行走速度
            if(getTravelSpeed(pF,str,pWeldData,status)==-1) return -1;
        }
    }
    if((*pWeldData).weldTravelSpeed<=0) {*status=str+"焊接速度出现负值。";return -1;}
    //分道后 两侧停留时间发生位置变化， 靠近破口侧 停留时间大于 中间位置
    if(weldNum<2){//单层单道
        if(grooveStyleName=="单边V形坡口"){
            (*pWeldData).beforeSwingStayTime=!grooveDirValue?pF->swingRightStayTime:pF->swingLeftStayTime; // 非坡口侧:坡口侧
            (*pWeldData).afterSwingStayTime=!grooveDirValue?pF->swingLeftStayTime:pF->swingRightStayTime;    //坡口侧:非坡口侧
        }else{//V形坡口 两边停留时间一致且为坡口侧 停留时间。
            (*pWeldData).beforeSwingStayTime=pF->swingLeftStayTime;// 坡口侧
            (*pWeldData).afterSwingStayTime=pF->swingLeftStayTime;    //坡口侧
        }
    }else{//分道处理
        if(grooveStyleName=="单边V形坡口"){
            (*pWeldData).beforeSwingStayTime=!grooveDirValue?pF->swingRightStayTime:pF->swingLeftStayTime; // 非坡口侧:坡口侧
            (*pWeldData).afterSwingStayTime=!grooveDirValue?pF->swingLeftStayTime:pF->swingRightStayTime;    //坡口侧:非坡口侧
        }else{//V形坡口
            if((currentWeldNum+1)<(weldNum)){//不是最后一道
                (*pWeldData).beforeSwingStayTime=pF->swingLeftStayTime;// 坡口侧
                (*pWeldData).afterSwingStayTime=pF->swingRightStayTime;//非坡口侧
            }else{
                (*pWeldData).beforeSwingStayTime=pF->swingLeftStayTime;//坡口侧
                (*pWeldData).afterSwingStayTime=pF->swingLeftStayTime;    //坡口侧
            }
        }
    }
    //计算摆速
    if(weldStyleName=="立焊"){
        //最大摆速1400  900   6之后 开始衰减 到 30
        // 1400=6*x+Y
        // 900=22*x+Y  ->500=-16X ->X=-31 ->Y=1570
        temp=pF->swingLength>6?qMax(1570-31*pF->swingLength,float(600)):WAVE_MAX_VERTICAL_SPEED;
    }else{
        temp=getSwingSpeed(pWeldData,WAVE_MAX_SPEED);
    }
    //判断返回数据
    if(temp==-1){
        QString tempStr=*status;
        tempStr.insert(0,str);
        *status=tempStr;
        return -1;
    }else{
        (*pWeldData).swingSpeed=temp;
    }
    (*pWeldData).weldFill=GET_WELDFILL_AREA(meltingCoefficientValue,weldWireSquare, (*pWeldData).weldFeedSpeed, (*pWeldData).weldTravelSpeed);
    //重新计算层面积
    (*pWeldData).swingSpeed/=10;
    *s+= (*pWeldData).weldFill;
    return 1;
}

int SysMath::getWeldFloor(FloorCondition *pF,float *hused,float *sused,float *weldLineYUesd,int *currentFloor,int *currentWeldNum){
    float s,swingLength,reSwingRightLength;
    int weldNum,i;
    //打底层清空
    if((pF->name=="bottomFloor")||(pF->name=="ceramicBackFloor")){
        *currentWeldNum=0;
        *hused=0;
        *sused=0;
        *weldLineYUesd=0;
        *currentFloor=1;
        status="Successed";
        if(grooveHeight<pF->minHeight){
            status="计算第1层时，最小层高限制超过板厚。请检查输入坡口参数！";
            return -1;
        }
    }//如果根部间隙大于8则打底层限制条件转换为填充层/第二层条件也转为填充层
    QString str="计算第"+QString::number(*currentFloor)+"层时，";
    float ba=2;
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
            if(weldConnectName=="T接头"){ //T街头要多焊出坡口
                ba=3;
                s+=(reinforcementValue)*(2*(grooveHeight-rootFace)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap+ba);
            }else
                s+=(reinforcementValue)*(2*(grooveHeight-rootFace)*(grooveAngel1Tan+grooveAngel2Tan)/2+rootGap+ba)/2;
    }else{
        //计算面积
        s=(qMax(float(0),(*hused+pF->height-rootFace))*qMax(float(0),(*hused+pF->height-rootFace)*(grooveAngel1Tan+grooveAngel2Tan)/2)+rootGap*(*hused+pF->height)-*sused);
    }
    if(pF->name=="ceramicBackFloor"){
        //陶瓷衬垫 的面积计算
        s+=GET_CERAMICBACK_AREA(rootGap,1.5);
    }
    float tempHeight;
    tempHeight=pF->height/2;
    //计算h/2处摆宽
    swingLength=qMax(float(0),(*hused+tempHeight-rootFace)*(grooveAngel1Tan+grooveAngel2Tan))+rootGap;
    //如果摆宽小于两端间隔则 不摆
    if(swingLength>(pF->swingLeftLength+pF->swingRightLength))
        swingLength-=pF->swingLeftLength+pF->swingRightLength;
    else
        swingLength=0;
    //计算分多少道
    for(weldNum=1;weldNum<100;weldNum++){
        if(swingLength<((pF->weldSwingSpacing)*(weldNum-1)+pF->maxSwingLength*weldNum)){
            // qDebug()<<"pF->weldSwingSpacing"<<pF->weldSwingSpacing<<"pF->maxSwingLength"<<pF->maxSwingLength
            //    <<"swingLength"<<swingLength<<"weldNum"<<weldNum;
            break;
        }
    }
    if(weldNum>100){
        status=str+"焊道数超过100！";
        return -1;
    }
    //焊接参数
    weldDataType *pWeldData=new weldDataType[weldNum];
    //初始化数组
    solveA(pWeldData,pF,weldNum,s);
    //计算单道摆宽0.2 倍数
    pF->swingLength=float(qRound(5*(swingLength-(weldNum-1)*pF->weldSwingSpacing)/weldNum))/5;

    s=0;
    for(i=0;i<weldNum;i++){
        (*(pWeldData+i)).swingLength=pF->swingLength;
        if(getWeldNum(pF,pWeldData+i,&s,i,weldNum,*currentFloor,&status)==-1){
            return -1;
        }
    }
    //没有必要重新计算层高
    // pF->height=getFloorHeight(pF,grooveAngel1,grooveAngel2,*hused,*sused,&s,rootFace,rootGap);
    float *weldLineX=new float[weldNum];
    float *startArcX=new float[weldNum];
    float *startArcY=new float[weldNum];
    float *weldLineY=new float[weldNum];
    float *startWeldLineZ=new float[weldNum];
    float *stopWeldLineZ=new float[weldNum];
    //重新计算 摆幅距离非坡口侧距离
    reSwingRightLength= ((qMax(float(0),(*hused+tempHeight-rootFace)*(grooveAngel1Tan+grooveAngel2Tan))+rootGap-weldNum*pF->swingLength-(weldNum-1)*pF->weldSwingSpacing)*(pF->swingRightLength))/(pF->swingLeftLength+pF->swingRightLength);
    for(i=0;i<weldNum;i++){
        //Y轴偏移 填充量太大则抬枪
        if(pF->height>4)
            *(weldLineY+i)=*weldLineYUesd+tempHeight;
        else
            *(weldLineY+i)=*weldLineYUesd;
        //中线偏移X 取一位小数 已经确定坡口侧非坡口侧
        if(grooveDirValue)//非坡口侧
            *(weldLineX+i)=-((reSwingRightLength+pF->swingLength/2+(pF->swingLength+pF->weldSwingSpacing)*(i)-\
                              qMax(float(0),(*hused+tempHeight-rootFace)*grooveAngel1Tan))-rootGap/2);
        else
            *(weldLineX+i)=((reSwingRightLength+pF->swingLength/2+(pF->swingLength+pF->weldSwingSpacing)*(i)-\
                             qMax(float(0),(*hused+tempHeight-rootFace)*grooveAngel2Tan))-rootGap/2);
        //如果是 横焊对应的
        if(weldStyleName=="横焊"){
            //如果在坡口侧
            if(!grooveDirValue){
                //外为- 内侧为正
                *(startArcX+i)=rootGap/2+qMax(float(0),(pF->height/2-rootFace)*grooveAngel1Tan);
            }else{
                *(startArcX+i)=0-rootGap/2-qMax(float(0),(pF->height/2-rootFace)*grooveAngel2Tan);
            }
            *(startArcY+i)=*(weldLineY+i)+qMax(float(0),(pF->height/2-rootFace));
        }else{
            //从侧边起弧不从中间起弧
            if(i==0){//两侧的从两个侧壁起弧
                if(grooveDirValue)
                    *(startArcX+i)=*(weldLineX+i)-pF->swingLength/2;
                else
                    *(startArcX+i)=*(weldLineX+i)+pF->swingLength/2 ;
            }else if((i+1)==weldNum){
                if(grooveDirValue)
                    *(startArcX+i)=*(weldLineX+i)+pF->swingLength/2;
                else
                    *(startArcX+i)=*(weldLineX+i)-pF->swingLength/2 ;
            }else{
                *(startArcX+i)=*(weldLineX+i);
            }
            *(startArcY+i)=*(weldLineY+i);
        }
        if(weldStyleName=="水平角焊"){//角焊翻转坐标系  尚未翻转
            getXYPosition(angel,startArcX+i,startArcY+i,*(weldLineX+i),*(weldLineY+i));
            *(weldLineX+i)=*(startArcX+i);
            *(weldLineY+i)=*(startArcY+i);
        }else if(weldConnectName=="T接头"){
            getXY(angel,startArcX+i,startArcY+i,grooveDirValue?*(weldLineX+i):-*(weldLineX+i),*(weldLineY+i));
            *(startArcX+i)=grooveDirValue?*(startArcX+i):-*(startArcX+i);
            *(weldLineX+i)=*(startArcX+i);
            *(weldLineY+i)=*(startArcY+i);
        }
        float tempStartWeldLineZ,tempStopWeldLineZ;
        tempStartWeldLineZ=(*currentFloor-1)*startArcZz+i*startArcZx;//当前层偏移+当前道偏移
        tempStopWeldLineZ=*(stopWeldLineZ+i)=weldLength+(*currentFloor-1)*stopArcZz+i*stopArcZx; //焊接长度+当前层外偏移+当前道偏移
        if(returnWay==0){//dan cheng
            *(startWeldLineZ+i)=tempStartWeldLineZ;
            *(stopWeldLineZ+i)=tempStopWeldLineZ;
        }else{
            int t=*currentWeldNum+i;
            if(t%2){
                *(startWeldLineZ+i)=tempStartWeldLineZ;
                *(stopWeldLineZ+i)=tempStopWeldLineZ;
            }else{
                *(startWeldLineZ+i)=tempStopWeldLineZ;
                *(stopWeldLineZ+i)=tempStartWeldLineZ;
            }
        }
        /*if(returnWay==0){//单程
            *(startWeldLineZ+i)=(*currentFloor-1)*startArcZz+i*startArcZx;//当前层偏移+当前道偏移
            *(stopWeldLineZ+i)=weldLength+(*currentFloor-1)*stopArcZz+i*stopArcZx; //焊接长度+当前层外偏移+当前道偏移
        }else{//往返
            if((*currentFloor)%2){ //起弧为收弧 收弧为起弧
                *(startWeldLineZ+i)=(*currentFloor-1)*startArcZz+i*startArcZx;//当前层偏移+当前道偏移
                *(stopWeldLineZ+i)=weldLength+(*currentFloor-1)*stopArcZz+i*stopArcZx; //焊接长度+当前层外偏移+当前道偏移
            }else{ //正常
                *(stopWeldLineZ+i)=(*currentFloor-1)*startArcZz+i*startArcZx;//当前层偏移+当前道偏移
                *(startWeldLineZ+i)=weldLength+(*currentFloor-1)*stopArcZz+i*stopArcZx; //焊接长度+当前层外偏移+当前道偏移
            }
        }*/
    }
    //全算完了之后重新调整 摆宽 摆宽这个时候调整 会影响到摆频的计算
    if(weldConnectName=="T接头"){
        pF->swingLength*=qCos(angel*PI/180);
    }
    //陶瓷衬垫打底摆宽最好不要超过 根部间隙 -2mm否则容易出现底部成型不良
    if((pF->swingLength>(rootGap-2))&&(pF->name=="ceramicBackFloor"))
        pF->swingLength=(rootGap-2)>0?rootGap-2:0;
    for(i=0;i<weldNum;i++){
        int temp;
        //外负内正
        // if(weldStyleName!="仰焊")
        //     temp=!grooveDirValue?i:weldNum-1-i;
        //else//仰焊 基数从一侧开始焊偶数从另一侧开始焊
        //  temp=i%2?grooveDirValue?i/2:weldNum-1-i/2:!grooveDirValue?i/2:weldNum-1-i/2;
        str=i==(weldNum-1)?QString::number(stopOutTime):QString::number(stopInTime);
        //焊道数增加
        *currentWeldNum=*currentWeldNum+1;
        //
        if(weldStyleName=="水平角焊"){
            if(grooveDirValue){ //非坡口测将X值变负值
                temp=i;
                *(weldLineX+i)=-*(weldLineX+i);
                *(startArcX+i)=*(weldLineX+i);
            }else    //坡口侧颠倒Y值
                temp=weldNum-i-1;
        }else if((weldStyleName=="平焊")&&(grooveStyleName=="单边V形坡口")&&(weldConnectName=="T接头")){
            temp=weldNum-1-i;//先焊坡口侧 这样好堆出 角来
        }else{
            temp=i;
        }
        if((*(pWeldData+i)).swingSpeed<=(WAVE_MIN_SPEED/10))//最小摆速 800
            (*(pWeldData+i)).swingSpeed=WAVE_MIN_SPEED/10;
        //计算单道摆宽小于2 则清零
        if(((weldStyleName=="横焊")&&((pF->name!="bottomFloor")&&(pF->name!="ceramicBackFloor")))||(weldStyleName=="水平角焊")||(pF->swingLength<2))
            pF->swingLength=0;
        totalWeldTime+=qAbs(*(stopWeldLineZ+i)-*(startWeldLineZ+i))/((*(pWeldData+i)).weldTravelSpeed);
        //全部参数计算完成
        pJson.insert("ID",QJsonValue(QString::number(*currentWeldNum)));
        pJson.insert("C1",QJsonValue(QString::number(*currentFloor)+"/"+QString::number(i+1)));
        pJson.insert("C2",QJsonValue(QString::number((*(pWeldData+i)).weldCurrent)));
        pJson.insert("C3",QJsonValue(QString::number(float(qRound((*(pWeldData+i)).weldVoltage*10))/10)));
        pJson.insert("C4",QJsonValue(QString::number(float(qRound(pF->swingLength*5))/10)));
        pJson.insert("C5",QJsonValue(QString::number(float(qRound((*(pWeldData+i)).swingSpeed*10))/10)));
        pJson.insert("C6",QJsonValue(QString::number(float(qRound((*(pWeldData+i)).weldTravelSpeed))/10)));
        pJson.insert("C7",QJsonValue(QString::number(float(qRound(*(weldLineX+temp)*10))/10)));
        pJson.insert("C8",QJsonValue(QString::number(float(qRound(*(weldLineY+temp)*10))/10)));
        pJson.insert("C9",QJsonValue(QString::number(float(qRound((*(pWeldData+i)).beforeSwingStayTime*10))/10)));
        pJson.insert("C10",QJsonValue(QString::number(float(qRound((*(pWeldData+i)).afterSwingStayTime*10))/10)));
        pJson.insert("C11",QJsonValue(str));
        pJson.insert("C12",QJsonValue(QString::number(float(qRound(s*10))/10)));
        pJson.insert("C13",QJsonValue(QString::number(float(qRound((*(pWeldData+i)).weldFill*10))/10)));
        pJson.insert("C14",QJsonValue(QString::number(float(qRound(*(startArcX+temp)*10))/10)));
        pJson.insert("C15",QJsonValue(QString::number(float(qRound(*(startArcY+temp)*10))/10)));
        pJson.insert("C16",QJsonValue(QString::number(float(qRound(*(startWeldLineZ+i)*10))/10)));
        pJson.insert("C17",QJsonValue(QString::number(float(qRound(*(weldLineX+temp)*10))/10)));
        pJson.insert("C18",QJsonValue(QString::number(float(qRound(*(weldLineY+temp)*10))/10)));
        pJson.insert("C19",QJsonValue(QString::number(float(qRound(*(stopWeldLineZ+i)*10))/10)));
        emit weldRulesChanged(status,pJson);
    }
    //迭代中线偏移Y
    *weldLineYUesd+=pF->height;
    *hused+=pF->height;
    *sused+=s;
    *currentFloor=*currentFloor+1;
    return 1;
}

int SysMath::weldMath(){
    int i;
    float sUsed=0;
    float hUsed=0;
    int currentWeldNum=0;
    int floorNum=1;
    //起弧z位置 每次都往里面缩进3mm
    float weldLineYUesd=0;
    controlWeld=false;
    totalWeldTime=0;
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
            currentMax=350;
            currentMin=50;
        } else{
            currentMax=350;
            currentMin=150;}
    }else if(weldStyleName=="立焊"){
        if(pulseValue){
            currentMax=350;
            currentMin=50;
        }else  if(wireTypeValue==4){//药芯
            currentMax=350;
            currentMin=180;
        }else{
            currentMax=350;
            currentMin=80;}
    }else if(weldStyleName=="横焊"){
        if(pulseValue){
            currentMax=350;
            currentMin=50;
        } else{
            currentMax=350;
            currentMin=80;}
    }
    else
        if(pulseValue){
            currentMax=350;
            currentMin=50;
        } else{
            currentMax=350;
            currentMin=80;}

    bottomFloor->height=bottomFloor->maxHeight;
    while(bottomFloor->height>bottomFloor->minHeight){
        if(getWeldFloor(bottomFloor,&hUsed,&sUsed,&weldLineYUesd,&floorNum,&currentWeldNum)!=-1){
            break;
        }
        bottomFloor->height-=0.2;
    }
    if(bottomFloor->height<bottomFloor->minHeight) return -1;
    float hre=grooveHeight+reinforcementValue-hUsed;
    int res=solveN(&hre,&hUsed,&sUsed,&weldLineYUesd,&floorNum,&currentWeldNum);
    if(res==-1) return -1;
    for(i=0;i<secondFloor->num;i++){
        if(getWeldFloor(secondFloor,&hUsed,&sUsed,&weldLineYUesd,&floorNum,&currentWeldNum)==-1){
            return -1;
        }
    }
    for(i=0;i<fillFloor->num;i++){
        if(getWeldFloor(fillFloor,&hUsed,&sUsed,&weldLineYUesd,&floorNum,&currentWeldNum)==-1){
            return -1;
        }
    }
    for(i=0;i<topFloor->num;i++){
        if(getWeldFloor(topFloor,&hUsed,&sUsed,&weldLineYUesd,&floorNum,&currentWeldNum)==-1){
            return -1;
        }
    }
    qDebug()<<"totalWeldTime is "<<totalWeldTime;
    emit weldRulesChanged("Finish",pJson);
    return 1;
}

/*
 * swing  摆动幅度  pf 当前层条件  weldSpeed 焊接速度
 */
float SysMath::getSwingSpeed(weldDataType *pWeldData,float maxSpeed){
    //定义摆动间隔
    float A;
    //定义总时间
    float t;
    //定义停留时间 单位MS
    float t_temp0 = (((*pWeldData).beforeSwingStayTime+(*pWeldData).afterSwingStayTime)*1000)/4;
    //定义加速度时间
    float t_temp1=0;
    //定义匀速时间
    float t_temp2=0;
    //定义摆动速度
    float swingSpeed=0;
    if(((*pWeldData).swingLength<=0)||((*pWeldData).weldTravelSpeed<=0)){
        return  0;
    }
    //脉冲叠加数量  半个摆幅 对应脉冲数 = 摆幅(mm)/2*(10)*(0.1mm 对应脉冲数)
    float S_MAX=(*pWeldData).swingLength*10*WAVE_CODE_NUM/2;
    for(;;){
        //定义加速度时间
        t_temp1=0;
        //定义匀速时间
        t_temp2=0;
        //求取到达最大速度的时间及路程
        for(int i=0;;i++){
            swingSpeed=WAVE_SPEED_START_STOP+WAVE_SPEED_ACCE_DECE*i;
            //maxPulse 7666
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
                (*pWeldData).swingHz=1/t;
                qDebug()<<"SysMath::getSwingSpeed::Hz"<<1/(t);
                return GET_WAVE_SPEED(swingSpeed);
            }
        }
        //t_temp2 存在 则证明 匀速存在  ms转换成min
        t=((t_temp0+t_temp1+t_temp2)*4)/60000;
        if(t==0)
            return 0;
        (*pWeldData).swingHz=1/t;
        A=t*(*pWeldData).weldTravelSpeed;
        A=float(qRound(A*10))/10;
        // qDebug()<<"SysMath::getSwingSpeed::T"<<t<<" t_temp0"<<t_temp0<<" t_temp1"<<t_temp1<<" t_temp2"<<t_temp2;
        qDebug()<<"SysMath::getSwingSpeed::swingSpeed"<<GET_WAVE_SPEED(swingSpeed);
        qDebug()<<"SysMath::getSwingSpeed::Hz"<<1/(t);
        qDebug()<<"SysMath::getSwingSpeed::A"<<A;
        if((((A<3.5)&&((*pWeldData).beforeSwingStayTime!=0)&&((*pWeldData).afterSwingStayTime!=0))||((A<2.5)&&((*pWeldData).beforeSwingStayTime==0)&&((*pWeldData).afterSwingStayTime==0)))&&(weldStyleName!="立焊")){
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
    if((current>350)&&(current<10))
        return -1;
    if((gasValue)&&(!pulseValue)&&(wireTypeValue==0)&&(wireDValue==4)){
        //MAG D 实芯 1.2
        if((current<=200)||(weldStyleName=="横焊")||(weldStyleName=="立焊")){
            voltage=14+0.05*current-2;
        }else{
            voltage=14+0.05*current+1;
        }
    }else if((gasValue)&&(pulseValue)&&(wireTypeValue==0)&&(wireDValue==4)){
        //MAG P 实芯 1.2 200以下或者横焊或者立焊 MAG 脉冲电压都要压低
        if ((current<=200)||(weldStyleName=="横焊")||(weldStyleName=="立焊")){
            voltage=14+0.05*current-1.5;
        }else{
            voltage=14+0.05*current+1;
        }
    }else if((!gasValue)&&(!pulseValue)&&(wireTypeValue==0)&&(wireDValue==4)){
        //CO2 D 实芯 1.2
        if((current<=200)||(weldStyleName=="横焊")||(weldStyleName=="立焊"))
            voltage=14+0.05*current-1;
        else
            voltage=14+0.05*current+1;
    }else if((!gasValue)&&(!pulseValue)&&(wireTypeValue==4)&&(wireDValue==4)){
        //CO2 D 药芯 1.2  药芯电压作用不明显
        if (current<170)
            voltage=14+0.05*current+1;
        else
            voltage=14+0.05*current+0.5;
    }else {
        return -1;
    }
    return voltage;
}

int SysMath::getFeedSpeed(int current){
    int feedspeed;
    const int FeedSpeedNum[8][50]={
        //1.2
        {1240,1280,1320,1360,1400,1536,1673,1845,2027,2215,
         2408,2600,2878,3155,3427,3700,4200,4645,5055,5478,
         5922,6367,6811,7155,7473,7960,8538,9100,9550,10000,
         10850,11700,12350,13000,14000,15000,16167,17000,18169,19013,
         19856,20700,21585,22469,23222,23778,24333,24889,25000,25000},

        {300,600,900,1200,1600,2000,2400,2800,3199,3600,
         4000,4400,4800,5200,5600,6000,6500,7000,7400,7800,
         8300,8800,9300,9800,10300,10800,11300,11800,12300,12800,
         13400,14000,14600,15200,15900,25000,25000,25000,25000,25000,
         25000,25000,25000,25000,25000,25000,25000,25000,25000,25000},

        {900,1000,1100,1200,1300,1400,1550,1700,1867,2050,
         2300,2562,2875,3200,3533,3867,4225,4600,5100,5871,
         6300,6762,7223,7750,8375,8833,9250,9725,10288,10800,
         11314,11886,12375,12844,13312,25000,25000,25000,25000,25000,
         25000,25000,25000,25000,25000,25000,25000,25000,25000,25000},

        {950,1100,1250,1400,1550,1700,2200,2700,3033, 3367,
         3700, 4100, 4500,5300, 5850,6400,6850,7300,7850,8400,
         9200,10000,10650,11300,11900,12500,13750,15000,15750,16500,
         17250,18000,18800,19600,20400,21200,22100,23000,24000,25000,
         25000,25000,25000,25000,25000,25000,25000,25000,25000,25000},
        //1.6参数
        {1240,1280,1320,1360,1400,1536,1673,1845,2027,2215,
         2408,2600,2878,3155,3427,3700,4200,4645,5055,5478,
         5922,6367,6811,7155,7473,7960,8538,9100,9550,10000,
         10850,11700,12350,13000,14000,15000,16167,17000,18169,19013,
         19856,20700,21585,22469,23222,23778,24333,24889,25000,25000},

        {300,600,900,1200,1600,2000,2400,2800,3199,3600,
         4000,4400,4800,5200,5600,6000,6500,7000,7400,7800,
         8300,8800,9300,9800,10300,10800,11300,11800,12300,12800,
         13400,14000,14600,15200,15900,25000,25000,25000,25000,25000,
         25000,25000,25000,25000,25000,25000,25000,25000,25000,25000},

        {900,1000,1100,1200,1300,1400,1550,1700,1867,2050,
         2300,2562,2875,3200,3533,3867,4225,4600,5100,5871,
         6300,6762,7223,7750,8375,8833,9250,9725,10288,10800,
         11314,11886,12375,12844,13312,25000,25000,25000,25000,25000,
         25000,25000,25000,25000,25000,25000,25000,25000,25000,25000},

        {950,1100,1250,1400,1550,1700,2200,2700,3033, 3367,
         3700, 4100, 4500,5300, 5850,6400,6850,7300,7850,8400,
         9200,10000,10650,11300,11900,12500,13750,15000,15750,16500,
         17250,18000,18800,19600,20400,21200,22100,23000,24000,25000,
         25000,25000,25000,25000,25000,25000,25000,25000,25000,25000}
    };
    if((current>350)||(current<10))
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
    }else if((gasValue)&&(!pulseValue)&&(wireTypeValue==0)&&(wireDValue==6)){
        //MAG D 实芯 1.6
        feedspeed=4;
    }else if((gasValue)&&(pulseValue)&&(wireTypeValue==0)&&(wireDValue==6)){
        //MAG P 实芯 1.6
        feedspeed=5;
    }else if((!gasValue)&&(!pulseValue)&&(wireTypeValue==0)&&(wireDValue==6)){
        //CO2 D 实芯 1.6
        feedspeed=6;
    }else if((!gasValue)&&(!pulseValue)&&(wireTypeValue==4)&&(wireDValue==6)){
        //CO2 D 药芯 1.6
        feedspeed=7;
    }else{
        return -1;
    }
    return FeedSpeedNum[feedspeed][current/10-1];
}

//求解 道面积 存储到pFill开始的内存里
void SysMath::solveA(weldDataType *pWeldData,FloorCondition *p,int num,float s){
    int i=0;
    qreal fill=1;
    if ((weldConnectName=="T接头")&&(weldStyleName=="横焊")){
        for(i=0;i<(num-1);i++){
            fill+=qPow(p->k,i+1);
            qDebug()<<"fill"<<fill;
        }
        for(i=0;i<num;i++){
            (*(pWeldData+i)).weldFill=(s/fill)*(qPow(p->k,i));
            qDebug()<<"i"<<(*(pWeldData+i)).weldFill<<s;
        }
    }else{
        for(i=0;i<num;i++){
            if(num==1)
                (*pWeldData).weldFill=s;
            else if(i<(num-1))
                (*(pWeldData+i)).weldFill=s/(num-1+p->k);
            else if(i==(num-1))
                (*(pWeldData+i)).weldFill=(*(pWeldData+i-1)).weldFill*p->k;
        }
    }
}
int SysMath::solveI(FloorCondition *pI, int num,int total){
    if(total==1){
        pI->current=pI->current_middle;
    }else if(num==0){
        pI->current=pI->current_right;
    }else if(num<(total-1)){
        pI->current=pI->current_middle;
    }else if(num==(total-1)){
        pI->current=pI->current_left;
    }else{
        status="电流选择num大于total！";
        return -1;
    }
    return pI->current;
}
//分层
int SysMath::solveN(float *pH,float *hused,float *sused,float *weldLineYUesd,int *currentFloor,int *currentWeldNum){
    float tempH,tempHav;
    int fillFloor_MaxNum=0;
    int fillFloor_MinNum=0;

    int res=0;

    if(qRound(*pH)<=0){
        fillFloor->num=topFloor->num=secondFloor->num=0;
        bottomFloor->height=grooveHeight+reinforcementValue;
        //调用重新匹配第一层
#if ENABLE_SOLVE_FIRST ==1
        if(getWeldFloor(bottomFloor,hused,sused,weldLineYUesd,currentFloor,currentWeldNum)==-1){
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
            if(getWeldFloor(bottomFloor,hused,sused,weldLineYUesd,currentFloor,currentWeldNum)==-1){
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
            if(getWeldFloor(bottomFloor,hused,sused,weldLineYUesd,currentFloor,currentWeldNum)==-1){
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
            else if((secondFloor->height<secondFloor->minHeight)||(secondFloor->height>secondFloor->maxHeight)){
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
            if(getWeldFloor(bottomFloor,hused,sused,weldLineYUesd,currentFloor,currentWeldNum)==-1){
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
typedef struct{
    float x;
    float y;
}point;
typedef struct{
    float angel;
    float height;
    float rootGap;
    bool error;
}ResType;
ResType getAngelT(float angel1,float angel2,float height,float rootgap,float heightError){
    ResType res;
    res.angel=0;
    res.height=0;
    res.error=false;
    res.rootGap=0;
    float Lk,Lb,Rk;
    point A,B,C;
    if(angel1!=0){
        Lb=-rootgap/qTan(angel1*PI/180); //线段b b
        Lk=-1/qTan(angel1*PI/180);//线段b 斜率
        A.y=height;
        A.x=(A.y-Lb)/Lk;//A点坐标
        if(angel2==0){
            C.x=0; //C点坐标
            C.y=Lb;
            B.x=0; //B点坐标
            B.y=height+heightError;
        }else{
            Rk=1/qTan(angel2*PI/180);//线段a 斜率
            C.x=Lb/(Rk-Lk); //C点坐标
            C.y=C.x*Rk;
            B.y=height+heightError*qCos(angel2*PI/180);//B点坐标
            B.x=B.y/Rk;
        }
        //求c边长
        float b,a,c;
        b=(A.x-C.x)*(A.x-C.x)+(A.y-C.y)*(A.y-C.y);
        b=qSqrt(b);
        a=(B.x-C.x)*(B.x-C.x)+(B.y-C.y)*(B.y-C.y);
        a=qSqrt(a);
        c=a*a+b*b-a*b*2*qCos((angel1+angel2)*PI/180);
        c=qSqrt(c);
        //求B角度
        float angelB;
        angelB=qAcos((a*a+c*c-b*b)/(2*a*c))*180/PI;
        res.angel=90-angel2-angelB;
        //求坡口高度
        float zb,za;
        point D;
        float d;
        //求垂线斜率
        if((B.y-A.y)==0){
            res.angel=0;
            res.height=height;
            res.rootGap=rootgap;
        }else{
            za=-(B.x-A.x)/(B.y-A.y);
            zb=C.y-za*C.x;
            D.x=-zb/za;
            D.y=0;
            d=(D.x-C.x)*(D.x-C.x)+(D.y-C.y)*(D.y-C.y);
            d=qSqrt(d);
            res.height=a*qSin(angelB*PI/180)-d;
            res.rootGap=d*qTan((90-angelB)*PI/180)+d*qTan((angel1+angel2+angelB-90)*PI/180);
        }
    }else{
        //左边角度不能为0
        res.error=true;
    }
    return res;
}

int SysMath::setGrooveRules(QStringList value){
    qDebug()<<value;
    //数组有效
    if(value.count()){
        if(weldStyleName!="水平角焊"){
            grooveHeight=value.at(0).toFloat();
            grooveHeightError=value.at(1).toFloat();
            rootGap=value.at(2).toFloat();
            if(weldConnectName=="T接头"){
                //float a,b,c,c2,angel1,angel2,angela,angelc;
                float angel1,angel2;
                if(grooveDirValue)//非坡口侧
                {  angel1=value.at(4).toFloat();
                    angel2=value.at(3).toFloat();
                }else{ angel1=value.at(3).toFloat();
                    angel2=value.at(4).toFloat();
                }
                ResType res= getAngelT(angel1,angel2,grooveHeight,rootGap,grooveHeightError);
                if(!res.error){
                    angel=res.angel;
                    grooveHeight=res.height;
                    rootGap=res.rootGap;
                    if(grooveDirValue){
                        grooveAngel2=angel1-angel;
                        grooveAngel1=angel2+angel;
                    }else{
                        grooveAngel1=angel1-angel;
                        grooveAngel2=angel2+angel;
                    }
                }else{
                    status="角度β1或β2异常！";
                    emit weldRulesChanged("error",pJson);
                }
            }else{ //输入的板厚已经和板厚差做出变化
                grooveAngel1=value.at(3).toFloat();
                grooveAngel2=value.at(4).toFloat();
            }
        }else{//水平角焊
            grooveHeight=value.at(0).toFloat();
            grooveHeightError=value.at(1).toFloat();
            angel=qAtan(grooveHeight/grooveHeightError)*180/PI;
            grooveHeight*=qCos(angel*PI/180);
            rootGap=0;
            if(grooveDirValue){//非坡口侧
                grooveAngel1=value.at(3).toFloat()+angel;
                grooveAngel2=value.at(4).toFloat()-angel;
            }else{
                grooveAngel1=value.at(3).toFloat()-angel;
                grooveAngel2=value.at(4).toFloat()+angel;
            }
        }
        //获取焊接长度
        weldLength=value.at(7).toFloat();
    }
    emit weldRulesChanged("Clear",pJson);
    return weldMath();
}
