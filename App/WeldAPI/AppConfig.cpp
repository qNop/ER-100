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
 ********************************************************************************检测文件是否存在
 */
bool File_Is_Exist(QString Qfilename){
    QFile tempfile(Qfilename);
    return tempfile.exists();
}

/*
 ************************************************************************************App配置文件
 */
void Write_App_Config(QSettings *File){
    //
    File->setValue("Last_User",EROBOWELDSYS_LAST_USER_TYPE);
    File->setValue("Current_Groove",0);
    File->setValue("Current_User_Name",EROBOWELDSYS_CURRENT_USER_NAME);
    File->setValue("Current_User_PassWord",EROBOWELDSYS_CURRENT_USER_PASSWORD);
    File->setValue("Current_User_Type",EROBOWELDSYS_CURRENT_USER_TYPE);

    File->setValue("Screen_Height",EROBOWELDSYS_SCREEN_HEGHT);
    File->setValue("Screen_Width",EROBOWELDSYS_SCREEN_WIDTH);

    File->setValue("Theme_AccentColor",EROBOWELDSYS_THEMEACCENTCOLOR);
    File->setValue("Theme_BackgroundColor",EROBOWELDSYS_THEMEBACKGROUNDCOLOR);
    File->setValue("Theme_PrimaryColor",EROBOWELDSYS_THEMEPRIMARYCOLOR);

    File->setValue("SoftWare_Author",EROBOWELDSYS_SOFTWAREAUTHOR);
    File->setValue("SoftWare_Company",EROBOWELDSYS_SOFTWARECOMPANY);
    File->setValue("SoftWare_Description",EROBOWELDSYS_SOFTWAREDESCRIPTION);
    File->setValue("SoftWare_Version",EROBOWELDSYS_SOFTWAREVREASION);

    File->setValue("BackLight",EROBOWELDSYS_BACKLIGHT);
    File->setValue("Language","EN");
    //
    File->setValue("Swing","200");
    File->setValue("X","200");
    File->setValue("Y","200");
    File->setValue("Z","200");

    File->setValue("SwingMoto","0");
    File->setValue("XMoto","0");
    File->setValue("YMoto","0");
    File->setValue("ZMoto","0");

    File->setValue("BottomStyle","0");
    File->setValue("BottomStyleWidth","8");
    File->setValue("BottomStyleDeep","1.2");
    File->setValue("ConnectSyle","0");
    File->setValue("GrooveStyle","0");
    File->setValue("WeldDir","0");
}
/*
 **********************************************************************************获取配置ini指针
 */
QSettings *PfromQfile(){
    QSettings *path;
    bool IsExist;
    QString QFilename = EROBOWELDSYS_DIR;
    QFilename = QFilename+"Config.txt";
    IsExist = File_Is_Exist(QFilename);
    path=new QSettings(QFilename,QSettings::IniFormat);
    if(!IsExist){
        qDebug()<<"AppConfig::OPEN FILE FAILED .";
        Write_App_Config(path);
    }else{
        qDebug()<<"AppConfig::OPEN FILE OK .";
    }
    return(path);
}
AppConfig::AppConfig(){
    /*获取ini信息*/
    File=PfromQfile();
    Screen_Width = File->value("Screen_Width").toInt();
    Screen_Height = File->value("Screen_Height").toInt();
    Name = File->value("Current_User_Name").toString();
    Password = File->value("Current_User_PassWord").toString();
    Type = File->value("Current_User_Type").toString();
    Primarycolor = File->value("Theme_PrimaryColor").toString();
    Accentcolor = File->value("Theme_AccentColor").toString();
    Backgroundcolor = File->value("Theme_BackgroundColor").toString();
    BacklightValue = File->value("BackLight").toInt();
    CurrentGrooveValue = File->value("Current_Groove").toInt();
    BottomStyleValue=File->value("BottomStyle").toInt();
    //languageValue=File->value("Language").toString();
    //setlanguage(languageValue);
    xSpeedValue=File->value("X").toInt();
    ySpeedValue=File->value("Y").toInt();
    zSpeedValue=File->value("Z").toInt();
    swingSpeedValue=File->value("Swing").toInt();
    swingMotoValue=File->value("SwingMoto").toBool();
    xMotoValue=File->value("XMoto").toBool();
    yMotoValue=File->value("YMoto").toBool();
    zMotoValue=File->value("ZMoto").toBool();
    setbackLight(BacklightValue);
    connectStyleValue=File->value("ConnectStyle").toInt();
    grooveStyleValue=File->value("GrooveStyle").toInt();
    weldDirValue=File->value("WeldDir").toInt();
}
AppConfig::~AppConfig(){

    qDebug()<<"AppConfig::REMOVE";
}
/*
 ************************************************************************************屏幕宽度读写
 */

