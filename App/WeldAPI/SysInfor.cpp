#include "SysInfor.h"
#define MB (1024 * 1024)
#define KB (1024)

SysInfor::SysInfor()
{
    totalNew = idleNew = totalOld = idleOld = 0;
    cpuPercent = 0;
    process = new QProcess(this);
    timer=new QTimer(this);
    connect(timer,SIGNAL(timeout()),this,SLOT(TimerTrigger()));
    connect(process,SIGNAL(readyRead()),this,SLOT(ReadData()));
}

QStringList SysInfor::cpuInfor()
{
    if( (process->state() == QProcess::NotRunning)&&(process)) {
        totalNew = idleNew = 0;
        process->start("cat /proc/stat");
    }
    QString s="cat /proc/stat";
    QStringList cpud=s.split(" ");
    status="cpu";
     timer->start(100);
    return cpud;
}
SysInfor::~SysInfor(){
    while(process->state()==QProcess::Running);
    delete process;
    timer->stop();
    delete timer;
    qDebug()<<"SysInfor::REMOVE";
}

QStringList SysInfor::memoryInfor()
{
    if( (process->state() == QProcess::NotRunning)&&(process)) {
        process->start("cat /proc/meminfo");
    }
    QString s="cat /proc/meminfo";
    QStringList cpud=s.split(" ");
    status="meminfo";

    return cpud;
}

QStringList SysInfor::deviceSizeInfor()
{
    if( (process->state() == QProcess::NotRunning)&&(process)){
        process->start("df -h");
    }
    QString s="df -h";
    QStringList cpud=s.split(" ");
     status="device";
    return cpud;
}

int SysInfor::cpuTemp(){
    if( (process->state() == QProcess::NotRunning)&&(process)){
        process->start("cat /sys/devices/virtual/thermal/thermal_zone0/temp");
    }
    status="temp";
    return 1;
}

void SysInfor::setCpuInfor(QStringList infor){Q_UNUSED(infor)}
void SysInfor::setMemoryInfor(QStringList infor){Q_UNUSED(infor)}
void SysInfor::setDeviceSizeInfor(QStringList infor){Q_UNUSED(infor)}
void SysInfor::setCpuTemp(int temp){Q_UNUSED(temp)}

void SysInfor::TimerTrigger(){
    if(status== "cpu"){
        memoryInfor();
        timer->start(100);
    }else if(status== "meminfo"){
        cpuTemp();
    }
}

void SysInfor::ReadData()
{
    QStringList list;
    while (!process->atEnd()) {
        QString s = QLatin1String(process->readLine());
        if (s.startsWith("cpu")) {
            list = s.split(" ");
            idleNew = list.at(5).toInt();
            foreach (QString value, list) {
                totalNew += value.toInt();
            }
            int total = totalNew - totalOld;
            int idle = idleNew - idleOld;
            cpuPercent = 100 * (total - idle) / total;
            totalOld = totalNew;
            idleOld = idleNew;
            s=QString("Cpu:%1").arg(cpuPercent);
            list=s.split(":");
            emit cpuInforChanged(list);        
            break;
        } else if (s.startsWith("MemTotal")) {
            s = s.replace(" ", "");
            s = s.split(":").at(1);
            memoryAll = s.left(s.length() - 3).toInt() / KB;
        } else if (s.startsWith("MemFree")) {
            s = s.replace(" ", "");
            s = s.split(":").at(1);
            memoryFree = s.left(s.length() - 3).toInt() / KB;
        } else if (s.startsWith("Buffers")) {
            s = s.replace(" ", "");
            s = s.split(":").at(1);
            memoryFree += s.left(s.length() - 3).toInt() / KB;
        } else if (s.startsWith("Cached")) {
            s = s.replace(" ", "");
            s = s.split(":").at(1);
            memoryFree += s.left(s.length() - 3).toInt() / KB;
            memoryUse = memoryAll - memoryFree;
            memoryPercent = 100 * memoryUse / memoryAll;
            s=QString("memory:%1:%2:%3").arg(memoryPercent).arg(memoryUse).arg(memoryAll);
            list=s.split(":");
            emit memoryInforChanged(list);
            break;
        }
        else if (s.startsWith("/dev/root")) {
            list=s.split(" " ,QString::SkipEmptyParts);
            qDebug()<<list;
        }
       if(status=="temp"){
         emit cpuTempChanged(s.toInt());
           break;
         }

    }
}
