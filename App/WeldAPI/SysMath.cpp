#include "SysMath.h"
#include "FeedSpeedTable.h"

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
    //  qDebug()<<"angel"<<angel<<"x1"<<*x1<<"*y1"<<*y1<<"x2"<<x2<<"y2"<<y2;
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
    //*x1=float(qRound(10**x1))/10;
    //*y1=float(qRound(10**y1))/10;
    //y1为负值则迁移坐标使y值为正值
    // qDebug()<<"angel"<<angel<<"x1"<<*x1<<"*y1"<<*y1<<"x2"<<x2<<"y2"<<y2;
}
//
float SysMath::getTravelSpeed(){
    float temp1;
    int temp;
    //获取电压 为0 则自动生成电压 否则 采用限制条件电压
    if(pF->voltage==0){
        temp1=getVoltage(pWeldData->weldCurrent,pF->name);
        if(temp1<0){return temp1;}
        else pWeldData->weldVoltage=temp1;
    }else
        pWeldData->weldVoltage=pF->voltage;
    //获取送丝速度
    temp=getFeedSpeed(pWeldData->weldCurrent);
    if(temp<0){return temp;}
    else pWeldData->weldFeedSpeed=temp;
    //计算焊速
    pWeldData->weldTravelSpeed=GET_TRAVELSPEED(meltingCoefficient,weldWireSquare,pWeldData->weldFeedSpeed,pWeldData->weldFill);
    if(pWeldData->weldTravelSpeed<=0) {
        return ERROR_GET_TRAVELSPEED;
    }else
        return NO_ERROR;
}
//优化函数输入参数结构
int SysMath::getWeldNum(){
    int temp;
    if(currentWeldNum>weldNum) return ERROR_OTHER;
    //设置摆宽
    pWeldData->swingLength=pF->swingLength;
    //设置当前层
    pWeldData->floor=currentFloor;
    //当前层内当前道
    pWeldData->num=currentWeldNum+1;
    //总焊道号
    pWeldData->index=weldNumIndex+currentWeldNum;
    //获取电流
    pWeldData->weldCurrent=solveI(currentWeldNum,weldNum);
    //计算焊接速度
    temp=getTravelSpeed();
    if(temp<0) return temp;
    //保证焊接速度不大于最大焊接速度 否则减小电流 2A
    if(pWeldData->weldTravelSpeed>pF->maxWeldSpeed){
        /*2019.11.19屏蔽 超过最大速度则不再调整焊接电流直接以最大速度进行焊接
        while(pWeldData->weldTravelSpeed>pF->maxWeldSpeed){
            pWeldData->weldCurrent-=2;
            //需要重新调整层高
            if(pWeldData->weldCurrent<pF->current-10){
                qDebug()<<"pF.maxWeldSpeed";
                // 只有计算显示的时候才做
                if(pGrooveRules->index==255)
                    return ERROR_CURRENT_MIN;
            }
            //重新获取行走速度
            temp=getTravelSpeed();
            if(temp<0) return temp;
        }
        */
          pWeldData->weldTravelSpeed= pF->maxWeldSpeed;
    }else if(pWeldData->weldTravelSpeed<pF->minWeldSpeed){//焊速小于最小速度加电流 2A
        /*2019.11.19屏蔽 超过最小速度则不再调整焊接电流直接以最小速度进行焊接
        while(pWeldData->weldTravelSpeed<pF->minWeldSpeed){
            pWeldData->weldCurrent+=2;
            //需要重新调整层高
            if(pWeldData->weldCurrent>pF->current+10){
                qDebug()<<"pF.minWeldSpeed";
                // 只有计算显示的时候才做
                if(pGrooveRules->index==255)
                    return ERROR_CURRENT_MAX;
            }
            //重新获取行走速度
            temp=getTravelSpeed();
            if(temp<0) return temp;
        }*/
       pWeldData->weldTravelSpeed= pF->minWeldSpeed;
    }
    //分道后 两侧停留时间发生位置变化， 靠近破口侧 停留时间大于 中间位置
    if(weldNum<2){//单层单道
        if(grooveStyleName=="单边V形坡口"){
            pWeldData->outSwingStayTime=!grooveDir?pF->swingNotGrooveStayTime:pF->swingGrooveStayTime; // 非坡口侧:坡口侧
            pWeldData->interSwingStayTime=!grooveDir?pF->swingGrooveStayTime:pF->swingNotGrooveStayTime;    //坡口侧:非坡口侧
        }else{//V形坡口 两边停留时间一致且为坡口侧 停留时间。
            pWeldData->outSwingStayTime=pF->swingGrooveStayTime;// 坡口侧
            pWeldData->interSwingStayTime=pF->swingGrooveStayTime;    //坡口侧
        }
    }else{//分道处理
        if(grooveStyleName=="单边V形坡口"){
            if(currentWeldNum==0){
                pWeldData->outSwingStayTime=!grooveDir?pF->swingNotGrooveStayTime:pF->swingGrooveStayTime; // 非坡口侧:坡口侧
                pWeldData->interSwingStayTime=!grooveDir?pF->swingGrooveStayTime:pF->swingNotGrooveStayTime;    //坡口侧:非坡口侧
            }else{
                //均为坡口侧 停留时间
                pWeldData->interSwingStayTime=pWeldData->outSwingStayTime=pF->swingGrooveStayTime; // 非坡口侧:坡口侧
            }
        }else{//V形坡口
            if((currentWeldNum+1)<(weldNum)){//不是最后一道
                pWeldData->outSwingStayTime=pF->swingGrooveStayTime;// 坡口侧
                pWeldData->interSwingStayTime=pF->swingNotGrooveStayTime;//非坡口侧
            }else{
                pWeldData->outSwingStayTime=pF->swingGrooveStayTime;//坡口侧
                pWeldData->interSwingStayTime=pF->swingGrooveStayTime;    //坡口侧
            }
        }
    }
    //计算摆速 20191120 加快药芯焊丝立焊的摆动速度
    if((weldStyleName=="立焊")&&(wireType==0)){
        //最大摆速1400  900   6之后 开始衰减 到 30
        // 1400=6*x+Y
        // 900=22*x+Y  ->500=-16X ->X=-31 ->Y=1570
        temp=pF->swingLength>6?qMax(1570-31*pF->swingLength,float(600)):WAVE_MAX_VERTICAL_SPEED;
    }else{
        temp=getSwingSpeed(WAVE_MAX_SPEED,pWeldData);
    }
    if(temp<0) return temp;
    else pWeldData->swingSpeed=temp;
    //重新计算层面积
    pWeldData->weldFill=GET_WELDFILL_AREA(meltingCoefficient,weldWireSquare, pWeldData->weldFeedSpeed, pWeldData->weldTravelSpeed);
    s+= pWeldData->weldFill;
    //限制摆速
    if(pWeldData->swingSpeed<=(WAVE_MIN_SPEED/10))//最小摆速 800
        pWeldData->swingSpeed=WAVE_MIN_SPEED/10;
    else
        pWeldData->swingSpeed/=10;
    //停止时间存入
    pWeldData->stopTime=currentWeldNum==(weldNum-1)?stopOutTime:stopInTime;
    //全算完了之后重新调整 摆宽 摆宽这个时候调整 会影响到摆频的计算
    if(weldConnectName=="T接头"){
        pWeldData->swingLength*=qCos(pGrooveRules->angel*PI/180);
    }
    //陶瓷衬垫打底摆宽最好不要超过 根部间隙 -2mm否则容易出现底部成型不良
    //if((pWeldData->swingLength>(pGrooveRules->rootGap-2))&&(pF->name=="ceramicBackFloor"))
    // pWeldData->swingLength=(pGrooveRules->rootGap-2)>0?pGrooveRules->rootGap-2:0;
    //计算单道摆宽小于2 则清零
    if((weldStyleName=="水平角焊")||(pF->swingLength<2)||(weldStyleName=="横焊"))
        pWeldData->swingLength=0;
    /*
    if(&&(weldNum==1)&&(pF->name=="bottomFloor")){

    }else{
        pWeldData->swingLength=0;
    }*/
    return NO_ERROR;
}
/*
 *  计算焊接中线XY 起弧XY收弧XY 起弧Z收弧Z
 *  针对摆动方向 内正外负
 */