void AppConfig::setBottomStyle(int value){
    File->setValue("BottomStyle",value);
    BottomStyleValue=value;
    qDebug() <<"AppConfig::BottomStyle Changed";

}

int AppConfig::bottomStyle(){
    qDebug() <<"Get AppConfig::BottomStyle";
    return BottomStyleValue;
}

void AppConfig::setBottomStyleDeep(int value){
    File->setValue("BottomStyleDeep",value);
    BottomStyleDeepValue=value;
    qDebug() <<"AppConfig::BottomStyleDeep Changed";

}

int AppConfig::bottomStyleDeep(){
    qDebug() <<"Get AppConfig::BottomStyle";
    return BottomStyleDeepValue;
}

void AppConfig::setBottomStyleWidth(int value){
    File->setValue("BottomStyleWidth",value);
    BottomStyleWidthValue=value;
    qDebug() <<"AppConfig::BottomStyleWidth Changed";

}

int AppConfig::bottomStyleWidth(){
    qDebug() <<"Get AppConfig::BottomStyle";
    return BottomStyleWidthValue;
}


int AppConfig::screenWidth(){
    return Screen_Width;
}
void AppConfig::setScreenWidth(int width){
    File->setValue("Screen_Width",width);
    Screen_Width=width;
    qDebug() <<"AppConfig::Screen Width Changed";
    emit screenWidthChanged(width);
}
/*
 ************************************************************************************屏幕高度读写
 */
int AppConfig::screenHeight(){
    return Screen_Height;
}
void AppConfig::setScreenHeight(int height){
    File->setValue("Screen_Height",height);
    Screen_Height=height;
    qDebug() <<"AppConfig::Screen Height Changed";
    emit screenHeightChanged(height);
}
/*
 ************************************************************************************当前用户称
 */
QString AppConfig::currentUserName(){
    return Name;
}
void AppConfig::setcurrentUserName(QString username){
    File->setValue("Current_User_Name",username);
    Name=username;
    qDebug() <<"AppConfig::Current User Name Changed";
    emit currentUserNameChanged(username);
}
/*
 ************************************************************************************当前密码
 */
QString AppConfig::currentUserPassword(){
    return Password;
}
void AppConfig::setcurrentUserPassword(QString userpassword){
    File->setValue("Current_User_PassWord",userpassword);
    Password=userpassword;
    qDebug() <<"AppConfig::Current Password Changed";
    emit currentUserPasswordChanged(userpassword);
}
/*
 ************************************************************************************当前用户类型
 */
QString AppConfig::currentUserType(){
    return Type;
}
void AppConfig::setcurrentUserType(QString usertype){
    File->setValue("Current_User_Type",usertype);
    Type=usertype;
    qDebug() <<"AppConfig::Current Type Changed";
    emit currentUserTypeChanged(usertype);
}
/*
 ************************************************************************************当前用户类型
 */
QString AppConfig::lastUser(){
    QString username;
    username = File->value("Last_User").toString();
    qDebug()<<"AppConfig::Last User Read"<<username;
    return username;
}
void AppConfig::setlastUser(QString username){
    File->setValue("Last_User",username);
    qDebug() <<"AppConfig::Last User Changed";
    emit lastUserChanged(username);
}
/*
 ************************************************************************************基本色
 */
QString AppConfig::themePrimaryColor(){  
    return Primarycolor;
}
void AppConfig::setthemePrimaryColor(QString color){
    File->setValue("Theme_PrimaryColor",color);
    Primarycolor=color;
    qDebug() <<"AppConfig::Primary Color Changed";
    emit themePrimaryColorChanged(color);
}
/*
 ************************************************************************************前景色
 */
QString AppConfig::themeAccentColor(){
    return Accentcolor;
}
void AppConfig::setthemeAccentColor(QString color){
    File->setValue("Theme_AccentColor",color);
    Accentcolor=color;
    qDebug() <<"AppConfig::Accent Color Changed";
    emit themeAccentColorChanged(color);
}
/*
 ************************************************************************************背景色
 */
QString AppConfig::themeBackgroundColor(){
    return Backgroundcolor;
}
void AppConfig::setthemeBackgroundColor(QString color){
    File->setValue("Theme_BackgroundColor",color);
    Backgroundcolor=color;
    qDebug() <<"AppConfig::Background Color Changed";
    emit themeBackgroundColorChanged(color);
}
/*
 ************************************************************************************系统背光
 */
