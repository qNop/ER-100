#ifndef WELDMODEL_H
#define WELDMODEL_H
#include "gloabldefine.h"
#include <QObject>

class  GrooveModel: public QObject
{
    Q_OBJECT
    Q_PROPERTY(LocalStruct teachMode READ teachMode WRITE setteachMode NOTIFY teachModeChanged)
public:
    TeachMode();
    LocalStruct teachMode();
    void setteachMode(QString mode);
signals:
    void teachModeChanged(mode);
};

class  TeachMode: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString weldMode READ weldMode WRITE setWeldMode NOTIFY weldModeChanged)
public:
    WeldModel();
    QString weldMode();
    void setWeldMode(QString mode);
signals:
    void weldModeChanged(mode);
};

#endif // WELDMODEL_H