int SysMath::getPoint(){
    float reSwingRightLength,tempHeight,tempSwingLength;
    int i;
    int j;
    tempHeight=pF->height/2;
    weldPointType *pPoint;
    //重新计算 摆幅距离非坡口侧距离
    reSwingRightLength= ((qMax(float(0),(hused+tempHeight-rootFace)*(grooveAngelTan))+pGrooveRules->rootGap\
                          -weldNum*pF->swingLength-(weldNum-1)*pF->weldSwingSpacing)*(pF->swingRightLength))/(pF->swingLeftLength+pF->swingRightLength);
    qDebug()<<"reSwingRightLength"<<reSwingRightLength;
    //2019.10.8横焊坐标排布更新
    if(weldStyleName=="横焊"){
        if(weldNum==1){
            tempSwingLength=0;
        }else{
            tempSwingLength=pF->swingLength*weldNum/(weldNum-1);
        }
    }else{
        tempSwingLength=0;
    }
    for(i=0;i<weldNum;i++){
        if(weldStyleName=="水平角焊"){
            j=weldNum-i-1;
        }else{
            j=i;
        }
        pPoint=&pWeldDataTable->weldDataFloorTable[currentFloor-1].weldPointTable[j];
        //计算焊枪当前Y轴坐标取1/2
        pPoint->weldLineY=weldLineYUesd+pF->height/2;
        //计算焊枪当前X轴坐标  2019.10.8 横焊坐标排布更新
        if(grooveDir){//非坡口侧
            if(weldStyleName=="横焊"){
                pPoint->weldLineX=-((reSwingRightLength+(tempSwingLength+pF->weldSwingSpacing)*(i)-\
                                     qMax(float(0),(hused+tempHeight-rootFace)*pGrooveRules->grooveAngel1Tan))-pGrooveRules->rootGap/2);
            }else{
                 //2021.03.22 水平角焊盖面不能切换坐标
                if((pF->name=="topFloor")&&(grooveStyleName=="单边V形坡口")&&(weldStyleName=="平焊"))
                    pPoint->weldLineX=-((reSwingRightLength+pF->swingLength/2+(pF->swingLength+pF->weldSwingSpacing)*(weldNum-1-i)-\
                                         qMax(float(0),(hused+tempHeight-rootFace)*pGrooveRules->grooveAngel1Tan))-pGrooveRules->rootGap/2);
                else
                    pPoint->weldLineX=-((reSwingRightLength+pF->swingLength/2+(pF->swingLength+pF->weldSwingSpacing)*(i)-\
                                         qMax(float(0),(hused+tempHeight-rootFace)*pGrooveRules->grooveAngel1Tan))-pGrooveRules->rootGap/2);
            }
        }else{
            if(weldStyleName=="横焊"){
                pPoint->weldLineX=((reSwingRightLength+(tempSwingLength+pF->weldSwingSpacing)*(i)-\
                                    qMax(float(0),(hused+tempHeight-rootFace)*pGrooveRules->grooveAngel2Tan))-pGrooveRules->rootGap/2);
            }else{
                //2021.03.22 水平角焊盖面不能切换坐标
                if((pF->name=="topFloor")&&(grooveStyleName=="单边V形坡口")&&(weldStyleName=="平焊"))
                    pPoint->weldLineX=((reSwingRightLength+pF->swingLength/2+(pF->swingLength+pF->weldSwingSpacing)*(weldNum-1-i)-\
                                        qMax(float(0),(hused+tempHeight-rootFace)*pGrooveRules->grooveAngel2Tan))-pGrooveRules->rootGap/2);
                else
                    pPoint->weldLineX=((reSwingRightLength+pF->swingLength/2+(pF->swingLength+pF->weldSwingSpacing)*(i)-\
                                        qMax(float(0),(hused+tempHeight-rootFace)*pGrooveRules->grooveAngel2Tan))-pGrooveRules->rootGap/2);
            }
        }
        //计算焊枪当前起弧点XY轴坐标
        if(weldStyleName=="横焊"){//如果在坡口侧
            pPoint->startArcX=pPoint->weldLineX;
        }else{//从侧边起弧不从中间起弧
            if(i==0){//两侧的从两个侧壁起弧
                if(grooveDir)
                    pPoint->startArcX=pPoint->weldLineX+pF->swingLength/2;
                else
                    pPoint->startArcX=pPoint->weldLineX-pF->swingLength/2 ;
            }else if((i+1)==weldNum){
                if(grooveDir)
                    pPoint->startArcX=pPoint->weldLineX-pF->swingLength/2;
                else
                    pPoint->startArcX=pPoint->weldLineX+pF->swingLength/2 ;
            }else{
                pPoint->startArcX=pPoint->weldLineX;
            }
        }
        pPoint->startArcY= pPoint->weldLineY;
        //计算旋转前坐标系
        if(weldStyleName=="水平角焊"){//角焊翻转坐标系  尚未翻转
            getXYPosition(pGrooveRules->angel,&pPoint->startArcX,&pPoint->startArcY,pPoint->weldLineX,pPoint->weldLineY);
            if(grooveDir){
                pPoint->startArcX=-pPoint->startArcX;
                pPoint->weldLineX=pPoint->startArcX;
            }else
                pPoint->weldLineX=pPoint->startArcX;
            pPoint->weldLineY=pPoint->startArcY;
        }else if(weldConnectName=="T接头"){
            getXY(pGrooveRules->angel,&pPoint->startArcX,&pPoint->startArcY,grooveDir?pPoint->weldLineX:-pPoint->weldLineX,pPoint->weldLineY);
            pPoint->startArcX-=pGrooveRules->basic_x;
            pPoint->startArcY-=pGrooveRules->basic_y;
            pPoint->startArcX=grooveDir?pPoint->startArcX:-pPoint->startArcX;
            pPoint->weldLineX=pPoint->startArcX;
            pPoint->weldLineY=pPoint->startArcY;
        }
        //计算焊枪当前收弧点XY轴坐标
        pPoint->stopArcX=pPoint->weldLineX;
        pPoint->stopArcY=pPoint->weldLineY;
    }
    return NO_ERROR;
}

