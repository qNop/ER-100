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

#include <QQuickItem>
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
    QObject* InputPanel;
    QString place_str;

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
    d->place_str="";
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

void DeclarativeInputEngine::setPlaceStr(QString str){
    d->place_str=str;
}


//==============================================================================
void DeclarativeInputEngine::sendKeyToFocusItem(const QString& text)
{
    //qDebug() << "CDeclarativeInputEngine::sendKeyToFocusItem " << text;
    QInputMethodEvent ev;

    //qDebug()<<"DeclarativeInputEngine::d->index"<<d->index;
    //删除命令
    if (text == QString("\x7F"))
    {
        if(d->str==""){
            ev.setCommitString("",-1,1);
            QCoreApplication::sendEvent(QGuiApplication::focusObject(),&ev);
        }
        if(d->place_str.length()){
            ev.setCommitString("",-1,1);
            QCoreApplication::sendEvent(QGuiApplication::focusObject(),&ev);
            d->place_str.remove(d->place_str.length()-1,1);
        }
        if (d->str.length()){
            d->str.truncate(d->str.length()-1);
            macthing(d->str);//匹配 汉字
        }
        else{
            d->str = "";
        }
    }else if(text.startsWith(QString("\x0D"))){//确认命令输入
        QString str=text;
        str=str.replace(QString("\x0D"),"");
        if(d->Model.length()){
            str=d->Model.at(str.toInt());
            //如果placestr 还有数据 则从开头对比str 和placestr 不同的地方 把不同字符输入 textfeild
            for(int i=0;i<d->place_str.length();i++){
                if(str.at(i)==d->place_str.at(i)){
                    str.remove(0,1);
                    d->place_str.remove(0,1);
                    i-=1;
                    qDebug()<<d->place_str<<str;
                }else{
                    //一旦不想等就立即退出
                    break;
                }
            }
            ev.setCommitString(str);
            QCoreApplication::sendEvent(QGuiApplication::focusObject(),&ev);
            //确认参数
            d->str="";
            macthing(d->str);
        }
    }
    //正常命令
    else
    {
        //如果place上面有数 则清除 控件上的数据同时清除place-str 清除d->str
        if(d->place_str.length()){
            for(int i=0;i<d->place_str.length();i++){
                ev.setCommitString("",-1,1);
                QCoreApplication::sendEvent(QGuiApplication::focusObject(),&ev);
            }
            d->place_str="";
            d->str="";
        }
        //处理输入的数据
        d->str+=text;
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
    InputPanelItem=dynamic_cast<QQuickItem*>(Object);
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
