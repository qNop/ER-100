#ifndef SYSINFOR_H
#define SYSINFOR_H

#include <QObject>
#include <QString>
#include <QDebug>
#include <QThread>
#include <QTimer>
#include <QProcess>
#include <QtQml/QQmlListProperty>

class SysInfor :public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList cpuInfor READ cpuInfor WRITE setCpuInfor NOTIFY cpuInforChanged)
    Q_PROPERTY(QStringList memoryInfor READ memoryInfor WRITE setMemoryInfor NOTIFY memoryInforChanged)
    Q_PROPERTY(QStringList deviceSizeInfor READ deviceSizeInfor WRITE setDeviceSizeInfor NOTIFY deviceSizeInforChanged)
public:
    explicit SysInfor();
    ~SysInfor();
    void setCpuInfor(QStringList infor);
    void setMemoryInfor(QStringList infor);
    void setDeviceSizeInfor(QStringList infor);
private:
    //cpu1 使用率 cpu2 使用率 cpu3 使用率 cpu4使用率
    QStringList cpu;
    //内存 使用率 使用MB 总共MB
    QStringList memory;
    //设备存储 使用率 使用MB 可用MB  总计MB
    QStringList deviceSize;

    int totalNew, idleNew, totalOld, idleOld;
    int cpuPercent;
  int memoryAll,memoryFree,memoryUse,memoryPercent;
    QProcess *process;

private slots:
    void ReadData();
public slots:
    //获取Cpu信息
    QStringList cpuInfor();
    //获取Memory信息
    QStringList memoryInfor();
    //获取 设备存储信息
    QStringList deviceSizeInfor();
signals:
    void  cpuInforChanged(QStringList infor);
    void  memoryInforChanged(QStringList infor);
    void  deviceSizeInforChanged(QStringList infor);
};

#endif // SYSINFOR_H