int AppConfig::backLight(){
    return BacklightValue;
}
void AppConfig::setbackLight(int value){
    QString s;
    File->setValue("BackLight",value);
    BacklightValue=value;
    s="echo ";
    s+=QString::number(value*2);
    //陈世豪的内核
    //s+=" > /sys/devices/platform/pwm-backlight.0/backlight/pwm-backlight.0/brightness";
    //TKSW内核
    s+=EROBOWELDSYS_PLATFORM?" > /sys/devices/platform/pwm-backlight.2/backlight/pwm-backlight.2/brightness":" > /sys/devices/platform/pwm-backlight.0/backlight/pwm-backlight.0/brightness";
    system(s.toLatin1().data());
    emit backLightChanged(value);
    qDebug() <<"AppConfig::Backlight Value Changed";
}
/*
 ************************************************************************************当前坡口形状
 */
int AppConfig::currentGroove(){
    return CurrentGrooveValue;
}
void AppConfig::setcurrentGroove(int value){
    File->setValue("Current_Groove",value);
    CurrentGrooveValue=value;
    emit currentGrooveChanged(value);
    qDebug() <<"AppConfig::Current Groove Changed";
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
    led_status=status;
}
QString AppConfig::leds(void){
    return led_status;
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

QStringList AppConfig::dateTime(){
    QStringList res;
    res[0]="";
    return res;
}

QString AppConfig::language(){
    return languageValue;
}

void AppConfig::setlanguage(QString str){
    languageValue=str;
    File->setValue("Language",str);
    qDebug()<<"AppConfig::setlanguage "<<str;
    if(str=="EN"){
        QLocale::setDefault(QLocale(QLocale::English,QLocale::UnitedStates));
    }else if(str=="CH"){
        QLocale::setDefault(QLocale(QLocale::Chinese,QLocale::China));
    }
}

bool AppConfig::loadNet(){
    return loadNetValue;
}

void AppConfig::setloadNet(bool value){
    QString s;
    loadNetValue=value;
    //    s="./ethcfg start";
    //    system(s.toLatin1().data());
    //    qDebug()<<s;
    //如果true加载网络 否则关闭网络
    if(value){
        s="./ethcfg mount";
    }else{
        s="./ethcfg umount";
    }
    system(s.toLatin1().data());
    qDebug()<<s;
}

int AppConfig::swingSpeed(){
    return swingSpeedValue;
}

void AppConfig::setSwingSpeed(int value){
    swingSpeedValue=value;
    File->setValue("Swing",value);
}

void AppConfig::setYSpeed(int value){
    ySpeedValue=value;
    File->setValue("Y",value);
}
int AppConfig::ySpeed(){
    return ySpeedValue;
}

void AppConfig::setZSpeed(int value){
    zSpeedValue=value;
    File->setValue("Z",value);
}
int AppConfig::zSpeed(){
    return zSpeedValue;
}
void AppConfig::setXSpeed(int value){
    xSpeedValue=value;
    File->setValue("X",value);
}
int AppConfig::xSpeed(){
    return xSpeedValue;
}

void AppConfig::setXMoto(bool value){
    xMotoValue=value;
    File->setValue("XMoto",value?"1":"0");
}
int AppConfig::xMoto(){
    return xMotoValue;
}
void AppConfig::setYMoto(bool value){
    yMotoValue=value;
    File->setValue("YMoto",value?"1":"0");
}
int AppConfig::yMoto(){
    return yMotoValue;
}
void AppConfig::setZMoto(bool value){
    zMotoValue=value;
    File->setValue("ZMoto",value?"1":"0");
}
int AppConfig::zMoto(){
    return zMotoValue;
}
void AppConfig::setSwingMoto(bool value){
    swingMotoValue=value;
    File->setValue("SwingMoto",value?"1":"0");
}
int AppConfig::swingMoto(){
    return swingMotoValue;
}

void AppConfig::setWeldDir(int value){
    File->setValue("WeldDir",value);
    weldDirValue=value;
    qDebug() <<"AppConfig::WeldDir Changed";
}
int AppConfig::weldDir(){
    return weldDirValue;
}
void AppConfig::setGrooveStyle(int value){
    File->setValue("GrooveStyle",value);
    grooveStyleValue=value;
    qDebug() <<"AppConfig::GrooveStyle Changed";
}
int AppConfig::grooveStyle(){
    return grooveStyleValue;
}
int AppConfig::connectStyle(){
    return connectStyleValue;
}
void AppConfig::setConnectStyle(int value){
    File->setValue("ConnectStyle",value);
    connectStyleValue=value;
    qDebug() <<"AppConfig::ConnectStyle Changed";
}
