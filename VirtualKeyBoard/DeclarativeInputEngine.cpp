//============================================================================
/// \file   DeclarativeInputEngine.cpp
/// \author Uwe Kindler
/// \date   08.01.2015
/// \brief  Implementation of CDeclarativeInputEngine
///
/// Copyright 2015 Uwe Kindler
/// Licensed under MIT see LICENSE.MIT in project root
//============================================================================

//============================================================================
//                                   INCLUDES
//============================================================================
#include "DeclarativeInputEngine.h"
#include <QFile>
#include <QDir>
#include <QSettings>
#include <QInputMethodEvent>
#include <QCoreApplication>
#include <QGuiApplication>
#include <QDebug>
#include <QQmlEngine>
#include <QJSEngine>
#include <QtQml>
#include <QString>

#include <string.h>


/**
 * Private data class
 */
struct DeclarativeInputEnginePrivate
{
    DeclarativeInputEngine* _this;
    int InputMode;
    QRect KeyboardRectangle;
    QStringList key;
    QStringList val;
    QStringList Model;
    QString str;
    long index;
    /**
     * Private data constructor
     */
    DeclarativeInputEnginePrivate(DeclarativeInputEngine* _public);

}; // struct DeclarativeInputEnginePrivate

//==============================================================================
DeclarativeInputEnginePrivate::DeclarativeInputEnginePrivate(DeclarativeInputEngine* _public)
    : _this(_public),
      InputMode(DeclarativeInputEngine::Latin),
      key(0),
      val(0),
      Model(0)
{

}

//==============================================================================
DeclarativeInputEngine::DeclarativeInputEngine(QObject *parent) :
    QObject(parent),
    d(new DeclarativeInputEnginePrivate(this))
{
    d->str="";
    d->Model.clear();
    d->index=0;
    QSettings setter(":/pinyin/pinyinEx.ini", QSettings::IniFormat);
    d->key = setter.value("pyKey",d->key).toStringList();
    d->val = setter.value("pyVal", d->val).toStringList();
    if (d->key.size() <= 1)
    {
        qDebug()<<"DeclarativeInputEngine::Install Chinese Fail .";
        return;
    }
}


//==============================================================================
DeclarativeInputEngine::~DeclarativeInputEngine()
{
    delete d;
}


//==============================================================================
void DeclarativeInputEngine::sendKeyToFocusItem(const QString& text)
{
    //qDebug() << "CDeclarativeInputEngine::sendKeyToFocusItem " << text;
    QInputMethodEvent ev;
    //删除命令
    if (text == QString("\x7F"))
    {
        if(d->str == ""){
             ev.setCommitString("",-1,1);
             QCoreApplication::sendEvent(QGuiApplication::focusObject(),&ev);
        }
        if (d->str.length()){
            d->str.truncate(d->str.length()-1);
            d->index--;
            macthing(d->str);//匹配 汉字
        }
        else
            d->str = "";
    }else if (text == QString("\n"))
    {
        QCoreApplication::sendEvent(QGuiApplication::focusObject(), new QKeyEvent(QEvent::KeyPress, Qt::Key_Enter, Qt::NoModifier));
        QCoreApplication::sendEvent(QGuiApplication::focusObject(), new QKeyEvent(QEvent::KeyRelease, Qt::Key_Enter, Qt::NoModifier));
    }else if(text == QString("\x0D")){//enter
        ev.setCommitString(d->Model.at(d->index));
        QCoreApplication::sendEvent(QGuiApplication::focusObject(),&ev);
        d->str="";
        macthing(d->str);
    }else if(text == QString("\x0E")){//>>
        d->index++;
    }else if(text == QString("\x0F")){ // <<
       if(d->index>0)
            d->index--;
    }
    //正常命令
    else
    {
        d->str+=text;
        d->index=0;
        macthing(d->str);//匹配 汉字
    }
}

//==============================================================================
QRect DeclarativeInputEngine::keyboardRectangle() const
{
    return d->KeyboardRectangle;
}


//==============================================================================
void DeclarativeInputEngine::setKeyboardRectangle(const QRect& Rect)
{
    d->KeyboardRectangle = Rect;
    emit keyboardRectangleChanged();
}

//==============================================================================
int DeclarativeInputEngine::inputMode() const
{
    return d->InputMode;
}


//==============================================================================
void DeclarativeInputEngine::setInputMode(int Mode)
{
   // qDebug() << "CDeclarativeInputEngine::setInputMode " << Mode;
    if (Mode != d->InputMode)
    {
        d->InputMode = Mode;
        emit inputModeChanged();
    }
}
//
void DeclarativeInputEngine::macthing(QString str){
    int min = 0;
    int max = d->key.size();
    int idx = max / 2;
    d->Model.clear();
    d->Model.append(str);
    str = str.toLower();
    if(str != ""){
        while (true)
        {
            if (d->key[idx].startsWith(str))
                break;
            if (max == min + 1 || max <= min || max == idx + 1 || max == idx || min == idx + 1 || min == idx ){
                idx=-1;
                break;
            }
            if (d->key[idx] > str)
                max = idx;
            else
                min = idx;
            idx = (max + min) / 2;
        }
        do{
            if (--idx < 0)
                break;
        }while(d->key[idx].startsWith(str));
        idx++;
        if (idx != -1)
        {
            while(true)
            {
                if (idx >= d->key.size())
                    break;
                if (d->key[idx].startsWith(str)){
                    d->Model.append(d->val[idx]);
                }
                else
                    break;
                idx++;
            }
        }
    }
    setchineseList(d->Model);
}
QStringList DeclarativeInputEngine::getchineseList(){
    return d->Model;
}
void DeclarativeInputEngine::setchineseList(QStringList list){
    emit chineseListChanged(list);
}
//------------------------------------------------------------------------------
// EOF DeclarativeInputEngine.cpp
