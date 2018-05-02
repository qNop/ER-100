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
    ~WeldMath();
    SysMath* sysMath;

       int grooveValue;

       //陶瓷衬垫层限制条件
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
private:
    //数据参数总表
    pointRules pointRulesData[30];//数据备份缓冲区

    floorRules bufWeldRules;
    //数据参数序表
    QList<pointRules* > pointRulesList;


    weldFloorTableRules weldTable;

    int grooveRulesPoint;

    QStringList limitedString;

    QList<QVariant> pJsonList;

    void getMathGrooveRule(int index,QObject* obj,grooveRulesType* p);

    void makeJson(QJsonObject *pJson, weldDataType *pWeldData,weldCoordinateType *pWeldCoordinate);

    int getGrooveIndex(int index,int max);

    int count;

public slots:
    bool setGrooveRules(int index,QObject *obj,bool ok);
    bool setLimited(QObject *value);
    QStringList getLimitedMath(QObject* value);
signals:
    void grooveRulesChanged(QStringList value);
    void weldRulesChanged(QString status,QList<QVariant> jsonObject);
    void updateWeldMathChanged();
};

#endif // WELDMATH_H
