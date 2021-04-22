#ifndef SYSMATH_H
#define SYSMATH_H
#include <QObject>
#include <QString>
#include <QDebug>
#include <QStringList>
#include <QtCore>
#include <QtGlobal>
#include "gloabldefine.h"
#include "groove.h"

class SysMath:public QObject
{
    Q_OBJECT
private:
    //最小电流
    int currentMin;
    //最大电流
    int currentMax;
    //限制条件临时变量
    FloorCondition *pF;
    //当前焊接规范函数
    weldDataType *pWeldData;
    //
    weldPointType *pWeldPoint;
    //
    float hused;
    //
    float sused;
    //
    float s;
    float weldLineYUesd;
    int currentFloor;
    int currentWeldNum;
    int weldNum;
    int weldNumIndex;

    float grooveAngelTan;
    //当前坡口指针
    grooveRulesType *pGrooveRules;
public:
    SysMath();
    ~SysMath();
    weldDataTableType *pWeldDataTable;

    weldDataTableType *pDispWeldDataTable;
    //av
    int weldMath(weldDataTableType *pWeld);
    //焊接位置  平焊 立焊 横焊 水平角焊
    QString weldStyleName;
    //接头形式 T接头 平对接
    QString weldConnectName;
    //坡口形式 V形坡口 单边V形坡口
    QString grooveStyleName;
    //余高
    float reinforcement;
    //溶敷系数 *100
    int meltingCoefficient;
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

    bool weldTravelDir;
    //坡口侧0 非口侧1
    int grooveDir;
    //焊丝橫截面积
    float weldWireSquare;
    //焊丝直径
    //int wireD;
    //分道控制 左右分开调节
    bool controlWeld;
    //顿边
    float rootFace;
    //气体 0co2 1混合气
    bool gas;
    //脉冲 0 无脉冲 1 有脉冲
    bool pulse;
    //焊丝种类 0 碳钢实芯 1药芯
    int wireType;
    int wireDValue;
    int grooveValue;
   //是在顿边里面吗
    int returnWay;
    //层间起弧
    int startArcZz;
    int stopArcZz;
    //层内起弧
    int startArcZx;
    int stopArcZx;

    int stopInTime; //层内停止时间
    int stopOutTime; //层间停止时间
    //
    float weldLength;
    //电流偏移量
    int currentAdd;
    //
    int voltageAdd;
    float totalWeldTime;
    //
    int teachPoint;
    //
    bool teachFirstPoint;
    //
    float checkLeftLength;
    //
    float checkRightLength;
    //电弧跟踪开启
    bool arcAvcEn;
    bool arcSwEn;
    bool arcSwWEn;
    //计算数据状态
    QString status;
    //函数 有 电流求送丝速度
    int getFeedSpeed(int current);
    //函数 有电流求电压
    float getVoltage(int current,QString name);
    //求解A
    void solveA(int num,float s);
    //选取道电流
    int solveI(int num,int total);
    //求层数 输入参数 h剩余层高 各层层高上下限, 输出参数 层数/层高 打底层高是否需要修改的标记
    int solveN(float pH);
    //计算坐标点函数
    //int getPoint(float *lineX,float *lineY,float *startArcX,float *startArcY,int weldNum,FloorCondition *pF);
    //计算 分道
    float getTravelSpeed();
    int getPoint();
    int getWeldFloor();
    int getWeldNum();
    int setGrooveRulesTable(QObject *value,int length);
    float getSwingSpeed(float maxSpeed,weldDataType *p);
    int getLimitedFillMetal();
};

#endif // MATH_H
