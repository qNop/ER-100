#ifndef WELDMATH_H
#define WELDMATH_H

#include <QObject>
#include <QString>
#include <QDebug>
#include <QStringList>
#include <QtCore>
#include <QtGlobal>
#include "gloabldefine.h"
#include "SysMath.h"

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
    //顶层限制条件
    FloorCondition overFloor;

    SysMath* sysMath;

    int grooveValue;
public slots:
    //设置焊接位置
    void setWeldStyle(int value);
    //设置坡口形式
    void setGrooveStyle(int value);
    //设置链接方式
    void setConnectStyle(int value);
    //设置余高
    void setReinforcement(float value);
    //溶敷系数
    void setMeltingCoefficient(int value);
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
    bool setLimited(QObject* value);
    //获取电压
    float getWeldVoltage(int current);
    //设置坡口
    void setGroove(int value);
    //设置往返方式
    void setReturnWay(int value);
    //设置层间起弧偏移
    void setStartArcZz(int value);
    //设置层间收弧偏移
    void setStopArcZz(int value);
    //设置层外起弧偏移
    void setStartArcZx(int value);
    //设置层外收弧偏移
    void setStopArcZx(int value);
    //设置顿边
    void setRootFace(float value);
    //设置层间停止时间
    void setStopInTime(int value);
    //设置层外停止时间
    void setStopOutTime(int value);
    //设置起弧偏移
  //  void setStartx(int value);
    //设置收弧偏移
    //void setStopx(int value);
    //根据电流获取送丝速度
    int getFeedSpeed(int current);
    //根据电流电压行走速度获取道面积
    float getWeldArea(int current,float weldSpeed,float met);
    //求摆动距离
   // float getWeldA(float swing,float swingLeftStayTime,float swingRightStayTime,float weldSpeed,float maxSpeed);
    //求填充高度
    float getWeldHeight(float deep,float bottomWidth,float leftAngel,float rightAngel,int current,float weldSpeed,float met);
signals:
    void grooveRulesChanged(QStringList value);
    void weldRulesChanged(QString status,QJsonObject value);
    void updateWeldMathChanged();
};

#endif // WELDMATH_H
