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
    QObject* InputPanel;
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
      Model(0),
      InputPanel(0)
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
    qDebug()<<"DeclarativeInputEngine::REMOVE";
    delete d;
}


//==============================================================================
void DeclarativeInputEngine::sendKeyToFocusItem(const QString& text)
{
    //qDebug() << "CDeclarativeInputEngine::sendKeyToFocusItem " << text;
    QInputMethodEvent ev;
  //  qDebug()<<"DeclarativeInputEngine::d->index"<<d->index;
    //删除命令
    if (text == QString("\x7F"))
    {
        if(d->str == ""){
            ev.setCommitString("",-1,1);
            QCoreApplication::sendEvent(QGuiApplication::focusObject(),&ev);
        }
        if (d->str.length()){
            d->str.truncate(d->str.length()-1);
            d->index=0; //每次匹配时都清零
            macthing(d->str);//匹配 汉字
        }
        else{
            d->index=0;
            d->str = "";
        }
    }else if (text == QString("\n"))
    {
        QCoreApplication::sendEvent(QGuiApplication::focusObject(), new QKeyEvent(QEvent::KeyPress, Qt::Key_Enter, Qt::NoModifier));
        QCoreApplication::sendEvent(QGuiApplication::focusObject(), new QKeyEvent(QEvent::KeyRelease, Qt::Key_Enter, Qt::NoModifier));
    }else if(text == QString("\x0D")){//enter
        if(d->Model.length()){
            ev.setCommitString(d->Model.at(d->index));
            QCoreApplication::sendEvent(QGuiApplication::focusObject(),&ev);
            d->str="";
            macthing(d->str);
        }
    }else if(text == QString("\x0E")){//>>
        d->index++;
        if(d->index>d->Model.length()){
            d->index=d->Model.length();
        }
    }else if(text == QString("\x0F")){ // <<
        if(d->index>0)
            d->index--;
        else d->index=0;
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

QObject * DeclarativeInputEngine::inputPanel() {
    return d->InputPanel;
}

void DeclarativeInputEngine::setInputPanel(QObject *Object){
  //  qDebug()<<"DeclarativeInputEngine::setInputPanel ObjectName is "<<Object->objectName();
    d->InputPanel=Object;
    emit inputPanelChanged(Object);
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
    d->InputMode = Mode;
    emit inputModeChanged(Mode);
}
//
void DeclarativeInputEngine::macthing(QString str){
    int min = 0;
    int max = d->key.size();
    int idx = max / 2;
    d->Model.clear();
    d->Model.append(str);
    d->index=0;
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
   // qDebug()<<"DeclarativeInputEngine::d->Model length"<<d->Model.length();
    setchineseList(d->Model);
}
QStringList DeclarativeInputEngine::getchineseList(){
    return d->Model;
}
void DeclarativeInputEngine::setchineseList(QStringList list){
    d->Model=list;
    d->str=list[0];
    //qDebug()<<d->str;
    emit chineseListChanged(list);
}
//------------------------------------------------------------------------------
// EOF DeclarativeInputEngine.cpp
