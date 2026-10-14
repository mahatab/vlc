/*****************************************************************************
 * Copyright (C) 2020 VLC authors and VideoLAN
 *
 * Authors: Benjamin Arnaud <bunjee@omega.gg>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * ( at your option ) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/

import QtQuick

import VLC.MainInterface
import VLC.Style
import VLC.Widgets as Widgets
import VLC.Util

// Empty library view: the main action adds a folder to the library in one step;
// "Browse" stays available for people who just want to look around.
EmptyLabel {
    id: root

    // Properties

    property bool _keyPressed: false

    // Aliases

    property alias button: button
    property alias browseButton: browseButton

    // Functions

    function onNavigate(reason) {
        History.push(["network"], reason)
    }

    function addFolder() {
        // Falls back to Browse when this build has no media library.
        if (!MainCtx.addFolderToLibrary() && !MainCtx.mediaLibraryAvailable)
            onNavigate(Qt.OtherFocusReason)
    }

    // Keys

    Keys.priority: Keys.AfterItem

    Keys.onPressed: (event) => {
        _keyPressed = true

        Navigation.defaultKeyAction(event)
    }

    Keys.onReleased: (event) => {
        if (_keyPressed === false)
            return

        _keyPressed = false

        if (KeyHelper.matchOk(event)) {
            if (browseButton.activeFocus)
                onNavigate(Qt.TabFocusReason)
            else
                addFolder()
        }

        Navigation.defaultKeyReleaseAction(event)
    }

    // Children

    Row {
        anchors.horizontalCenter: parent.horizontalCenter

        spacing: VLCStyle.margin_small

        Widgets.ButtonExt {
            id: button

            width: Math.max(VLCStyle.dp(120, VLCStyle.scale), implicitWidth)

            focus: true

            text: qsTr("Add a folder")
            iconTxt: VLCIcons.folder

            Navigation.parentItem: root
            Navigation.rightItem: browseButton

            onClicked: root.addFolder()
        }

        Widgets.ButtonExt {
            id: browseButton

            width: Math.max(VLCStyle.dp(84, VLCStyle.scale), implicitWidth)

            text: qsTr("Browse")

            Navigation.parentItem: root
            Navigation.leftItem: button

            onClicked: root.onNavigate(Qt.OtherFocusReason)
        }
    }
}
