#ifndef AppCONFIG_H
#define AppCONFIG_H

#include <QObject>
#include <QString>
#include <QtQml/QQmlListProperty>
#include <QSettings>
#include <QProcess>
#include <QLocale>
#include <QQuickWindow>


class AppConfig : public QObject
{
    Q_OBJECT
private:

public:
    AppConfig();
    ~AppConfig();

public slots:

    void setbackLight(int value);
    void setleds(QString status);//leds
    void setdateTime(QStringList time);
    void setlanguage(QString str);

    bool screenShot(QQuickWindow *widget);

};

#endif // AppCONFIG_H
