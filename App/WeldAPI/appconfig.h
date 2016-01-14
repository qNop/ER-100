#ifndef APPCONFIG_H
#define APPCONFIG_H

#include <QObject>
#include <QString>
#include <QtQml/QQmlListProperty>

class APPConfig : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int screenWidth READ  screenWidth WRITE setScreenWidth NOTIFY screenWidthChanged )
    Q_PROPERTY(int screenHeight READ  screenHeight WRITE setScreenHeight NOTIFY screenHeightChanged)
    Q_PROPERTY(QString currentUserName READ  currentUserName WRITE setcurrentUserName NOTIFY currentUserNameChanged )
    Q_PROPERTY(QString currentUserPassword READ  currentUserPassword WRITE setcurrentUserPassword NOTIFY currentUserPasswordChanged)
    Q_PROPERTY(QString currentUserType READ  currentUserType WRITE setcurrentUserType NOTIFY currentUserTypeChanged)
    Q_PROPERTY(QString lastUser READ  lastUser WRITE setlastUser NOTIFY lastUserChanged)
    //  Q_PROPERTY(QString localdatetime READ  localdatetime WRITE setlocaldatetime NOTIFY localdatetimeChanged)
    /*当前基础色彩*/
    Q_PROPERTY(QString themePrimaryColor READ  getthemePrimaryColor WRITE setthemePrimaryColor NOTIFY themePrimaryColorchanged )
    /*当前前景色彩*/
    Q_PROPERTY(QString themeAccentColor READ  getthemeAccentColor WRITE setthemeAccentColor NOTIFY themeAccentColorchanged)
    /*当前背景色彩*/
    Q_PROPERTY(QString themeBackgroundColor READ  getthemeBackgroundColor WRITE setthemeBackgroundColor NOTIFY themeBackgroundColorchanged )
    /*系统背光*/
    Q_PROPERTY(int backLight READ  getbackLight WRITE setbackLight NOTIFY backLightchanged )
    /*当前坡口*/
    Q_PROPERTY(int currentGroove READ  getcurrentGroove WRITE setcurrentGroove NOTIFY currentGroovechanged)
    /*系统led*/
    Q_PROPERTY(QString leds READ getleds WRITE setleds)

public:
    APPConfig();
    ~APPConfig();



    void setleds(QString status);//leds
    QString getleds();

    int getcurrentGroove(); // 当前坡口
    void setcurrentGroove(int);

    QString currentUserName();  // 当前用户名称
    void  setcurrentUserName(QString username);

    QString currentUserPassword();//当前用户密码
    void  setcurrentUserPassword(QString userpassword);

    QString currentUserType();     //当前用户类型
    void setcurrentUserType(QString usertype);

    QString lastUser();//上一次使用用户
    void setlastUser(QString username);

    QString localdatetime();//本地系统时间
    void setlocaldatetime(QString datetime);

    int screenWidth();//屏幕宽度
    void setScreenWidth(int width);

    int screenHeight();       //屏幕长度
    void setScreenHeight(int height);

    QString getthemePrimaryColor();  //系统主题前景颜色
    void setthemePrimaryColor(QString color);

    QString getthemeAccentColor();  //系统主题前景颜色
    void setthemeAccentColor(QString color);

    QString getthemeBackgroundColor();  //系统主题前景颜色
    void setthemeBackgroundColor(QString color);

    int getbackLight();//系统背光
    void setbackLight(int value);
private:
    QString led_status;
    QString SoftWare_Description; // 软件描述
    QString SoftWare_Author;         //软件作者
    QString SoftWare_Company;    //软件公司
    QString SoftWare_Version;                //软件版本
signals:
    void screenWidthChanged(int width);
    void screenHeightChanged(int hight);
    void currentUserNameChanged(QString username);
    void currentUserPasswordChanged(QString userpassword);
    void currentUserTypeChanged(QString usertype);
    void lastUserChanged(QString username);
    void localdatetimeChanged(QString datetime);
    void themePrimaryColorchanged(QString color);
    void themeAccentColorchanged(QString color);
    void themeBackgroundColorchanged(QString color);
    void backLightchanged(int value);
    void currentGroovechanged(int value);

};

#endif // APPCONFIG_H
