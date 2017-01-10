#ifndef WELDMATH_H
#define WELDMATH_H

#include <QObject>
#include <QString>
#include <QDebug>
#include <QStringList>
#include <QtCore>
#include <QtGlobal>
#include "gloabldefine.h"
#include "verticalmath.h"
#include "flatmath.h"
#include "horizontalmath.h"
#include "filletmath.h"

class WeldMath:public QObject
{
    Q_OBJECT
public:
    WeldMath();
private:
    FloorCondition bottomFloor0;
    //打底层限制条件
    FloorCondition bottomFloor;
    //第二层限制条件
    FloorCondition secondFloor;
    //填充层限制条件
    FloorCondition fillFloor;
    //盖面层限制条件
    FloorCondition topFloor;

    verticalMath vertical;

    flatMath  flat;

    horizontalMath horizontal;

    filletMath fillet;

    int grooveValue;
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
    //设置陶瓷衬垫形式(int value)
    void setCeramicBack(int value);
    //设置坡口侧非坡口侧  陶瓷衬垫起弧时必须在坡口侧
    void setGrooveDir(bool value);
    //设置限制条件
    void setLimited(QStringList value);
    //设置坡口
    void setGroove(int value);
    //根据电流获取送丝速度
    int getFeedSpeed(int current);
     //根据电流电压行走速度获取道面积
    float getWeldArea(int current,float weldSpeed,float k,float met);
    //求摆动距离
    float getWeldA(float swing,float swingLeftStayTime,float swingRightStayTime,float weldSpeed,float maxSpeed);
    //求填充高度
    float getWeldHeight(float deep,float bottomWidth,float leftAngel,float rightAngel,int current,float weldSpeed,float k,float met);
signals:
    void grooveRulesChanged(QStringList value);
    void weldRulesChanged(QStringList value);
    void updateWeldMathChanged();
};

#endif // WELDMATH_H
