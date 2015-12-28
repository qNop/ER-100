#include "VirtualKeyboardinputcontext.h"
#include <QDebug>
#include <QEvent>
#include <QGuiApplication>
#include "pinyininputmethod.h"

VirtualKeyboardInputContextPrivate::VirtualKeyboardInputContextPrivate() : view(0)
{
}

VirtualKeyboardInputContextPrivate::~VirtualKeyboardInputContextPrivate()
{
    if (view) {
        delete view;
    }
}

CPinyinInputMethod *pinyinInput = NULL;
VirtualKeyboardInputContextPrivate *VirtualKeyboardInputContext::d = new VirtualKeyboardInputContextPrivate();
VirtualKeyboardInputContext::VirtualKeyboardInputContext() :
    QPlatformInputContext()
{
    pinyinInput = new CPinyinInputMethod();
}

VirtualKeyboardInputContext::~VirtualKeyboardInputContext()
{

}

bool VirtualKeyboardInputContext::isValid() const
{
    return true;
}

QRectF VirtualKeyboardInputContext::keyboardRect() const
{
    return (d->view)? d->view->geometry(): QRectF();
}

void VirtualKeyboardInputContext::showInputPanel()
{
    if (!d->view)
    {
        d->view = new QQuickView();
        d->view->engine()->rootContext()->setContextProperty("keyEventDispatcher",&d->keyEventDispatcher);

        d->view->setSource(QUrl("qrc:/qml/InputPanel.qml"));

        d->view->setResizeMode(QQuickView::SizeViewToRootObject);
        d->view->setClearBeforeRendering(true);

        d->view->setColor(Qt::transparent);
        QSurfaceFormat f(d->view->format());
        f.setAlphaBufferSize(8);
        d->view->setFormat(f);

        d->view->engine()->rootContext()->setContextProperty("pinyinInput", pinyinInput);
        pinyinInput->Update();
        d->view->setFlags(d->view->flags() | Qt::Tool | Qt::FramelessWindowHint | Qt::WindowStaysOnTopHint	| Qt::WindowDoesNotAcceptFocus);
    }

    d->view->show();
    QPlatformInputContext::showInputPanel();
}

void VirtualKeyboardInputContext::hideInputPanel()
{
    if (d->view)
        d->view->hide();
}

bool VirtualKeyboardInputContext::isInputPanelVisible() const
{
    return (d->view) ? d->view->isVisible() : false;
}


void VirtualKeyboardInputContext::setFocusObject(QObject *object)
{
    d->keyEventDispatcher.setFocusItem(object);
}
