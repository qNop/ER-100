#ifndef FLATMATH_H
#define FLATMATH_H
#include <QObject>
#include <QString>
#include <QDebug>
#include <QStringList>
#include <QtCore>
#include <QtGlobal>
#include <gloabldefine.h>

class flatMath:public QObject
{
    Q_OBJECT
public:
    flatMath();
    ~flatMath();
    int weldMath();
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
    //顿边
    float p;
    //函数 用打底后剩余高度  填充层最大高度 盖面高度 余高 求中间层的填充层数 填充层平均层高 盖面层高
    void getRulesOfFill();
    //函数 有 电流求送丝速度
    int getFeedSpeed(int current);
    //函数 有电流求电压
    float getVoltage(int current);
    // 函数 有摆幅求摆频
    int getSwingHz(int swing,int floor,float stayTime);
    //气体 0co2 1混合气
    bool gasValue;
    //脉冲 0 无脉冲 1 有脉冲
    bool pulseValue;
    //焊丝种类 0 碳钢实芯 1药芯
    bool wireTypeValue;
    //计算数据状态
    QString status;
    //计算第一层
    void firstFloorFunc();
    //计算填充层
    void FloorFunc(FloorCondition *pF);
    //计算盖面层
    void topFloorFunc();
    //求解A
    void solveA(float *pFill,FloorCondition *p,int num,float s);
    //选取道电流
    int solveI(FloorCondition *p,int num,int total);
    //求层数 输入参数 h剩余层高 各层层高上下限, 输出参数 层数/层高 打底层高是否需要修改的标记
    int solveN(float *pH);
    //每层层高变量
    float h;
    float sUsed;
    float hUsed;
    float startArcz;
    int currentWeldNum;
    int floorNum;
    float weldLineYUesd;

    int grooveValue;
    void setGrooveRules(QStringList value);
signals:
    void weldRulesChanged(QStringList value);
};

#endif // FLATMATH_H
