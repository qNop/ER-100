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
#include "ERModbus.h"
#include "groove.h"


class WeldMath:public QObject
{
    Q_OBJECT
public:
    WeldMath();
    ~WeldMath();
    //内部数据列表
    weldDataTableType weldDataTable[MAX_TEACHPOINT+1];
    //坡口参数列表
    //grooveRulesType grooveRulesTable[MAX_TEACHPOINT+1];
    //显示数据列表
    weldDataTableType dispWeldDataTable;
    //
    QList<QVariant> qJsonList;
    QJsonObject pJson;
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
   // FloorCondition overFloor;
    //算法指针
    SysMath* sysMath;
    //坡口结构
    groove *pGroove;

    QTimer *pTimer;

    QTimer *pSchedule;

    bool readSet;

    weldADDType weldAdd;
    //0 kongxian 1:pokoujiance 2:hanjie
    int welding;

    float lastMotoPoint;
#ifdef USE_MODBUS
    //Modbus指针
    ERModbus *pERModbus;
    void doError(int e1,int e2,int e3,int e4);

    QString sysStatus;

    //错误代码保存
    uint64_t errorCode;
    //坡口列表索引
    int grooveIndex;
    //焊接规范索引
    int weldIndex;
    //钥匙开关
    int changeUserFlag;
    //修补焊道标志
    bool weldFix;
    //当前行走轴坐标
   // float travelPointZ;
    //电弧跟踪开启
    bool arc_on;

    modBusWeldType lastWeldData;
#endif

    void doControlSatus(int s1,int s2);
    int grooveValue;

    QStringList limitedString;

    motoPointType moto;
    teachSetType teachSet;
    void sendWeldRules(void);

    int currentFloor;
    int currentNum;
    int totalNum;
    //坡口启始坐标 结束坐标
    float startZ;
    float stopZ;

    //
    float startExternZ;
    float stopExternZ;

    float restDeepA;
    float restDeepB;

    float radius;

    bool fixWeld;

    bool motoStatus;

    int teachPointNum;
    int teachModel;
    int firstPoint;

private slots:
#ifdef USE_MODBUS
    void modbusSlot(QList<int> value);
#endif
    void timeSolt(void );

    void getWeldDataRules();

    void scheduleSolt(void);
public slots:
   void setFixWeld(bool ok);
   void setFixPara(int a,int b,int c,int d,int e);
    //设置焊接相关参数
    int setPara(QString name,int value,bool send,bool save);
    //设置坡口参数
    int setGrooveRulesTable(QObject *value,int index);
    //设置限制条件
    bool setLimited(QObject* value);
    //
    QStringList getLimitedMath(QObject* value);
    //
    void readVersion();

    int getWeldMath();

    void setSysStatus(QString status);

    void getDateTime(void);

    void getMotoPoint(bool status);

    void getWeldLength(void);

    void getGrooveTable(void);

    void setDateTime(QStringList dateTime);

    bool sendWeldData(QObject *value);

    void setPath(QList<int> value);

    void setMoto(QList<int> value);

    void initWeldMath();

    //void setTeachSet(int point,int mode,int firstPoint,int );

#ifdef USE_MODBUS
    /***Modbus******************************/
#endif
signals:
    void er100_UpdateWeldRules(QList<QVariant> value);

    void er100_UpdateWeldLength(float value);
#ifdef USE_MODBUS
    //通讯错误
    void er100_SysError(int index,int status);
    //
    void er100_SysStatus(QString status);
    //
    void er100_Key(int flag);
    //
    void er100_TeachSet(QList<int> value);

    void er100_TeachPointNumChanged(int value);
    //
    void er100_MotoPoint(QList<int>value);
    //改变焊接规范
   void er100_changeWeldRules();
   //更新坡口数据表
   void er100_updateGrooveTable(QJsonObject groove);
   //发送焊接规范
   void er100_sendWeldRules();
   //读系统时间
   void er100_readDateTime();
   //
   void er100_Version(int code1,int code2,int code3);

   void er100_changeWeldTableIndex(int index);

   void er100_GetControlStatus(QList<int> value);
#endif

};

#endif // WELDMATH_H
