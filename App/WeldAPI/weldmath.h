#ifndef WELDMATH_H
#define WELDMATH_H


#include <QObject>
#include <QString>
#include <QDebug>

class WeldMath:public QObject
{
    Q_OBJECT
    //余高
    Q_PROPERTY(float reinforcement READ reinforcement WRITE setReinforcement)
    //溶敷系数
     Q_PROPERTY(float meltingCoefficient READ meltingCoefficient WRITE setMeltingCoefficient)
    //排道计算函数

public:
    WeldMath();
    float reinforcement();
    float meltingCoefficient();
private:
    //余高
    float reinforcementValue;
    //溶敷系数
    float meltingCoefficientValue;
public slots:
    //设置余高
    void setReinforcement(float value);
    //溶敷系数
    void setMeltingCoefficient(float value);
signals:


};

#endif // WELDMATH_H
