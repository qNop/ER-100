#ifndef VIRTUALKEYBOARDINPUTCONTEXT_H
#define VIRTUALKEYBOARDINPUTCONTEXT_H
#include <QRectF>
#include <qpa/qplatforminputcontext.h>
#include "VirtualKeyboardkeyeventdispatcher.h"
#include <QQmlEngine>
#include <QQmlContext>
#include <QQuickView>

class VirtualKeyboardInputContextPrivate;
class VirtualKeyboardInputContext : public QPlatformInputContext
{
    Q_OBJECT
public:
    VirtualKeyboardInputContext();
    ~VirtualKeyboardInputContext();
    //retur true if plugin is enabled
    bool isValid() const;

    //this value will be available in QGuiApplication::inputMethod()->keyboardRectangle()
    QRectF keyboardRect() const;


    //show and hide invoked by Qt when editor gets focus
    void showInputPanel();
    void hideInputPanel();
    //this value will be available in QGuiApplication::inputMethod()->isVisible()
    bool isInputPanelVisible() const;

    //editor pointer
    void setFocusObject(QObject *object);
    QObject *Sender;

public:
    static VirtualKeyboardInputContextPrivate *d;
};

class VirtualKeyboardInputContextPrivate
{
public:
    VirtualKeyboardInputContextPrivate();
    ~VirtualKeyboardInputContextPrivate();
    QQuickView *view;
    VirtualKeyboardKeyEventDispatcher keyEventDispatcher;
};
#endif // VirtualKeyboardINPUTCONTEXT_H
