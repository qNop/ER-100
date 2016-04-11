/*
 * QML Material - An application framework implementing Material Design.
 * Copyright (C) 2015 Michael Spencer <sonrisesoftware@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation, either version 2.1 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.4

/*!
   \qmltype OverlayLayer
   \inqmlmodule Material 0.1

   \brief Provides a layer to display popups and other overlay components.
 */
Flickable{
    id:flickable
    objectName: "overlayerFlickable"
    anchors.fill: parent
    visible: currentOverlay !==null
    contentHeight: height+40
    property Item currentOverlay;
    property real lastcontenty;
    onContentYChanged: {
        if((currentOverlay!==null)&&(!flickable.moving))
            currentOverlay.anchors.verticalCenterOffset=-contentY;
    }
    Rectangle {
        id: overlayLayer
        anchors.fill: parent
        color: "transparent"

        onEnabledChanged: {
            if (!enabled && flickable.currentOverlay !== null)
                flickable.currentOverlay.close()
        }

        onWidthChanged: closeIfNecessary()
        onHeightChanged: closeIfNecessary()

        states: State {
            name: "ShowState"
            when: flickable.currentOverlay !== null

            PropertyChanges {
                target: overlayLayer
                color: currentOverlay.overlayColor
            }
        }

        transitions: Transition {
            ColorAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }
    }
    function closeIfNecessary() {
        if (flickable.currentOverlay !== null && flickable.currentOverlay.closeOnResize)
            flickable.currentOverlay.close()
    }

    MouseArea {
        id:mouse
        anchors.fill: parent
        enabled: flickable.currentOverlay !== null &&
                 flickable.currentOverlay.globalMouseAreaEnabled
        hoverEnabled: false
        onClicked: {
            if (flickable.currentOverlay.dismissOnTap)
                flickable.currentOverlay.close()
        }
    }

}

