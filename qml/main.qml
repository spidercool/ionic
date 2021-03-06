import QtQuick 1.1
import "meego"

StepsPageStackWindow {
    id: appWindow
    initialPage: mainPage
    showStatusBar: false
    showToolBar: prefs.showToolbar
    focus: true

    MainPage {
        id: mainPage
    }

    BookPage {
        id: thisBookPage
        enableJump: false
    }

    StepsBanner {
        id: infoBookmarkAdded
        width: parent.width - 17
        text: qsTr("Bookmarked current position")
    }

    ImportPage {
        id: importPage
    }

    LibraryPage {
        id: libraryPage
    }

    SettingsPage {
        id: settingsPage
    }

    StepsToolBarLayout {
        id: commonTools
        visible: true

        StepsToolIcon {
            stockIcon: "up"
            enabled: library.nowReading.valid
            onClicked: {
                menu.close()
                mainPage.goToPreviousPage()
            }
        }
        StepsToolIcon {
            stockIcon: "down"
            enabled: library.nowReading.valid
            onClicked: {
                menu.close()
                mainPage.goToNextPage()
            }
        }
        StepsToolIcon {
            stockIcon: (platform.osName === "symbian")? "qrc:/icons/bookmark.png": "bookmark"
            enabled: library.nowReading.valid
            onClicked: {
                menu.close()
                pageStack.push(Qt.resolvedUrl("JumpPage.qml"))
            }
        }
        StepsToolIcon {
            stockIcon: (platform.osName === "symbian")? "qrc:/icons/about.png": "new-message"
            onClicked: {
                menu.close()
                pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
        }
        StepsToolIcon {
            stockIcon: "menu"
            anchors.right: (parent === undefined)? undefined: parent.right
            onClicked: {
                if (menu.status === menu.statusClosed) {
                    mainPage.toolBarRevelaerActive = false
                    menu.open()
                } else {
                    menu.close()
                }
            }
        }
    }

    StepsMenu {
        id: menu
        visualParent: pageStack
        StepsMenuLayout {
            StepsMenuItem {
                text: qsTr("Book details")
                enabled: library.nowReading.valid
                onClicked: {
                    menu.close()
                    pageStack.push(thisBookPage)
                }
            }
            StepsMenuItem {
                text: qsTr("Add books")
                onClicked: {
                    menu.close()
                    pageStack.push(importPage)
                }
            }
            StepsMenuItem {
                text: qsTr("Library")
                onClicked: {
                    menu.close()
                    pageStack.push(libraryPage)
                }
            }
            StepsMenuItem {
                text: qsTr("Settings")
                onClicked: {
                    menu.close()
                    pageStack.push(settingsPage)
                }
            }
            StepsMenuItem {
                text: qsTr("Exit")
                onClicked: Qt.quit()
                visible: platform.osName == "symbian"
            }
        }
        onStatusChanged: {
            if (status === statusClosed && mainPage.status === mainPage.statusActive) {
                mainPage.toolBarRevelaerActive = true
                showToolBar = prefs.showToolBar
            }
        }
    }

    Component.onCompleted: {
        mainPage.setStyle(prefs.style)
    }
}
