#ifndef SYSMATH_H
#define SYSMATH_H
#include <QObject>
#include <QObjectList>
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
    //缓存指针
    QList<pointRules* > *pPointRulesLists;
       weldFloorTableRules* pWeldTable;
       //排序指针
       floorRules* pBufWeldRules;
    QJsonObject pJson;
    //焊接位置  平焊 立焊 横焊 水平角焊
    QString weldStyleName;
    //接头形式 T接头 平对接
    QString weldConnectName;
    //坡口形式 V形坡口 单边V形坡口
    QString grooveStyleName;
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
    int startArcZz;
    int startArcZx;

    int stopArcZz;
    int stopArcZx;
    bool returnWay;
    int grooveValue;
    //层内停止时间
    int stopInTime;
    //层间停止时间
    int stopOutTime;
    //计算数据状态
    QString status;
    //函数 有 电流求送丝速度
    int getFeedSpeed(int current);
    //函数 有电流求电压
    float getVoltage(int current);
    //求解A
    void solveA(FloorCondition *p,int num,float s);
    //选取道电流
    int solveI(FloorCondition *p,int num,int total);
    //求层数 输入参数 h剩余层高 各层层高上下限, 输出参数 层数/层高 打底层高是否需要修改的标记
    int solveN(float *pH);
    //计算每层的最大最小填充量
    int getFillMetal(FloorCondition *pF);
    //计算坐标点函数
    //int getPoint(float *lineX,float *lineY,float *startArcX,float *startArcY,int weldNum,FloorCondition *pF);
    //计算 分道
    float getTravelSpeed(FloorCondition *pF,QString str);
    int getWeldFloor(FloorCondition *pF);
    int getWeldNum(FloorCondition *pF,float *s,int weldNum,float reSwingLength);
    //int setGrooveRules(QStringList value);
    //获取横焊和平焊的 摆动频率
    float getSwingSpeed(float maxSpeed);
    int weldMath(int pointNum);
    //void makeJson(QJsonObject* pJson,weldDataType* pWeldData,weldPointType* pWeldPoint);
private:
    //板厚
    float grooveHeight;
    //已经使用的面积
    float sUsedBuf[30];
    //weldLineY
    float hUsed;
    //坡口角度tan1
    float grooveAngel1Tan;
    //坡口角度2tan
    float grooveAngel2Tan;
    //焊丝橫截面积
    float weldWireSquare;
    //最小电流
    int currentMin;
    //最大电流
    int currentMax;
    //焊接层
    int currentFloor;
    //焊接道
    int currentWeldNum;
    //焊接长度
    float weldLength;
    //焊接规范指针
    weldDataType *pWeldData;
    //焊接坐标系统
    weldCoordinateType *pWeldCoordinate;
    //坡口参数指针
    grooveRulesType* pGrooveRule;
    //总焊接道数
    int totalWeldNum;


    //point数量
    int pointNumber;

    float swingLengthBuf[30];

    float weldNumBuf[30];


signals:
    void weldRulesChanged(QString status,QJsonObject value);
};

#endif // MATH_H
