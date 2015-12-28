#ifndef VIRTUALKEYBOARDKEYEVENTDISPATCHER_H
#define VIRTUALKEYBOARDKEYEVENTDISPATCHER_H

#include <QObject>

class VirtualKeyboardKeyEventDispatcher : public QObject
{
    Q_OBJECT
public:
    explicit VirtualKeyboardKeyEventDispatcher(QObject *parent = 0);
    bool IsLower;
signals:
    
public slots:
    void setFocusItem(QObject *focusItem);
    void sendKeyToFocusItem(const QString &keyText);
private:
    QObject * m_focusItem;
};

#endif // VirtualKeyboardKEYEVENTDISPATCHER_H