int SysMath::getWeldFloor(){
    float swingLength;
    int res;
    //打底层清空
    if((pF->name=="bottomFloor")||(pF->name=="ceramicBackFloor")){
        weldNumIndex=1;
        hused=0;
        sused=0;
        weldLineYUesd=0;
        currentFloor=1;
        if(pGrooveRules->grooveHeight<pF->minHeight){
            return -1;
        }
    }
    float ba=2;
    //前面应该对输入参数进行校验 否则不能进入函数
    //计算层面积
    if(pF->name=="topFloor"){
        /*有异议*/
        //  pF->height=pGrooveRules->grooveHeight+reinforcement-hused;
        //面积为 坡口剩余面积+余高*（间隙+两侧坡口角度+覆盖坡口外益面积）/2
        s=(pGrooveRules->grooveHeight-rootFace)*(pGrooveRules->grooveHeight-rootFace)*grooveAngelTan/2+pGrooveRules->rootGap*pGrooveRules->grooveHeight;
        s-=sused;
        if(grooveStyleName=="V形坡口")
            s+=reinforcement*(2*(pGrooveRules->grooveHeight-rootFace)*grooveAngelTan/2+pGrooveRules->rootGap+2*ba)/2;
        else
            if(weldConnectName=="T接头"){//头要多焊出坡口
                ba=3;
                s+=(reinforcement)*(2*(pGrooveRules->grooveHeight-rootFace)*grooveAngelTan/2+pGrooveRules->rootGap+ba);
            }else
                s+=(reinforcement)*(2*(pGrooveRules->grooveHeight-rootFace)*grooveAngelTan/2+pGrooveRules->rootGap+ba)/2;
    }else{
        //计算面积
        s=(qMax(float(0),(hused+pF->height-rootFace))*qMax(float(0),(hused+pF->height-rootFace)*grooveAngelTan/2)+pGrooveRules->rootGap*(hused+pF->height)-sused);
    }
    if(pF->name=="ceramicBackFloor"){
        //陶瓷衬垫 的面积计算
        s+=GET_CERAMICBACK_AREA(pGrooveRules->rootGap,1.5);
    }
    //计算h/2处摆宽
    swingLength=qMax(float(0),(hused+pF->height/2-rootFace)*grooveAngelTan)+pGrooveRules->rootGap;
    //如果摆宽小于两端间隔则 不摆
    if(swingLength>(pF->swingLeftLength+pF->swingRightLength))
        swingLength-=pF->swingLeftLength+pF->swingRightLength;
    else
        swingLength=0;
    //当前坡口为均部坡口时则计算分道数
    if(pGrooveRules->index==255){
        //计算分多少道
        for(weldNum=1;weldNum<20;weldNum++){
            if(swingLength<((pF->weldSwingSpacing)*(weldNum-1)+pF->maxSwingLength*weldNum)){
                break;
            }
        }
        if(weldNum>20){
            return ERROR_WELDNUM_MAX;
        }
        //预置当前层堆栈深度
        pWeldDataTable->weldDataFloorTable[currentFloor-1].length=weldNum;
    }else{
        //把均部的道数赋值给示教点的层道数
        pWeldDataTable->weldDataFloorTable[currentFloor-1].length=weldNum=pDispWeldDataTable->weldDataFloorTable[currentFloor-1].length;
    }
    //焊接参数
    pWeldData=&pWeldDataTable->weldDataFloorTable[currentFloor-1].weldDataTable[0];
    pWeldData->name=pF->name;
    //打底时把缺失的填充补充回来
    if(pF->name=="bottomFloor"){
        s+=pGrooveRules->s;
    }
    //初始化数组 焊接规范数组内部填充量
    solveA(weldNum,s);
    //计算单道摆宽0.2 倍数
    pF->swingLength=float(qRound(5*(swingLength-(weldNum-1)*pF->weldSwingSpacing)/weldNum))/5;
    //清空总的使用缓存
    s=0;
    //计算层内道数
    for(currentWeldNum=0;currentWeldNum<weldNum;currentWeldNum++){
        res=getWeldNum();
        if(res<0) return res;
        pWeldData++;
    }
    //在把填充缺失的打底填充弄回去
    if(pF->name=="bottomFloor"){
        s-=pGrooveRules->s;
    }
    //获取坐标点
    getPoint();
    //迭代中线偏移Y
    weldNumIndex+=weldNum;
    weldLineYUesd+=pF->height;
    hused+=pF->height;
    sused+=s;
    currentFloor=currentFloor+1;
    return NO_ERROR;
}

