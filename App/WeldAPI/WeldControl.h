#ifndef WELDCONTROL_H
#define WELDCONTROL_H

#include <QObject>
#include <WeldMath.h>
#include <ERModbus.h>
#include <DoError.h>

class WeldControl:public QObject
{
    Q_OBJECT
public:
    WeldControl();
    ~WeldControl();
private:
    //焊接算法
    WeldMath* pWeldMath;
    //算法指针
    SysMath* pSysMath;
    //modbus指针
    ERModbus* pModbus;
    //doError
    DoError * pDoError;
    //系统定时器
    QTimer weldControlTimer;
    //系统状态
    QString sysStatus;
    //错误代码
    long long errorCode;
public slots:

    //设置焊接位置
    void setWeldStyle(int value);
    //设置坡口形式
    void setGrooveStyle(int value);
    //设置链接方式
    void setConnectStyle(int value);
    //设置陶瓷衬垫形式(int value)
    void setCeramicBack(int value);

    //示教模式
    void setTeachMode(int value);
    //焊接始终端检测
    void setWeldStartStop(int value);
    //示教第一点位置
    void setTeachFirstPoint(int value);
    //示教点数
    void setTeachPointNum(int value);
    //weldLength
    void setWeldLength(int value);
    //坡口检测点左侧距离
    void setGrooveCheckLeftLength(int value);
    //坡口检测点右侧距离
    void setGrooveCheckRightLength(int value);

    //头部摆动方式
    void setSwingWay(int value);
    //设置干伸长
    void setWeldOutLength(int value);
    //焊接电流偏置
    void setWeldCurrentOffset(int value);
    //焊接电压偏置
    void setWeldVoltageOffset(int value);
    //提前送气时间
    void setGasBeforeWeld(int value);
    //滞后送气时间
    void setGasAfterWeld(int value);
    //起弧停留时间
    void setStartArcStatyTime(int value);
    //收弧停留时间
    void setStopArcStatyTime(int value);
    //起弧电流
    void setStartArcCurrent(int value);
    //起弧电压
    void setStartArcVoltage(int value);
    //收弧电流
    void setStopArcCurrent(int value);
    //收弧电压
    void setStopArcVoltgae(int value);
    //回烧电压补偿
    void setBrunBackVoltage(int value);
    //回烧时间1
    void setBrunBackTime1(int value);
    //回烧时间2
    void setBrunBackTime2(int value);
    //起弧停留时间
    void setStartArcTime(int value);
    //起弧摆动速度
    void setStartArcSwingSpeed(int value);

    //设置余高
    void setReinforcement(float value);
    //溶敷系数
    void setMeltingCoefficient(int value);
    //设置气体
    void setGas(int value);
    //设置脉冲
    void setPulse(int value);
    //设置焊丝种类
    void setWireType(int value);
    //设置焊丝直径
    void setWireD(int value);
    //设置坡口侧非坡口侧  陶瓷衬垫起弧时必须在坡口侧
    void setGrooveDir(bool value);
    //获取电压
    //float getWeldVoltage(int current);
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
    //设置坡口参数
    bool setGrooveRules(int index, QObject *obj,bool ok);
    //设置限制条件
    bool setLimited(QObject *value);
    /*以下是Modbus设置*/
    //modbus 返回帧分析
    void modbusReply(QList< int > reply);
    //获取坡口参数 ["R","150","10"]
    void getGrooveData();
    //获取当前焊道号["R","200","1"]
    void getCurrentWeldNum();
    //获取操作盒端设置["R","99","6"]
    void getHMIset();
    //获取系统状态["R","0","5"]
    void getSysStatus();
    //获取钥匙开关状态["R","25","1"]
    void getKeyStatus();
    //获取焊接长度["R","104","1"]
    void getWeldLength();
    //获取系统时间["R","510","6"]
    void getSysDateTime();
    //获取各电机当前位置["R","1022","6"]
    void getMotoInfo();
    //设置电机信息["W","26","20"]
    void setMotoInfo(QList<int> qList);
    //获取版本信息
    void getVersionInfo();
    //写焊接规范

    //写系统日期,时间["W","510","6"]
    void setSysDateTime(QStringList dateTime);
    //系统状态改变为端部暂停态["W","0","1","5"]
    void setSysStatusStop();
    //写系统状态空闲 ["W","0","1","0"]
    void setSysStatusIdle();
    //写登陆标志["W","25","1","2"]
    void setSysStatusOk();
    //设置示教 坡口宽度跟踪 关闭 ["W",“98”,“1”,“0”]
    void setTeachSwingOff();

    //获取系统时间日期
    //坡口参数表格无数据错误
    void setGrooveTableNullError();
    //焊接表格无数据错误
    void setWeldTableNullError();
    //焊接规范生成错误
    void setMakeWeldRulesError();
    //下发规范
    void downLoadWeldRules();

    QStringList getLimitedMath(QObject* value);

signals:
    //系统状态改变
    void  upDateSysStatus(QString status);
    //输出系统异常
    void sysError(int errorCode);
    //输出更新坡口参数信号
    void updateGrooveData(QJsonObject jsonObject);
    //输出更新
    void errorMath(long long errorCode);
    void updateError(QString cmd,QJsonObject jsonObject);
    void updateHistroy(QString cmd,QJsonObject jsonObject);
    //更新时间
    void updateDateTime(QStringList qList);
    //更新teachset
    void updateTeachSet(QJsonObject jsonObject);
    void updateRockWay(QJsonObject jsonObject);
    //更新钥匙开关状态
    void updateKeyStatus(bool status);
    //更新电机位置
    void updateMotoPoint(QJsonObject jsonObject);
    //更新版本号码
    void updateVersion(QObject* obj);
};

#endif // WELDCONTROL_H
