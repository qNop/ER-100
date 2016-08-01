#ifndef WELDMATH_H
#define WELDMATH_H

#include <QObject>
#include <QString>
#include <QDebug>
#include <QStringList>
#include <QtCore>
#include <QtGlobal>

#define   PI   3.141592654

struct FloorLimitedCondition
{       //电流
        int current;
        //层高限制
        float height;
        //摆动距离坡口左侧距离
        float swingLeftLength;
        //摆动距离坡口右侧距离
        float swingRightLength;
        //最大摆动宽度
        float maxSwingLength;
        //分道摆动间隔 同一层 不同焊道之间间隔距离
        float weldSwingSpacing;
        //左侧摆动停留时间
        float swingLeftStayTime;
        //右侧摆动停止时间
        float swingRightStayTime;
        //总停留时间
        float totalStayTime;
        //末道填充与初道填充比 也是用于 多层多道
        float k;
        //最大填充量
        float maxFillMetal;
        //最小填充量
        float minFillMetal;
};

class WeldMath:public QObject
{
    Q_OBJECT
    //余高
    Q_PROPERTY(int reinforcement READ reinforcement WRITE setReinforcement)
    //溶敷系数
    Q_PROPERTY(int meltingCoefficient READ meltingCoefficient WRITE setMeltingCoefficient)
    //weld model
    Q_PROPERTY(QStringList weldRules READ weldRules WRITE setWeldRules NOTIFY weldRulesChanged)
    //groove
    Q_PROPERTY(QStringList grooveRules READ grooveRules WRITE setGrooveRules NOTIFY grooveRulesChanged)
    //gas
    Q_PROPERTY(int gas READ gas WRITE setGas NOTIFY gasChanged)
    //pulse
    Q_PROPERTY(int pulse READ pulse WRITE setPulse NOTIFY pulseChanged)
    //wireType
    Q_PROPERTY(int wireType READ wireType WRITE setWireType NOTIFY wireTypeChanged )
    //焊丝直径
    Q_PROPERTY(int wireD READ wireD WRITE setWireD NOTIFY wireDChanged)
public:
    WeldMath();
    int reinforcement();
    int meltingCoefficient();
    //获取坡口参数
    QStringList grooveRules();
    QStringList weldRules();
    //函数 用计算函数排道
    int weldMathFunction();
    //读取气体
    int gas();
    //脉冲
    int pulse();
    //焊丝种类
    int wireType();
    //焊丝直径
    int wireD();
private:
    //余高
    int reinforcementValue;
    //溶敷系数 *100
    int meltingCoefficientValue;
     //打底层限制条件
    FloorLimitedCondition bottomFloor;
    //第二层限制条件
    FloorLimitedCondition secondFloor;
    //填充层限制条件
    FloorLimitedCondition fillFloor;
    //盖面层限制条件
    FloorLimitedCondition topFloor;
    //根部间隙
    float rootGap;
    //板厚
    float grooveHeight;
    //板厚差
    float grooveHeightError;
    //坡口角度1
    float grooveAngel1;
    //坡口角度2
    float grooveAngel2;
    //焊丝直径
    float wireDValue;
    //最大焊接速度
    float maxWeldSpeed;
    //最小焊接速度
    float minWeldSpeed;
    //最大摆动频率
    float maxSwingHz;
    //最小摆动频率
    float minSwingHz;
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
     int gasValue;
     //脉冲 0 无脉冲 1 有脉冲
     int pulseValue;
     //焊丝种类 0 碳钢实芯 1药芯
     int wireTypeValue;
public slots:
    //设置余高
    void setReinforcement(int value);
    //溶敷系数
    void setMeltingCoefficient(int value);
    //model
    void setWeldRules(QStringList value);
    //设置坡口参数
    void setGrooveRules(QStringList value);
    //设置气体
    void setGas(int value);
    //设置脉冲
    void setPulse(int value);
    //设置焊丝种类
    void setWireType(int value);
    //设置焊丝直径
    void setWireD(int value);
signals:
    void grooveRulesChanged(QStringList value);
    void weldRulesChanged(QStringList value);
    void gasChanged(int value);
    void pulseChanged(int value);
    void wireTypeChanged(int value);
    void wireDChanged(int value);
};

#endif // WELDMATH_H