int SysMath::weldMath(weldDataTableType *pWeld){
    /* */
    int i,res;
    float bottomS,minS,maxS;
    // controlWeld=false;
    totalWeldTime=0;
    pWeldDataTable=pWeld;
    /*坡口*/
    pGrooveRules=&pWeldDataTable->grooveRules;
    //角度变量
    pGrooveRules->grooveAngel1Tan=qTan(pGrooveRules->grooveAngel1*PI/180);
    pGrooveRules->grooveAngel2Tan=qTan(pGrooveRules->grooveAngel2*PI/180);
    grooveAngelTan= pGrooveRules->grooveAngel1Tan+ pGrooveRules->grooveAngel2Tan;
    //焊丝直径
    weldWireSquare=(wireDValue==4?1.2*1.2:1.6*1.6)*PI/4;
    //255代表该层为均部坡口参数，以均部坡口参数计算焊缝分层。
    if(pGrooveRules->index==255){
        //计算打底层
        //计算打底层预期截面积
        bottomFloor->height=bottomFloor->maxHeight;
        //最大最小填充
        minS=GET_WELDFILL_AREA(meltingCoefficient,weldWireSquare,getFeedSpeed(bottomFloor->current),bottomFloor->maxWeldSpeed);
        maxS=GET_WELDFILL_AREA(meltingCoefficient,weldWireSquare, getFeedSpeed(bottomFloor->current),bottomFloor->minWeldSpeed);
        for(i=0;i<6;i++){
            bottomS=(qMax(float(0),(bottomFloor->height-rootFace))*qMax(float(0),(bottomFloor->height-rootFace)*grooveAngelTan/2)+pGrooveRules->rootGap*(bottomFloor->height));
            if(bottomS<minS){
                //计算面积
                bottomFloor->height+=1;
            }else{
                i=7;
            }
        }
        bottomFloor->num=1;
        pF=bottomFloor;
        while(bottomFloor->height>bottomFloor->minHeight){
            res=getWeldFloor();
            pWeldData->weldCurrent=bottomFloor->current;
            if(res==ERROR_CURRENT_MIN)           bottomFloor->height+=0.5;
            else if(res==ERROR_CURRENT_MAX)   bottomFloor->height-=0.5;
            else if(res==NO_ERROR)break;
            else return res;
        }
        if(bottomFloor->height<bottomFloor->minHeight) return -1;
        //计算要焊接多少层
        res=solveN(pGrooveRules->grooveHeight+reinforcement-hused);
        if(res==-1) return -1;
    }else{
        pF=bottomFloor;
        for(i=0;i<bottomFloor->num;i++){
            res=getWeldFloor();
            if(res<0) return res;
        }
    }
    pF=secondFloor;
    for(i=0;i<secondFloor->num;i++){
        res=getWeldFloor();
        if(res<0) return res;
    }
    pF=fillFloor;
    for(i=0;i<fillFloor->num;i++){
        res=getWeldFloor();
        if(res<0) return res;
    }
    pF=topFloor;
    for(i=0;i<topFloor->num;i++){
        res=getWeldFloor();
        if(res<0) return res;
    }
    //存储当前层深度
    pWeldDataTable->length=bottomFloor->num+secondFloor->num+fillFloor->num+topFloor->num;
    pWeldDataTable->totalNum=weldNumIndex;
    return NO_ERROR;
}
/*
 * swing  摆动幅度  pf 当前层条件  weldSpeed 焊接速度
 */
