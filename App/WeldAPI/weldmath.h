#ifndef WELDMATH_H
#define WELDMATH_H

#include <QObject>
#include <QString>
#include <QDebug>
#include <QStringList>

//class WeldRules{
//public:
//    WeldRules();
//    QString ID() const;
//    QString C1() const;
//    QString C2() const;
//    QString C3() const;
//    QString C4() const;
//    QString C5() const;
//    QString C6() const;
//    QString C7() const;
//    QString C8() const;
//    QString C9() const;
// private:
//    QString M_ID;
//    QString M_C1;
//    QString M_C2;
//    QString M_C3;
//    QString M_C4;
//    QString M_C5;
//    QString M_C6;
//    QString M_C7;
//    QString M_C8;
//    QString M_C9;
//};

class WeldMath:public QObject
{
    Q_OBJECT
    //余高
    Q_PROPERTY(float reinforcement READ reinforcement WRITE setReinforcement)
    //溶敷系数
     Q_PROPERTY(float meltingCoefficient READ meltingCoefficient WRITE setMeltingCoefficient)
    //weld model
  //  Q_PROPERTY(QStringList weldRules READ weldRules WRITE setWeldRules NOTIFY weldRulesChanged)
public:
    WeldMath();
    float reinforcement();
    float meltingCoefficient();
  //  QStringList weldRules();
private:
    //model
   // QMap<QString,QString,QString,QString,QString,QString,QString,QString,QString,QString> rulesMap;
    //余高
    float reinforcementValue;
    //溶敷系数
    float meltingCoefficientValue;

public slots:
    //设置余高
    void setReinforcement(float value);
    //溶敷系数
    void setMeltingCoefficient(float value);
    //model
 //   void setWeldRules(QStringList value);
signals:
  //  void weldRulesChanged(QStringList value);
};

#endif // WELDMATH_H
