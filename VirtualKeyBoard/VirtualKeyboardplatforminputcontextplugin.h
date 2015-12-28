#ifndef VIRTUALKEYBOARDPLATFORMINPUTCONTEXTPLUGIN_H
#define VIRTUALKEYBOARDPLATFORMINPUTCONTEXTPLUGIN_H

#include <qpa/qplatforminputcontextplugin_p.h>

class  VirtualKeyboardPlatformInputContextPlugin: public QPlatformInputContextPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QPlatformInputContextFactoryInterface.5.1" FILE "VirtualKeyboard.json")

public:
    QPlatformInputContext *create(const QString&, const QStringList&);
};


#endif 
