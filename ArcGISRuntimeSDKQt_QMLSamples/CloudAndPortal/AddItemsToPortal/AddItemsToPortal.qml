// [WriteFile Name=AddItemsToPortal, Category=CloudAndPortal]
// [Legal]
// Copyright 2016 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// [Legal]

import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import Esri.ArcGISRuntime 100.1
import Esri.ArcGISExtras 1.1
import Esri.ArcGISRuntime.Toolkit.Dialogs 100.1

Rectangle {
    id: rootRectangle
    clip: true

    width: 800
    height: 600

    property real scaleFactor: System.displayScaleFactor

    PortalItem {
        id: itemToAdd
        portal: portal
        type: Enums.PortalItemTypeCSV
        title: "Add Items Sample"

        onLoadStatusChanged: {
            if (loadStatus !== Enums.LoadStatusLoaded)
                return;

            statusBar.text = "Succesfully loaded item from portal." + itemToAdd.itemId
        }

        onItemIdChanged: {
            portalItemModel.setProperty(1, "value", itemToAdd.itemId);
        }
    }

    PortalUser {
        id: myUser
        portal: portal
        username: portal.portalUser ? portal.portalUser.username : ""

        onLoadStatusChanged: {
            if (loadStatus === Enums.LoadStatusFailedToLoad)
                return;

            if (loadStatus !== Enums.LoadStatusLoaded)
                return;

            statusBar.text = "Connected as " + username
        }

        onUsernameChanged: {
            if (loadStatus === Enums.LoadStatusLoaded)
                return;

            // If the username is valid and the portal has been loaded, we are ready to load the user
            if (username.length > 0 && portal.loadStatus === Enums.LoadStatusLoaded)
                load();
        }

        onErrorChanged: {
            statusBar.text = error.message + ": " + error.additionalMessage;
        }

        //! [PortalUser addPortalItemCompleted]
        onAddPortalItemStatusChanged: {
            if (addPortalItemStatus !== Enums.TaskStatusCompleted)
                return;

            itemToAdd.load();
            //! [PortalUser addPortalItemCompleted]

            statusBar.text = "Successfully added item.";
            addItemButton.border.width = 2 * scaleFactor;
        }


        onDeletePortalItemStatusChanged: {
            if (deletePortalItemStatus !== Enums.TaskStatusCompleted)
                return;

            statusBar.text = "Successfully deleted item " + itemToAdd.itemId;
            deleteItemButton.enabled = false;
            portalItemModel.clear();
        }
    }

    Portal {
        id: portal
        loginRequired: true
        credential: Credential {
            oAuthClientInfo: OAuthClientInfo {
                oAuthMode: Enums.OAuthModeUser
                clientId: "W3hPKzPbeJ0tr8aj"
            }
        }

        onLoadStatusChanged: {
            if (loadStatus === Enums.LoadStatusFailedToLoad)
                return;

            if (loadStatus !== Enums.LoadStatusLoaded)
                return;

            authenticationButton.border.width = 2 * scaleFactor;

            // The user cannot be loaded until it has been notified of the name change
            if (myUser.username.length > 0)
                myUser.load();
        }
    }

    Flickable {
        anchors.fill: parent
        interactive: true
        boundsBehavior: Flickable.StopAtBounds
        contentHeight: parent.height * 1.5
        contentWidth: parent.width

        Column {
            id: contentCol
            anchors {
                fill: parent
                margins: 16 * scaleFactor
            }
            spacing: 16 * scaleFactor

            Rectangle {
                id: authenticationButton
                anchors.horizontalCenter: parent.horizontalCenter
                height: 64 * scaleFactor
                width: Math.min(256 * scaleFactor, parent.width)
                color: enabled ? "darkblue" : "darkgrey"
                border {
                    color: "lightgrey"
                    width: 2 * scaleFactor
                }
                radius: 8 * scaleFactor
                enabled: portal.loadStatus !== Enums.LoadStatusLoaded

                Row {
                    anchors.fill: parent
                    spacing: 16 * scaleFactor

                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        source: portal.loadStatus !== Enums.LoadStatusLoaded ?
                                    "qrc:/Samples/CloudAndPortal/AddItemsToPortal/ic_menu_account_dark.png" :
                                    "qrc:/Samples/CloudAndPortal/AddItemsToPortal/ic_menu_checkedcircled_dark.png"
                        fillMode: Image.PreserveAspectFit
                        height: 64 * scaleFactor
                        width: height
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Authenticate Portal"
                        font.bold: true
                        color: "white"
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        portal.load();
                        authenticationButton.border.width = 4 * scaleFactor;
                    }
                }
            }

            Rectangle {
                id: addItemButton
                anchors.horizontalCenter: parent.horizontalCenter
                height: authenticationButton.height
                width: authenticationButton.width
                color: enabled ? "darkblue" : "darkgrey"
                border {
                    color: authenticationButton.border.color
                    width: 2 * scaleFactor
                }
                radius: authenticationButton.radius
                enabled: itemToAdd.loadStatus !== Enums.LoadStatusLoaded && portal.loadStatus === Enums.LoadStatusLoaded

                Row {
                    anchors.fill: parent
                    spacing: 16 * scaleFactor

                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        source: itemToAdd.loadStatus === Enums.LoadStatusLoaded ?
                                    "qrc:/Samples/CloudAndPortal/AddItemsToPortal/ic_menu_checkedcircled_dark.png" :
                                    "qrc:/Samples/CloudAndPortal/AddItemsToPortal/ic_menu_addencircled_dark.png"

                        fillMode: Image.PreserveAspectFit
                        height: 64 * scaleFactor
                        width: height
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Add Item"
                        font.bold: true
                        color: "white"
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        addItemButton.border.width = 4 * scaleFactor;
                        //! [PortalUser addItemWithUrl]
                        var localCSVFile = "qrc:/Samples/CloudAndPortal/AddItemsToPortal/add_item_sample.csv";
                        myUser.addPortalItemWithUrl(itemToAdd, localCSVFile, "add_item_sample.csv");
                        //! [PortalUser addItemWithUrl]
                    }
                }
            }

            Rectangle {
                id: deleteItemButton
                anchors.horizontalCenter: parent.horizontalCenter
                height: authenticationButton.height
                width: authenticationButton.width
                color: enabled ? "darkblue" : "darkgrey"
                border {
                    color: authenticationButton.border.color
                    width: 2 * scaleFactor
                }
                radius: authenticationButton.radius
                enabled: itemToAdd.loadStatus === Enums.LoadStatusLoaded

                Row {
                    anchors.fill: parent
                    spacing: 16 * scaleFactor

                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        source: myUser.deletePortalItemStatus !== Enums.TaskStatusCompleted ?
                                    "qrc:/Samples/CloudAndPortal/AddItemsToPortal/ic_menu_trash_dark.png" :
                                    "qrc:/Samples/CloudAndPortal/AddItemsToPortal/ic_menu_checkedcircled_dark.png"

                        fillMode: Image.PreserveAspectFit
                        height: 64 * scaleFactor
                        width: height
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Delete Item"
                        font.bold: true
                        color: "white"
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        deleteItemButton.border.width = 2 * scaleFactor;
                        myUser.deletePortalItem(itemToAdd);
                    }
                }
            }

            Rectangle {
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: 4 * scaleFactor
                color: "lightgrey"
            }

            Rectangle {
                id: itemView
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: 100 * scaleFactor
                color: "lightsteelblue"
                border {
                    color: "darkgrey"
                    width: 4 * scaleFactor
                }
                radius: 32
                clip: true

                Text {
                    id: portalItemLabel
                    anchors{
                        top: parent.top
                        horizontalCenter: parent.horizontalCenter
                        margins: 4 * scaleFactor
                    }
                    color: "white"
                    font.bold: true
                    text: "PortalItem"
                    font.underline: true
                    horizontalAlignment: Text.AlignHCenter
                }

                ListModel {
                    id: portalItemModel

                    Component.onCompleted: {
                        append({"label": "title", "value": itemToAdd.title });
                        append({"label": "itemId", "value": itemToAdd.itemId});
                        append({"label": "type", "value": itemToAdd.typeName});
                    }
                }

                ListView {
                    anchors {
                        top: portalItemLabel.bottom
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                        margins: 16 * scaleFactor
                    }
                    clip: true
                    model: portalItemModel
                    delegate: Text {
                        color: "white"
                        text: label + ":\t" + value
                        wrapMode: Text.Wrap
                        elide: Text.ElideRight
                    }
                }
            }

            Text {
                id: statusBar
                anchors{
                    left: parent.left
                    right: parent.right
                }
                wrapMode: Text.Wrap
                elide: Text.ElideRight
            }
        }
    }

    AuthenticationView {
        authenticationManager: AuthenticationManager
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: portal.loadStatus === Enums.TaskStatusInProgress ||
                 myUser.loadStatus === Enums.TaskStatusInProgress ||
                 myUser.addPortalItemStatus === Enums.TaskStatusInProgress ||
                 myUser.deletePortalItemStatus === Enums.TaskStatusInProgress
    }
}