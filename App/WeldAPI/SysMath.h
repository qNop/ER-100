#ifndef SYSMATH_H
#define SYSMATH_H
#include <QObject>
#include <QString>
#include <QDebug>
#include <QStringList>
#include <QtCore>
#include <QtGlobal>
#include "gloabldefine.h"

/*焊接相关数据结构*/
typedef struct {
    //焊接电流
    int weldCurrent;
    //焊接电压
    float weldVoltage;
    //送丝速度
    float weldFeedSpeed;
    //焊接速度
    float weldTravelSpeed;
    //摆动速度
    float swingSpeed;
    //前停留
    float beforeSwingStayTime;
    //后停留
    float afterSwingStayTime;
    //摆动频率
    float swingHz;
    //摆动宽度
    float swingLength;
    //填充量
    float weldFill;
    //当前道
 //   int currentWeldNum;
    //当前层总道数
  //  int weldNum;
    //当前层数
   // int weldFloor;
}weldDataType;


class SysMath:public QObject
{
    Q_OBJECT
public:
    SysMath();
    ~SysMath();
    int weldMath();
    //焊接位置  平焊 立焊 横焊 水平角焊
    QString weldStyleName;
    //接头形式 T接头 平对接
    QString weldConnectName;
    //坡口形式 V形坡口 单边V形坡口
    QString grooveStyleName;
    //最小电流
    int currentMin;
    //最大电流
    int currentMax;
    //角度转换
    float angel;
    //余高
    float reinforcementValue;
    //溶敷系数 *100
    int meltingCoefficientValue;
    //打底层限制条件
    FloorCondition *bottomFloor;
    //第二层限制条件
    FloorCondition *secondFloor;
    //填充层限制条件
    FloorCondition *fillFloor;
    //盖面层限制条件
    FloorCondition *topFloor;
    //立板层限制条件
    FloorCondition *overFloor;
    //陶瓷衬垫
    int ceramicBack;
    //陶瓷衬垫 深度
    float ceramicBackDeep;
    //陶瓷衬垫 宽度
    float ceramicBackWidth;
    //坡口侧0 非口侧1
    int grooveDirValue;
    //根部间隙
    float rootGap;
    //板厚
    float grooveHeight;
    //板厚差
    float grooveHeightError;
    //坡口角度1 靠近机器人侧
    float grooveAngel1;
    //坡口角度1tan
    float grooveAngel1Tan;
    //坡口角度2 远离机器人侧
    float grooveAngel2;
    //坡口角度2tan
    float grooveAngel2Tan;
    //焊丝橫截面积
    float weldWireSquare;
    //焊丝直径
    int wireDValue;
    //分道控制 左右分开调节
    bool controlWeld;
    //顿边
    float rootFace;
    //气体 0co2 1混合气
    bool gasValue;
    //脉冲 0 无脉冲 1 有脉冲
    bool pulseValue;
    //焊丝种类 0 碳钢实芯 1药芯
    int wireTypeValue;
    int grooveValue;
   //是在顿边里面吗
    int returnWay;

    int startArcZz;
    int startArcZx;
    int startX;

    int stopArcZz;
    int stopArcZx;
    int stopX;

    int stopInTime; //层内停止时间
    int stopOutTime; //层间停止时间

    float weldLength;

    //计算数据状态
    QString status;
    //函数 有 电流求送丝速度
    int getFeedSpeed(int current);
    //函数 有电流求电压
    float getVoltage(int current);
    //求解A
    void solveA(weldDataType *pWeldData,FloorCondition *p,int num,float s);
    //选取道电流
    int solveI(FloorCondition *p,int num,int total);
    //求层数 输入参数 h剩余层高 各层层高上下限, 输出参数 层数/层高 打底层高是否需要修改的标记
    int solveN(float *pH,float *hused,float *sused,float *weldLineYUesd,int *currentFloor,int *currentWeldNum);
    //计算每层的最大最小填充量
    int getFillMetal(FloorCondition *pF);
    //计算坐标点函数
    //int getPoint(float *lineX,float *lineY,float *startArcX,float *startArcY,int weldNum,FloorCondition *pF);
    //计算 分道
    // float getTravelSpeed(FloorCondition *pF,QString str,int *weldCurrent,float *weldVoltage,float *weldFeedSpeed,float *swingSpeed,float *weldTravelSpeed,float *weldFill,QString *status,float *swingHz);
    float getTravelSpeed(FloorCondition *pF,QString str,weldDataType *pWeldData,QString *status);
    int getWeldFloor(FloorCondition *pF,float *hused,float *sused,float *weldLineYUesd,int *currentFloor,int *currentWeldNum);
    // int getWeldNum(FloorCondition *pF,int *weldCurrent,float *weldVoltage,float *weldFeedSpeed,float *swingSpeed, float *weldTravelSpeed,float *weldFill,float *s,int count,int weldNum,int weldFloor,QString *status);
    int getWeldNum(FloorCondition *pF,weldDataType *pWeldData,float *s,int currentWeldNum,int weldNum,int weldFloor,QString *status);
    int setGrooveRules(QStringList value);
    //获取横焊和平焊的 摆动频率
   // float getSwingSpeed(float swing,float swingLeftStayTime,float swingRightStayTime,float weldSpeed,float maxSpeed,float *swingHz);
    float getSwingSpeed(weldDataType *pWeldData,float maxSpeed);
signals:
    void weldRulesChanged(QStringList value);
};

#endif // MATH_H