float SysMath::getSwingSpeed(float maxSpeed,weldDataType *p){
    //定义摆动间隔
    float A;
    //定义总时间
    float t;
    //定义停留时间 单位ms
    float t_temp0 = ((p->outSwingStayTime+p->interSwingStayTime)*1000)/4;
    //定义加速度时间
    float t_temp1=0;
    //定义匀速时间
    float t_temp2=0;
    //定义摆动速度
    float swingSpeed=0;

    bool arcOn=false;
    //判断电弧跟踪
    if((arcSwEn)||(arcSwWEn))
        arcOn=true;
    else
        arcOn=false;
    if((p->swingLength<=0)||(p->weldTravelSpeed<=0)){
        return  WAVE_MIN_SPEED;
    }
    //脉冲叠加数量  半个摆幅 对应脉冲数 = 摆幅(mm)/2*(10)*(0.1mm 对应脉冲数)
    float S_MAX=p->swingLength*10*WAVE_CODE_NUM/2;
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
                p->swingHz=1/t;
                return GET_WAVE_SPEED(swingSpeed);
            }
        }
        //t_temp2 存在 则证明 匀速存在  ms转换成min
        t=((t_temp0+t_temp1+t_temp2)*4)/60000;
        if(t==0)
            return 0;
        p->swingHz=1/t;
        A=t*p->weldTravelSpeed;
        A=float(qRound(A*10))/10;
        p->A=A;
        //20191120加快盖面时摆动速度使盖面成型美观
        if(((A<3.5)&&(p->outSwingStayTime!=0)&&(p->interSwingStayTime!=0)&&(p->name!="topFloor"))||\
            ((A<2.5)&&(p->outSwingStayTime==0)&&(p->interSwingStayTime==0))||\
            ((A<2.5)&&(p->name=="topFloor")||\
            ((A<2)&&(arcOn)&&(weldNum==1)))
            ){//&&(weldStyleName!="立焊")){
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

/*
    2019.05.14 横焊电压增大到平焊焊接电压 立焊还维持不变
    2019.09.05 电压算法区分到焊接位置
*/
float SysMath::getVoltage(int current,QString name){
    float voltage=18;
    if((gas)&&(!pulse)&&(wireType==0)){
        //MAG D 实芯 1.2
        if(weldStyleName=="立焊"){
            voltage=14+0.05*current-3;
        }else if(weldStyleName=="横焊"){
            if(name=="topFloor"){
                voltage=14+0.05*current;
            }else{
                voltage=14+0.05*current+4;
            }
        }else{
            if(name=="topFloor"){
                voltage=14+0.05*current;
            }else{
                voltage=14+0.05*current+1.5;
            }
        }
    }else if((gas)&&(pulse)&&(wireType==0)){
        //MAG P 实芯 1.2 200以下或者横焊或者立焊 MAG 脉冲电压都要压低
        if(weldStyleName=="立焊"){
            voltage=14+0.05*current-3;
        }else if(weldStyleName=="横焊"){
            if(name=="topFloor"){
                voltage=14+0.05*current;
            }else{
                voltage=14+0.05*current+4;
            }
        }else{
            if(name=="topFloor"){
                voltage=14+0.05*current;
            }else{
                voltage=14+0.05*current+1.5;
            }
        }
    }else if((!gas)&&(!pulse)&&(wireType==0)){
        //CO2 D 实芯 1.2
        if(weldStyleName=="立焊"){
            voltage=14+0.05*current-3;
        }else if(weldStyleName=="横焊"){
            if(name=="topFloor"){
                voltage=14+0.05*current;
            }else{
                voltage=14+0.05*current+4;
            }
        }else{
            if(name=="topFloor"){
                voltage=14+0.05*current;
            }else{
                voltage=14+0.05*current+1.5;
            }
        }
    }else if((!gas)&&(!pulse)&&(wireType==4)){
        //CO2 D 药芯 1.2  药芯 电压锁定
        if(weldStyleName=="立焊"){
            voltage=14+0.05*current+1.5;
        }else if(weldStyleName=="横焊"){
            if(name=="topFloor"){
                voltage=14+0.05*current+2.5;
            }else{
                voltage=14+0.05*current+6;
            }
        }else{
            voltage=14+0.05*current+2.5;
        }
    }else {
        return ERROR_GET_VOLTAGE;
    }
    return voltage;
}

int SysMath::getFeedSpeed(int current){
    int feedspeed;
    if((gas)&&(!pulse)&&(wireType==0)&&(wireDValue==4)){
        //MAG D 实芯 1.2
        feedspeed=0;
    }else if((gas)&&(pulse)&&(wireType==0)&&(wireDValue==4)){
        //MAG P 实芯 1.2
        feedspeed=1;
    }else if((!gas)&&(!pulse)&&(wireType==0)&&(wireDValue==4)){
        //CO2 D 实芯 1.2
        feedspeed=2;
    }else if((!gas)&&(!pulse)&&(wireType==4)&&(wireDValue==4)){
        //CO2 D 药芯 1.2
        feedspeed=3;
    }else if((gas)&&(!pulse)&&(wireType==0)&&(wireDValue==6)){
        //MAG D 实芯 1.6
        feedspeed=4;
    }else if((gas)&&(pulse)&&(wireType==0)&&(wireDValue==6)){
        //MAG P 实芯 1.6
        feedspeed=5;
    }else if((!gas)&&(!pulse)&&(wireType==0)&&(wireDValue==6)){
        //CO2 D 实芯 1.6
        feedspeed=6;
    }else if((!gas)&&(!pulse)&&(wireType==4)&&(wireDValue==6)){
        //CO2 D 药芯 1.6
        feedspeed=7;
    }else{
        return ERROR_GET_FEEDSPEED;
    }
    return FeedSpeedTable[feedspeed][(current+currentAdd)/2];
}

//求解 道面积 存储到pFill开始的内存里
void SysMath::solveA(int num,float s){
    int i=0;
    if(num==1){
        pWeldData->weldFill=s;
    }else{

       /* if(weldStyleName!="水平角焊"){
            for(i=0;i<num-1;i++)
                (*(pWeldData+i)).weldFill=s/(num-1+pF->k);
            (*(pWeldData+i)).weldFill=s/(num-1+pF->k)*pF->k;
        }else{
            (*(pWeldData)).weldFill=s/(num-1+pF->k)*pF->k;
            for(i=1;i<num;i++)
                (*(pWeldData+i)).weldFill=s/(num-1+pF->k);
        }*/
        if(weldStyleName=="水平角焊"){
            (*(pWeldData)).weldFill=s/(num-1+pF->k)*pF->k;
            for(i=1;i<num;i++)
                (*(pWeldData+i)).weldFill=s/(num-1+pF->k);
        }else if(weldStyleName=="横焊"){
            float k;
            k=pF->k-1;
            float s1;
            s1=s/((1+1+k*(num-1))*num/2);
            for(i=0;i<num;i++){
                (*(pWeldData+i)).weldFill=s1*(k*i+1);
            }
        }else{
            for(i=0;i<num-1;i++)
            (*(pWeldData+i)).weldFill=s/(num-1+pF->k);
            (*(pWeldData+i)).weldFill=s/(num-1+pF->k)*pF->k;
        }
    }
}
int SysMath::solveI(int num,int total){
    if(total==1){
        pF->current=pF->current_middle;
    }else if(num==0){
        if(grooveDir){
            pF->current=pF->current_right;
        }else{
            pF->current=pF->current_left;
        }
    }else if(num<(total-1)){
        pF->current=pF->current_middle;
    }else if(num==(total-1)){
        if(grooveDir){
            pF->current=pF->current_left;
        }else{
            pF->current=pF->current_right;
        }
    }
    return pF->current;
}
//分层
int SysMath::solveN(float pH){
    float tempHav;
    int fillFloor_MaxNum=0;
    int fillFloor_MinNum=0;

    int res=0;

    if(qRound(pH)<=0){
        fillFloor->num=topFloor->num=secondFloor->num=0;
#if ENABLE_SOLVE_FIRST
        bottomFloor->height=pGrooveRules->grooveHeight+reinforcement;
        //调用重新匹配第一层
        pF=bottomFloor;
        temp=getWeldFloor();
        if(temp<0) return temp;
#endif
        res=1;
    }else if(qRound(pH)<=topFloor->maxHeight){
        fillFloor->num=secondFloor->num=0;
        topFloor->num=1;
        if(pH>=topFloor->minHeight){
            topFloor->height=pH;
        }else{
            topFloor->height=topFloor->minHeight;
            //不用管剩下的 满足不满足要求
            //tempH=bottomFloor->height+pH-topFloor->height;
            //if(tempH<bottomFloor->minHeight){
            //  return ERROR_HEIGHT;
        }//else
#if ENABLE_SOLVE_FIRST
        bottomFloor->height=tempH;
        //调用重新匹配第一层
        pF=bottomFloor;
        temp=getWeldFloor();
        if(temp<0) return temp;
#endif
        res=2;
        // }
    }else if(qRound(pH)<=(secondFloor->maxHeight+topFloor->maxHeight)){
        secondFloor->num=1;
        fillFloor->num=0;
        topFloor->num=1;
        if(pH>=(secondFloor->minHeight+topFloor->minHeight)){
            topFloor->height=pH*(topFloor->minHeight+topFloor->maxHeight)/(topFloor->minHeight+topFloor->maxHeight+secondFloor->minHeight+secondFloor->maxHeight);
            secondFloor->height=pH-topFloor->height;
            if(topFloor->height<topFloor->minHeight){
                topFloor->height=topFloor->minHeight;
                secondFloor->height=pH-topFloor->height;
            }else if(secondFloor->height<secondFloor->minHeight){
                secondFloor->height=secondFloor->minHeight;
                topFloor->height=pH-secondFloor->height;
            }
        }else{
            secondFloor->height=secondFloor->minHeight;
            topFloor->height=topFloor->minHeight;
            //不用管剩下的 满足不满足要求
            //tempH=pGrooveRules->grooveHeight+reinforcement-secondFloor->height-topFloor->height;
            //if(tempH<bottomFloor->minHeight){
            //   bottomFloor->height= bottomFloor->minHeight;
            //   return ERROR_HEIGHT;
            //  }else{
            //  bottomFloor->height=tempH;
            //}
            //调用重新匹配第一层
#if ENABLE_SOLVE_FIRST
            pF=bottomFloor;
            temp=getWeldFloor();
            if(temp<0) return temp;
            pH=pGrooveRules->grooveHeight+reinforcement-hused;
            secondFloor->height=pH*(secondFloor->minHeight+secondFloor->maxHeight)/(topFloor->minHeight+topFloor->maxHeight+secondFloor->minHeight+secondFloor->maxHeight);
            topFloor->height=pH-secondFloor->height;
            if(secondFloor->height<secondFloor->minHeight){
                secondFloor->height=secondFloor->minHeight;
                topFloor->height=pH-secondFloor->height;
            }else if(topFloor->height<topFloor->minHeight){
                topFloor->height=topFloor->minHeight;
                secondFloor->height=pH-topFloor->height;
            }
#endif
        }
        res=3;
    }else{
        topFloor->num=secondFloor->num=1;
        //都应该是一样的四舍五入取整 否则会变成 小的大于大的
        fillFloor_MinNum=qCeil((pH-topFloor->maxHeight-secondFloor->maxHeight)/fillFloor->maxHeight);
        fillFloor_MaxNum=qFloor((pH-topFloor->minHeight-secondFloor->minHeight)/fillFloor->minHeight);
        //如果最小层数小于最大层数
        if(fillFloor_MinNum<=fillFloor_MaxNum){
            fillFloor->num=fillFloor_MinNum;
            //以最小层数进行平均 获取最高层及第二层层高
            tempHav=pH/(fillFloor->num+2);
            topFloor->height=secondFloor->height=float(qRound(tempHav*5))/5;
            //如果顶层层高不再范围内则优先保证顶层层高
            if((topFloor->height<topFloor->minHeight)||(topFloor->height>topFloor->maxHeight)){
                //限制盖面层高 为预置最大或最小层高
                topFloor->height=topFloor->height<topFloor->minHeight?topFloor->minHeight:topFloor->maxHeight;
                //保证盖面层层高的情况下第二层和填充层平均分配层高
                secondFloor->height=float(qRound(((pH-topFloor->height)/(fillFloor->num+1))*5))/5;
            }
            //如果第二层层高不在范围内
            else if((secondFloor->height<secondFloor->minHeight)||(secondFloor->height>secondFloor->maxHeight)){
                //第二层取最大最小层高
                secondFloor->height=secondFloor->height<secondFloor->minHeight?secondFloor->minHeight:secondFloor->maxHeight;
                //判断盖面层层高是最小值或最大值不能更改，否则，盖面层和填充层一起计算平均层高。
                if((topFloor->height!=topFloor->minHeight)&&(topFloor->height!=topFloor->maxHeight)){
                    topFloor->height=float(qRound(((pH-secondFloor->height)/(fillFloor->num+1))*5))/5;
                    //如果超过最大 则给最大值 如果超过最小则给最小值
                    topFloor->height=topFloor->height<topFloor->minHeight?topFloor->minHeight:topFloor->height>topFloor->maxHeight?topFloor->maxHeight:topFloor->height;
                }
            }
            //将分剩的层高转移给填充层
            fillFloor->height=(pH-secondFloor->height-topFloor->height)/fillFloor->num;
        }else{
            //
            fillFloor->num=fillFloor_MinNum;
            secondFloor->height=secondFloor->minHeight;
            topFloor->height=topFloor->minHeight;
            fillFloor->height=fillFloor->minHeight;
            //不用管剩下的 满足不满足要求
            //tempH=pGrooveRules->grooveHeight+reinforcement-secondFloor->height-topFloor->height-fillFloor->num*fillFloor->height;
            //if(tempH<bottomFloor->minHeight){
            //    bottomFloor->height=bottomFloor->minHeight;
            //     return ERROR_HEIGHT;
            // }else{
            //     bottomFloor->height=tempH;
            // }
            //调用重新匹配第一层
#if ENABLE_SOLVE_FIRST
            pF=bottomFloor;
            temp=getWeldFloor();
            if(temp<0) return temp;
            pH=pGrooveRules->grooveHeight+reinforcement-hused;
            fillFloor->height=(pH-secondFloor->height-topFloor->height)/fillFloor->num;
#endif
        }
        res=4;
    }
    return res;
}


