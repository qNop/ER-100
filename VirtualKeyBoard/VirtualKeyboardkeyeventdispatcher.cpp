#include "VirtualKeyboardkeyeventdispatcher.h"
#include <QInputMethodEvent>
#include <QCoreApplication>
VirtualKeyboardKeyEventDispatcher::VirtualKeyboardKeyEventDispatcher(QObject *parent) :
    QObject(parent),m_focusItem(0)
{

}

void VirtualKeyboardKeyEventDispatcher::setFocusItem(QObject *focusItem)
{
    m_focusItem = focusItem;
}

void VirtualKeyboardKeyEventDispatcher::sendKeyToFocusItem(const QString &keyText)
{
    if (!m_focusItem)
        return;

    QInputMethodEvent ev;
    if (keyText == QString("\x7F"))
        ev.setCommitString("",-1,1);
    else if (keyText == QString("\n"))
    {
        QCoreApplication::sendEvent(m_focusItem, new QKeyEvent(QEvent::KeyPress, Qt::Key_Enter, Qt::NoModifier));
        QCoreApplication::sendEvent(m_focusItem, new QKeyEvent(QEvent::KeyRelease, Qt::Key_Enter, Qt::NoModifier));
    }
    else
        ev.setCommitString(keyText);
    QCoreApplication::sendEvent(m_focusItem, &ev);
}
