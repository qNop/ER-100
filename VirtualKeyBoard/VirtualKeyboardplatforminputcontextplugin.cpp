#include "VirtualKeyboardplatforminputcontextplugin.h"
#include "VirtualKeyboardinputcontext.h"


QPlatformInputContext *VirtualKeyboardPlatformInputContextPlugin::create(const QString& system, const QStringList& paramList)
{
    Q_UNUSED(paramList);

    if (system.compare(system, QStringLiteral("VirtualKeyboard"), Qt::CaseInsensitive) == 0)
        return new VirtualKeyboardInputContext;
    return 0;
}



