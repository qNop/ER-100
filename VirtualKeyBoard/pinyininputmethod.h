/***************************************************************************
**
**  A chinese input method based on Qt 5.x
**  Copyright (C) <2014> <xinh>
**
****************************************************************************/

#ifndef PINYININPUTMETHOD_H
#define PINYININPUTMETHOD_H
//---------------------------------------------------------------------------
#include <QtCore>
#include <QObject>
#include <QList>
#include <QMultiMap>
#include <QString>

//---------------------------------------------------------------------------

class CPinyinInputMethod: public QObject
{
Q_OBJECT
public:
    CPinyinInputMethod();
    ~CPinyinInputMethod();

    void Update();
    int BinarySearch(const QString &gemfield);

public slots:
    void Matching(const QString &gemfield );

private:
    QStringList key;
    QStringList val;
    QStringList HanziModel;
};
//---------------------------------------------------------------------------
#endif
