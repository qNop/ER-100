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
    //
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
    }
    return(path);
}
AppConfig::AppConfig(){
    /*获取ini信息*/
    File=PfromQfile();
    poc = new QProcess;
}
AppConfig::~AppConfig(){
    qDebug()<<"AppConfig::REMOVE";
    delete File;
    delete poc;
}
/*
 ************************************************************************************屏幕宽度读写
 */
int AppConfig::screenWidth(){
    int ScreenWidth;
    ScreenWidth = File->value("Screen_Width").toInt();
    qDebug()<<"AppConfig::Screen Width Read"<<ScreenWidth;
    return ScreenWidth;
}
void AppConfig::setScreenWidth(int width){
    File->setValue("Screen_Width",width);
    qDebug() <<"AppConfig::Screen Width Changed";
    emit screenWidthChanged(width);
}
/*
 ************************************************************************************屏幕高度读写
 */
int AppConfig::screenHeight(){
    int Screen_Height;
    Screen_Height = File->value("Screen_Height").toInt();
    qDebug()<<"AppConfig::Screen Height Read"<<Screen_Height;
    return Screen_Height;
}
void AppConfig::setScreenHeight(int height){
    File->setValue("Screen_Height",height);
    qDebug() <<"AppConfig::Screen Height Changed";
    emit screenHeightChanged(height);
}
/*
 ************************************************************************************当前用户称
 */
QString AppConfig::currentUserName(){
    QString name;
    name = File->value("Current_User_Name").toString();
    qDebug()<<"AppConfig::Current User Name Read"<<name;
    return name;
}
void AppConfig::setcurrentUserName(QString username){
    File->setValue("Current_User_Name",username);
    qDebug() <<"AppConfig::Current User Name Changed";
    emit currentUserNameChanged(username);
}
/*
 ************************************************************************************当前密码
 */
QString AppConfig::currentUserPassword(){
    QString password;
    password = File->value("Current_User_PassWord").toString();
    qDebug()<<"AppConfig::Current Password Read"<<password;
    return password;
}
void AppConfig::setcurrentUserPassword(QString userpassword){
    File->setValue("Current_User_PassWord",userpassword);
    qDebug() <<"AppConfig::Current Password Changed";
    emit currentUserPasswordChanged(userpassword);
}
/*
 ************************************************************************************当前用户类型
 */
QString AppConfig::currentUserType(){
    QString type;
    type = File->value("Current_User_Type").toString();
    qDebug()<<"AppConfig::Current Type Read"<<type;
    return type;
}
void AppConfig::setcurrentUserType(QString usertype){
    File->setValue("Current_User_Type",usertype);
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
    QString primarycolor;
    primarycolor = File->value("Theme_PrimaryColor").toString();
    qDebug()<<"AppConfig::Primary Color Read"<<primarycolor;
    return primarycolor;
}
void AppConfig::setthemePrimaryColor(QString color){
    File->setValue("Theme_PrimaryColor",color);
    qDebug() <<"AppConfig::Primary Color Changed";
    emit themePrimaryColorChanged(color);
}
/*
 ************************************************************************************前景色
 */
QString AppConfig::themeAccentColor(){
    QString accentcolor;
    accentcolor = File->value("Theme_AccentColor").toString();
    qDebug()<<"AppConfig::Accent Color Read"<<accentcolor;
    return accentcolor;
}
void AppConfig::setthemeAccentColor(QString color){
    File->setValue("Theme_AccentColor",color);
    qDebug() <<"AppConfig::Accent Color Changed";
    emit themeAccentColorChanged(color);
}
/*
 ************************************************************************************背景色
 */
QString AppConfig::themeBackgroundColor(){
    QString backgroundcolor;
    backgroundcolor = File->value("Theme_BackgroundColor").toString();
    qDebug()<<"AppConfig::Background Color Read"<<backgroundcolor;
    return backgroundcolor;
}
void AppConfig::setthemeBackgroundColor(QString color){
    File->setValue("Theme_BackgroundColor",color);
    qDebug() <<"AppConfig::Background Color Changed";
    emit themeBackgroundColorChanged(color);
}
/*
 ************************************************************************************系统背光
 */
int AppConfig::backLight(){
    int value;
    value = File->value("BackLight").toInt();
    qDebug()<<"AppConfig::Backlight Value Read"<<value;
    return value;
}
void AppConfig::setbackLight(int value){

    File->setValue("BackLight",value);
    QString s;
    s="/Nop/backlight ";
    s+=QString::number(value);
    poc->start(s);
    emit backLightChanged(value);
    qDebug() <<"AppConfig::Backlight Value Changed";
}
/*
 ************************************************************************************当前坡口形状
 */
int AppConfig::currentGroove(){
    int value;
    value = File->value("Current_Groove").toInt();
    qDebug()<<"AppConfig::Current Groove Read"<<value;
    return value;
}
void AppConfig::setcurrentGroove(int value){
    if(value>8)
        value=0;
    File->setValue("Current_Groove",value);
    emit currentGrooveChanged(value);
    qDebug() <<"AppConfig::Current Groove Changed";
}
/*
 * set led status
 */
void AppConfig::setleds(QString status){
    QString s;
    s="/Nop/leds ";
    s+=status;
    qDebug()<<s;
    poc->start(s);
    led_status=status;
}
QString AppConfig::leds(void){
    return led_status;
}
