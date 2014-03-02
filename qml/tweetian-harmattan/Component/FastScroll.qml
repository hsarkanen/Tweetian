/*
    Copyright (C) 2012 Dickson Leong
    This file is part of Tweetian.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

// Source: <http://forum.meego.com/showthread.php?t=4600>
import QtQuick 2.1
import Sailfish.Silica 1.0
import "FastScroll.js" as Sections

Item {
    id: root

    property ListView listView

    property int __topPageMargin: 0
    property int __bottomPageMargin: 0
    property int __leftPageMargin: 0
    property int __rightPageMargin: 0
    property bool __hasPageWidth : false
    property bool __hasPageHeight : false

    property int __hideTimeout: 500

    //property Style platformStyle: FastScrollStyle {}

    // This function ensures that we always anchor the decorator correctly according
    // to the page margins.
    function __updatePageMargin() {
        if (!listView)
            return
        var p = listView.parent
        while (p) {
            if (p.hasOwnProperty("__isPage")) {
                __hasPageWidth = function() { return p.width == listView.width }
                __topPageMargin = function() { return p.anchors.topMargin }
                __bottomPageMargin = function() { return p.anchors.bottomMargin }
                __leftPageMargin = function() { return p.anchors.leftMargin }
                __rightPageMargin = function() { return p.anchors.rightMargin }
                return;
            } else {
                p = p.parent;
            }
        }
    }

    onListViewChanged: {
        if (listView && listView.model) {
            internal.initDirtyObserver();
        } else if (listView) {
            listView.modelChanged.connect(function() {
                if (listView.model) {
                    internal.initDirtyObserver();
                }
            });
        }
        __updatePageMargin()
    }

    anchors.fill: listView//parent

    //FIXME: Item
    Item {
        anchors.fill: parent
        anchors.leftMargin: __hasPageWidth ? -__leftPageMargin : 0
        anchors.rightMargin: __hasPageWidth ? -__rightPageMargin : 0
        anchors.topMargin: __hasPageWidth ? -__topPageMargin : 0
        anchors.bottomMargin: __hasPageWidth ? -__bottomPageMargin : 0

        MouseArea {
            id: dragArea
            objectName: "dragArea"
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 70
            drag.target: magnifier
            drag.axis: Drag.YAxis
            drag.minimumY: 0 // listView.y
            drag.maximumY: dragArea.height - magnifier.height // listView.y + listView.height - magnifier.height

            onPressed: {
                magnifier.positionAtY(dragArea.mouseY);
            }

            onPositionChanged: {
                internal.adjustContentPosition(dragArea.mouseY);
            }

            Image {
                id: rail
                source: platformStyle.railImage
                opacity: 0
                anchors.fill: parent

                property bool dragging: dragArea.drag.active

                Image {
                    id: handle
                    opacity: !rail.dragging ? 1 : 0
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: platformStyle.handleImage
                    y: 18 + (rail.height - 36 - height)/(1.0 - listView.visibleArea.heightRatio) * listView.visibleArea.yPosition
                }

                states: State {
                    name: "visible"
                    when: listView.moving || rail.dragging
                    PropertyChanges {
                        target: rail
                        opacity: 1
                    }
                }

                transitions: [
                    Transition {
                        from: ""; to: "visible"
                        NumberAnimation {
                            properties: "opacity"
                            duration: root.__hideTimeout
                        }
                    },
                    Transition {
                        from: "visible"; to: ""
                        NumberAnimation {
                            properties: "opacity"
                            duration: root.__hideTimeout
                        }
                    }
                ]
            }
        }

        Image {
            id: magnifier
            objectName: "popup"
            opacity: rail.dragging ? 1 : 0
            anchors.left: parent.left
            anchors.right: parent.right
            height: 150
            source: platformStyle.magnifierImage

            function positionAtY(yCoord) {
                magnifier.y = Math.max(dragArea.drag.minimumY, Math.min(yCoord - magnifier.height/2, dragArea.drag.maximumY));
            }

            Text {
                id: magnifierLabel
                objectName: "magnifierLabel"
                x: 14
                y: 40

                font.pixelSize: platformStyle.fontPixelSize
                //font.family: "Nokia Pure Text Bold"
                color: platformStyle.textColor

                text: internal.currentSection
            }
        }
    }

    Timer {
        id: dirtyTimer
        interval: 100
        running: false
        onTriggered: {
            Sections.initSectionData(listView);
            internal.modelDirty = false;
        }
    }

    Connections {
        target: root.listView
        onCurrentSectionChanged: internal.curSect = rail.dragging ? internal.curSect : ""
    }

    QtObject {
        id: internal

        property string currentSection: listView.currentSection
        property string curSect: ""
        property string curPos: "first"
        property int oldY: 0
        property bool modelDirty: false
        property bool down: true

        function initDirtyObserver() {
            Sections.initialize(listView);
            function dirtyObserver() {
                if (!internal.modelDirty) {
                    internal.modelDirty = true;
                    dirtyTimer.running = true;
                }
            }

            if (listView.model.countChanged)
                listView.model.countChanged.connect(dirtyObserver);

            if (listView.model.itemsChanged)
                listView.model.itemsChanged.connect(dirtyObserver);

            if (listView.model.itemsInserted)
                listView.model.itemsInserted.connect(dirtyObserver);

            if (listView.model.itemsMoved)
                listView.model.itemsMoved.connect(dirtyObserver);

            if (listView.model.itemsRemoved)
                listView.model.itemsRemoved.connect(dirtyObserver);
        }

        function adjustContentPosition(y) {
            if (y < 0 || y > dragArea.height) return;

            internal.down = (y > internal.oldY);
            var sect = Sections.getClosestSection((y / dragArea.height), internal.down);
            internal.oldY = y;
            if (internal.curSect != sect) {
                internal.curSect = sect;
                internal.curPos = Sections.getSectionPositionString(internal.curSect);
                var sec = Sections.getRelativeSections(internal.curSect);
                internal.currentSection = internal.curSect;
                var idx = Sections.getIndexFor(sect);
                listView.positionViewAtIndex(idx, ListView.Beginning);
            }
        }

    }
}
