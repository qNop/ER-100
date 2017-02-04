/*
 *
 *
 *
 *
 */
#include "AppConfig.h"
#include <QFile>
#include <QDir>

#include <QDebug>
#include <QTime>
#include <QDateTime>

#include "gloabldefine.h"
#include <sys/ioctl.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>


/*
 **********************************************************************************获取配置ini指针
 */

AppConfig::AppConfig(){

}

AppConfig::~AppConfig(){
    qDebug()<<"AppConfig::REMOVE";
}

/*
 ************************************************************************************系统背光
 */
void AppConfig::setbackLight(int value){
    QString s;
    s="echo ";
    s+=QString::number(value*2);
    //陈世豪的内核
    //s+=" > /sys/devices/platform/pwm-backlight.0/backlight/pwm-backlight.0/brightness";
    //TKSW内核
    s+=EROBOWELDSYS_PLATFORM?" > /sys/devices/platform/pwm-backlight.2/backlight/pwm-backlight.2/brightness":" > /sys/devices/platform/pwm-backlight.0/backlight/pwm-backlight.0/brightness";
    system(s.toLatin1().data());
    qDebug() <<"AppConfig::Backlight Value = "<<value;
}
/*
 * set led status
 */
void AppConfig::setleds(QString status){
    QString s;
    int i,flag,temp;
    if(status=="setup")       flag=0;
    else if(status=="start") flag=0x01;
    else if(status=="stop")  flag=0x02;
    else if(status=="ready")flag=0x04;
    else if(status=="all")      flag=0x07;
    else flag=0xFFFFFFFF;
    for(i=0;i<3;i++){
        s="echo ";
        temp=flag&0x01;
        s+=QString::number(temp);
        s+=" > /sys/class/leds/";
        if(i==0) s+=EROBOWELDSYS_PLATFORM?"start_led":"WeldSys_Start_Led";
        else if(i==1) s+=EROBOWELDSYS_PLATFORM?"stop_led":"WeldSys_Stop_Led";
        else s+=EROBOWELDSYS_PLATFORM?"ready_led":"WeldSys_Ready_Led";
        s+="/brightness";
        flag>>=1;
        system(s.toLatin1().data());
        qDebug()<<s;
    }
}
/*
 * 设置系统时间 格式为 date -s "2016-05-03 10:10:10" [[[[[YY]YY]MM]DD]hh]mm[.ss]
 */
void AppConfig::setdateTime(QStringList time){
    QString s;
    int i;
    for(i=0;i<time.length();i++){
        if(time[i].toInt()<10){
            time[i]="0"+time[i];
        }
    }
    time.insert(0,"20");
    time.insert(6,".");
    s="date -s ";
    s+=time.join("");
    qDebug()<<s;
    //调用系统命令
    system(s.toLatin1().data());
}


void AppConfig::setlanguage(QString str){
    qDebug()<<"AppConfig::setlanguage "<<str;
    if(str=="EN"){
        QLocale::setDefault(QLocale(QLocale::English,QLocale::UnitedStates));
    }else if(str=="CH"){
        QLocale::setDefault(QLocale(QLocale::Chinese,QLocale::China));
    }
}


bool AppConfig::screenShot(QQuickWindow *widget){
    QPixmap pixmap = QPixmap::fromImage(widget->grabWindow());
    QString dateTime=QDateTime::currentDateTime().toString("yyMMdd-hhmm");
    QString name="screenShot/"+dateTime+".png";
    QFile f(name);
    qDebug()<<name;
    f.open(QIODevice::WriteOnly);
    if(f.isOpen()) {
        pixmap.save(&f, "PNG");
        return true;
    }else
        return false;
}
