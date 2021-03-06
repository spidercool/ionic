import QtQuick 1.1
import QtWebKit 1.0
import "meego"
import com.pipacs.ionic.Bookmark 1.0
import com.pipacs.ionic.Book 1.0
import "theme.js" as Theme

StepsPage {
    signal nowReadingChanged
    property alias toolBarRevelaerActive: revealer.active

    orientationLock: prefs.orientation
    focus: true

    BookView {
        id: bookView
        anchors.fill: parent
        focus: true
        onLoadStarted: {
            spinner.visible = true
            spinner.running = true
        }
        onLoadFinished: {
            spinner.visible = false
            spinner.running = false
        }
        onLoadFailed: {
            spinner.visible = false
            spinner.running = false
        }
    }

    // Reading progress indicator
    ReadingProgress {
        id: readingProgress
    }

    StepsSpinner {
        id: spinner
        darken: false
    }

    // Handle double-tap to reveal the toolbar
    ToolBarRevealer {
        id: revealer
    }

    // Restore last reading position after a delay
    Timer {
        id: restoreTimer
        interval: 200
        running: false
        repeat: false
        onTriggered: restorePosition()
    }

    Component.onCompleted: {
        library.nowReadingChanged.connect(nowReadingChanged)
        library.setNowReading(library.nowReading)
        revealer.targetWindow = appWindow
        setStyle(prefs.style)
        appWindow.orientationChangeAboutToStart.connect(prepareRestoringPosition)
        appWindow.orientationChangeFinished.connect(restoreTimer.start)
        mediaKey.volumeUpPressed.connect(onVolumeUpPressed)
        mediaKey.volumeDownPressed.connect(onVolumeDownPressed)
        setToolBar(commonTools)
    }

    // Activate/deactivate the toolbar revealer, depending on the page status
    onStatusChanged: {
        if (status === statusActivating) {
            revealer.active = true
            appWindow.showToolBar = prefs.showToolBar
            focus = true
        } else if (status === statusDeactivating) {
            revealer.active = false
            appWindow.showToolBar = true
        }
    }

    // Restore a new book's last reading position
    onNowReadingChanged: {
        console.log("* MainPage.onNowReadingChanged to " + library.nowReading.title)
        if (library.nowReading.valid) {
            goTo(library.nowReading.lastBookmark.part, library.nowReading.lastBookmark.position, "#")
        } else {
            bookView.load(":/texts/nobook.html")
        }
    }

    // Handle up/down keys
    Keys.onPressed: {
        if ((event.key === Qt.Key_VolumeUp) || (event.key === Qt.Key_Up) || (event.key === Qt.Key_PageUp)) {
            bookView.goToPreviousPage()
        } else if ((event.key === Qt.Key_VolumeDown) || (event.key === Qt.Key_Down) || (event.key === Qt.Key_PageDown)) {
            bookView.goToNextPage()
        }
    }

    // Handle Volume Up key (needs special signal handler on Symbian)
    function onVolumeUpPressed() {
        if (prefs.useVolumeKeys && status === statusActive) {
            bookView.goToPreviousPage()
        }
    }

    // Handle Volume Down key (needs special signal handler on Symbian)
    function onVolumeDownPressed() {
        if (prefs.useVolumeKeys && status === statusActive) {
            bookView.goToNextPage()
        }
    }

    function goToPreviousPage() {
        bookView.goToPreviousPage()
    }

    function goToNextPage() {
        bookView.goToNextPage()
    }

    function goTo(part, targetPos, url) {
        console.log("* MainPage.goTo part " + part + ", targetPos " + targetPos + ", url '" + url + "'")
        console.log("*  Current URL is " + bookView.url)
        bookView.targetPos = targetPos
        bookView.part = part
        if (url === "#") {
            url = library.nowReading.urlFromPart(part)
            console.log("*  url from part: " + url)
        }
        if ((url == "") || (url == bookView.url)) {
            // Force a jump to the new position
            console.log("*  Same as current, forcing local jump")
            bookView.jump()
        } else {
            console.log("*  Loading new url")
            bookView.load(url)
            // BookView itself will force a jump, after loading url
        }
    }

    function goToUrl(link) {
        bookView.goToUrl(link)
    }

    function setStyle(style) {
        if (platform.osName === "harmattan") {
            theme.inverted = (style === "night")
        }
        readingProgress.color = Theme.progressColor(style)
        bookView.setStyle(style)
    }

    function setMargin(margin) {
        bookView.setMargin(margin)
    }

    function prepareRestoringPosition() {
        bookView.updateTimer.stop()
        bookView.updateLastBookmark()
    }

    function restorePosition() {
        bookView.targetPos = library.nowReading.lastBookmark.position
        bookView.jump()
        bookView.updateTimer.start()
    }
}
