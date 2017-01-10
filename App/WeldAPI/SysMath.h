#ifndef SYSMATH_H
#define SYSMATH_H
#include <QObject>
#include <QString>
#include <QDebug>
#include <QStringList>
#include <QtCore>
#include <QtGlobal>
#include "gloabldefine.h"

class SysMath:public QObject
{
    Q_OBJECT
public:
    SysMath();
    ~SysMath();
    int weldMath();
    //焊接位置  平焊 立焊 横焊 水平角焊
    QString weldDirName;
    //接头形式 T接头 平对接
    QString weldConnectName;
    //坡口形式 V形坡口 单边V形坡口
    QString GrooveStyleName;
    //余高
    int reinforcementValue;
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
    //坡口角度1
    float grooveAngel1;
    //坡口角度1tan
    float grooveAngel1Tan;
    //坡口角度2
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
    float p;
    //气体 0co2 1混合气
    bool gasValue;
    //脉冲 0 无脉冲 1 有脉冲
    bool pulseValue;
    //焊丝种类 0 碳钢实芯 1药芯
    int wireTypeValue;
        int grooveValue;
    //计算数据状态
    QString status;
    //函数 有 电流求送丝速度
    int getFeedSpeed(int current);
    //函数 有电流求电压
    float getVoltage(int current);
    //求解A
    void solveA(float *pFill,FloorCondition *p,int num,float s);
    //选取道电流
    int solveI(FloorCondition *p,int num,int total);
    //求层数 输入参数 h剩余层高 各层层高上下限, 输出参数 层数/层高 打底层高是否需要修改的标记
    int solveN(float *pH,float *hused,float *sused,float *weldLineYUesd,float *startArcZ,int *currentFloor,int *currentWeldNum);
    //计算每层的最大最小填充量
    int getFillMetal(FloorCondition *pF);
    //计算 分道
    int getWeldFloor(FloorCondition *pF,float *hused,float *sused,float *weldLineYUesd,float *startArcZ,int *currentFloor,int *currentWeldNum);
    int getWeldNum(FloorCondition *pF,int *weldCurrent,float *weldVoltage,float *weldFeedSpeed,float *swingSpeed, float *weldTravelSpeed,float *weldFill,float *s,int count,int weldNum,int weldFloor,QString *status,float swingLengthOne);
    int setGrooveRules(QStringList value);
    //获取横焊和平焊的 摆动频率
    float getSwingSpeed(float swing,float swingLeftStayTime,float swingRightStayTime,float weldSpeed,float maxSpeed,float *swingHz);
signals:
    void weldRulesChanged(QStringList value);
};

#endif // MATH_H
