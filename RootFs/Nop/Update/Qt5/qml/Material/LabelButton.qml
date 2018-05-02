/*
 * QML Material - An application framework implementing Material Design.
 * Copyright (C) 2014-2015 Michael Spencer <sonrisesoftware@gmail.com>
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
import Material 0.1
import Material.Extras 0.1

/*!
   \qmltype IconButton
   \inqmlmodule Material 0.1

   \brief Icon buttons are appropriate for app bars, toolbars, action buttons or toggles.
 */
Item {
    id: labelButton

    property Action action
    property alias color: label.color
    signal clicked

    width: label.width
    height: label.height
    enabled: action ? action.enabled : true
    opacity: enabled ? 1 : 0.6

    onClicked: {
        if (action) action.triggered(label)
    }

    Ink {
        id: ink

        anchors.centerIn: parent
        enabled: labelButton.enabled
        centered: true
        circular: true

        width: parent.width + Units.dp(20)
        height: parent.height + Units.dp(20)

        z: 0

        onClicked: {
            labelButton.clicked()
        }
    }

    Label {
        id: label
        anchors.centerIn: parent
	text: action ? action.name : ""
	color: label.color
	style: "button"
    }

    Tooltip {
        text: action ? action.name : ""
        mouseArea: ink
    }
}
