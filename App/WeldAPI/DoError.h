#ifndef DOERROR_H
#define DOERROR_H

#include <QObject>
#include <QString>
#include <QJsonObject>

class DoError : public QObject
{
    Q_OBJECT
private:
    long long oldError;
    int errorCount;
    //槽
public:
    DoError();
    void errorMath(long long errorCode);
    long long getErrorCode();
    //信号
signals:
    void upDateError(QString cmd,QJsonObject jsonObject);
    void upDateHistory(QString cmd,QJsonObject jsonObject);
};


#endif // DOERROR_H
