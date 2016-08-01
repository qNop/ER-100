#ifndef AppCONFIG_H
#define AppCONFIG_H

#include <QObject>
#include <QString>
#include <QtQml/QQmlListProperty>
#include <QSettings>
#include <QProcess>
#include <QLocale>


class AppConfig : public QObject
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
    Q_PROPERTY(QString themePrimaryColor READ  themePrimaryColor WRITE setthemePrimaryColor NOTIFY themePrimaryColorChanged )
    /*当前前景色彩*/
    Q_PROPERTY(QString themeAccentColor READ  themeAccentColor WRITE setthemeAccentColor NOTIFY themeAccentColorChanged)
    /*当前背景色彩*/
    Q_PROPERTY(QString themeBackgroundColor READ  themeBackgroundColor WRITE setthemeBackgroundColor NOTIFY themeBackgroundColorChanged )
    /*系统背光*/
    Q_PROPERTY(int backLight READ  backLight WRITE setbackLight NOTIFY backLightChanged )
    /*当前坡口*/
    Q_PROPERTY(int currentGroove READ  currentGroove WRITE setcurrentGroove NOTIFY currentGrooveChanged)
    /*系统led*/
    Q_PROPERTY(QString leds READ leds WRITE setleds)
    /*当前衬垫*/
    Q_PROPERTY(int bottomStyle READ  bottomStyle WRITE setbottomStyle NOTIFY bottomStyleChanged)
    /*修改当前时间*/
     Q_PROPERTY(QStringList dateTime READ dateTime WRITE setdateTime NOTIFY dateTimeChanged)
    /*设置本地化*/
      Q_PROPERTY(QString language READ language WRITE setlanguage NOTIFY languageChanged)
    /*加载本地网络*/
     Q_PROPERTY(bool loadNet READ loadNet WRITE setloadNet NOTIFY loadNetChanged)
    /*复制文件到backup文件夹下*/
   // Q_PROPERTY(bool)
    /*摇动电机点动速度*/
    Q_PROPERTY(int swingSpeed READ swingSpeed WRITE setSwingSpeed NOTIFY swingSpeedChanged)
    Q_PROPERTY(int xSpeed READ xSpeed WRITE setXSpeed NOTIFY xSpeedChanged)
    Q_PROPERTY(int ySpeed READ ySpeed WRITE setYSpeed NOTIFY ySpeedChanged)
    Q_PROPERTY(int zSpeed READ zSpeed WRITE setZSpeed NOTIFY zSpeedChanged)
private:
    QSettings* File;
    QProcess *poc;
    QString led_status;
    QString SoftWare_Description; // 软件描述
    QString SoftWare_Author;         //软件作者
    QString SoftWare_Company;    //软件公司
    QString SoftWare_Version;                //软件版本
    QString Name;
    QString Password;
    QString Type;
    QString Primarycolor;
    QString Accentcolor;
    QString Backgroundcolor;
    int Screen_Width;
    int Screen_Height;
    int BacklightValue;
    int CurrentGrooveValue;
    int  BottomStyleValue;
    QString languageValue;
    bool loadNetValue;
    int xSpeedValue;
    int ySpeedValue;
    int zSpeedValue;
    int swingSpeedValue;
public:
    AppConfig();
    ~AppConfig();

    QString leds();
    int currentGroove(); // 当前坡口
    int bottomStyle();
    QString currentUserName();  // 当前用户名称
    QString currentUserPassword();//当前用户密码
    QString currentUserType();     //当前用户类型
    QString lastUser();//上一次使用用户
    int screenWidth();//屏幕宽度
    int screenHeight();       //屏幕长度
    QString themePrimaryColor();  //系统主题前景颜色
    QString themeAccentColor();  //系统主题前景颜色
    QString themeBackgroundColor();  //系统主题前景颜色
    int backLight();//系统背光
    QStringList dateTime();
    QString language();
    bool loadNet();
    int xSpeed();
    int ySpeed();
    int zSpeed();
    int swingSpeed();
public slots:
    void setbottomStyle(int value);
    void setbackLight(int value);
    void setthemeBackgroundColor(QString color);
    void setthemeAccentColor(QString color);
    void setthemePrimaryColor(QString color);
    void setScreenHeight(int height);
    void setScreenWidth(int width);
    //   void setlocaldatetime(QString datetime);
    void setlastUser(QString username);
    void setcurrentUserType(QString usertype);
    void setcurrentUserPassword(QString userpassword);
    void setcurrentUserName(QString username);
    void setcurrentGroove(int value);
    void setleds(QString status);//leds
    void setdateTime(QStringList time);
    void setlanguage(QString str);
    void setloadNet(bool value);
    void setXSpeed(int value);
    void setYSpeed(int value);
    void setZSpeed(int value);
    void setSwingSpeed(int value);
signals:
    void xSpeedChanged();
    void ySpeedChanged();
    void zSpeedChanged();
    void swingSpeedChanged();
    void bottomStyleChanged(int value);
    void screenWidthChanged(int width);
    void screenHeightChanged(int hight);
    void currentUserNameChanged(QString username);
    void currentUserPasswordChanged(QString userpassword);
    void currentUserTypeChanged(QString usertype);
    void lastUserChanged(QString username);
    //  void localdatetimeChanged(QString datetime);
    void themePrimaryColorChanged(QString color);
    void themeAccentColorChanged(QString color);
    void themeBackgroundColorChanged(QString color);
    void backLightChanged(int value);
    void currentGrooveChanged(int value);
    void dateTimeChanged();
    void languageChanged(QString str);
    void loadNetChanged();
};

#endif // AppCONFIG_H
