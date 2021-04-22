#ifndef GROOVE_H
#define GROOVE_H
#include <QObject>
#include <QString>
#include <QDebug>
#include <QStringList>
#include <QtCore>
#include <QtGlobal>
#include "gloabldefine.h"

typedef struct{
    float x;
    float y;
}point;

typedef struct{
    float angel;
    float height;
    float rootGap;
    bool error;
    float s;
    float basic_x;
    float basic_y;
}ResType;

class groove
{
private:
    ResType getAngelT(float angel1,float angel2,float height,float rootgap,float heightError);
    void changeGrooveRules(grooveRulesType *p1,grooveRulesType*p2);
    int minAreaId;
    int maxAreaId;

public:
    groove();
    int index;

    QString name;

    int grooveDir;

    float rootFace;

    int setGrooveRules( grooveRulesType *p,QObject *value);

    int getGrooveRulesAv( grooveRulesType *pGrooveRules,weldDataTableType* pData,int length);

    void reorderGrooveList( weldDataTableType* pData,bool UpOrDown);

};

#endif // GROOVE_H
