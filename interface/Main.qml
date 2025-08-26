import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Imagine
import QtQuick.Window
import QtQuick.Shapes
import QtQuick.Timeline

ApplicationWindow {
    id: window
    width: 1920
    height: 1080
    minimumWidth: 1600
    minimumHeight: 900
    visible: true
    title: "AGV Control System - Advanced Vehicle Management"

    // Modern gradient arka plan
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#1a1a2e" }
            GradientStop { position: 0.5; color: "#16213e" }
            GradientStop { position: 1.0; color: "#0f3460" }
        }
    }

    // Geliştirilmiş renk paleti
    readonly property color primaryColor: "#00d4ff"
    readonly property color secondaryColor: "#0099cc"
    readonly property color accentColor: "#ff6b35"
    readonly property color warningColor: "#ff4757"
    readonly property color successColor: "#2ed573"
    readonly property color darkBg: "#1a1a2e"
    readonly property color cardBg: "#16213e"
    readonly property color cardBgHover: "#1e2a4a"
    readonly property color textPrimary: "#ffffff"
    readonly property color textSecondary: "#b8c5d6"
    readonly property color borderColor: "#2c3e50"

    // Font boyutları
    readonly property int fontSizeSmall: Qt.application.font.pixelSize * 0.8
    readonly property int fontSizeMedium: Qt.application.font.pixelSize * 1.2
    readonly property int fontSizeLarge: Qt.application.font.pixelSize * 1.8
    readonly property int fontSizeExtraLarge: Qt.application.font.pixelSize * 2.5

    // AGV Durum Değişkenleri
    property real batteryLevel: 87.5
    property real speed: 12.5
    property real temperature: 42.3
    property real motorRPM: 1850
    property real voltage: 48.2
    property real current: 15.8
    property real wheelAngle: 0
    property real loadWeight: 125.7
    property bool emergencyStop: false
    property bool systemRunning: false  // Normal start/stop durumu
    property bool autoMode: true
    property bool navigationActive: true
    property string currentLocation: "Warehouse A - Zone 3"
    property string destination: "Loading Dock - Zone 7"
    property real distanceToTarget: 45.2
    property real estimatedTime: 3.2

    // Mouse navigasyon kontrolü için değişkenler
    property real mouseX: 0
    property real mouseY: 0
    property bool mousePressed: false
    property real targetX: 0.8
    property real targetY: 0.3
    property bool hasTarget: true
    property bool forceRedraw: false
    property bool targetsCleared: false

    // AGV pozisyon ve hareket kontrolü
    property real agvCurrentX: 100
    property real agvCurrentY: 200
    property real agvTargetX: 100
    property real agvTargetY: 200
    property bool agvMoving: false
    property bool agvReachedTarget: false
    property real agvSpeed: 18.0 // piksel/saniye (9 kat daha hızlı)

    // Batarya şarj istasyonu özellikleri
    property real chargingStationX: 0.8  // Canvas'ın %80'i
    property real chargingStationY: 0.2  // Canvas'ın %20'si
    property bool isCharging: false
    property real chargingProgress: 0.0  // 0.0 - 1.0 arası
    property real chargingSpeed: 0.5     // %/saniye şarj hızı

    // Auto mode hedef seçimi için özellikler
    property var autoTargets: [
        {x: 0.2, y: 0.3, name: "Depo A"},
        {x: 0.4, y: 0.6, name: "Yükleme Alanı"},
        {x: 0.7, y: 0.4, name: "Transfer Noktası"},
        {x: 0.3, y: 0.8, name: "Paketleme"},
        {x: 0.6, y: 0.2, name: "Kontrol Noktası"}
    ]
    property int currentAutoTargetIndex: 0
    property bool autoTargetReached: false
    property bool isGoingToCharging: false  // Şarj istasyonuna gidiyor mu?
    property int lastAutoTargetIndex: 0     // Şarj öncesi son hedef indeksi

    // Sensör verileri
    property real frontDistance: 2.5
    property real rearDistance: 1.8
    property real leftDistance: 0.8
    property real rightDistance: 0.9
    property real lidarData: 3.2

    // Yeni özellikler
    property bool nightMode: false
    property bool soundEnabled: true
    property int selectedTheme: 0 // 0: Default, 1: Dark, 2: Light
    property bool showAdvancedData: false
    property bool showAlerts: true
    property int alertCount: 3

    // Intro ekranı özellikleri
    property bool showIntro: true
    property real introProgress: 0.0
    property real logoScale: 0.1
    property real logoOpacity: 0.0
    property real textOpacity: 0.0
    property real subtitleOpacity: 0.0

    // Kullanıcı girişi özellikleri
    property bool showLogin: false
    property bool isLoggedIn: false
    property string username: ""
    property string password: ""
    property bool loginError: false
    property string errorMessage: ""

         // Zamanlayıcılar
     Timer {
         interval: (emergencyStop || !systemRunning) ? 1000 : 100  // Emergency stop veya sistem durduğunda 10 kat daha yavaş
         running: true
         repeat: true
         onTriggered: {
             // Emergency stop veya sistem durduğunda değerleri sabitle
             if (emergencyStop || !systemRunning) {
                 // Emergency stop veya sistem durduğunda batarya çok çok yavaş düşer
                 batteryLevel = Math.max(0, batteryLevel - 0.0001)

                 // Diğer değerler sabit bırak
                 // speed, temperature, motorRPM, voltage, current, wheelAngle, loadWeight değişmez

                 // Mesafe sensörleri de sabit kalır
                 // frontDistance, rearDistance, leftDistance, rightDistance, lidarData değişmez

                 // Navigasyon durur
                 // distanceToTarget ve estimatedTime değişmez
             } else {
                 // Normal durumda tüm değerler güncellenir
                 batteryLevel = Math.max(0, batteryLevel - 0.01)
                 speed = speed + (Math.random() - 0.5) * 0.5
                 speed = Math.max(0, Math.min(25, speed))
                 temperature = temperature + (Math.random() - 0.5) * 0.2
                 motorRPM = motorRPM + (Math.random() - 0.5) * 50
                 voltage = voltage + (Math.random() - 0.5) * 0.1
                 current = current + (Math.random() - 0.5) * 0.2
                 wheelAngle = wheelAngle + (Math.random() - 0.5) * 2
                 loadWeight = loadWeight + (Math.random() - 0.5) * 0.5

                 // Mesafe sensörleri
                 frontDistance = frontDistance + (Math.random() - 0.5) * 0.1
                 rearDistance = rearDistance + (Math.random() - 0.5) * 0.1
                 leftDistance = leftDistance + (Math.random() - 0.5) * 0.1
                 rightDistance = rightDistance + (Math.random() - 0.5) * 0.1
                 lidarData = lidarData + (Math.random() - 0.5) * 0.1

                 // Navigasyon güncelleme
                 if (navigationActive) {
                     distanceToTarget = Math.max(0, distanceToTarget - 0.1)
                     estimatedTime = distanceToTarget / (speed + 0.1)
                 }


             }
         }
     }

    // AGV hareket fonksiyonu
    function moveAGVToTarget() {
        if (!hasTarget || emergencyStop || !systemRunning) {
            agvMoving = false
            return
        }

        // AGV'nin hedefe olan mesafesini hesapla
        var dx = agvTargetX - agvCurrentX
        var dy = agvTargetY - agvCurrentY
        var distance = Math.sqrt(dx * dx + dy * dy)

        // Şarj istasyonuna yakın mı kontrol et
        var chargingStationCanvasX = navigationCanvas.width * chargingStationX
        var chargingStationCanvasY = navigationCanvas.height * chargingStationY
        var distanceToChargingStation = Math.sqrt(
            Math.pow(agvCurrentX - chargingStationCanvasX, 2) +
            Math.pow(agvCurrentY - chargingStationCanvasY, 2)
        )

        // Şarj istasyonuna yakınsa şarj başlat, uzaklaşırsa şarjı durdur
        if (distanceToChargingStation < 20) {
            if (!isCharging) {
                isCharging = true
                chargingProgress = batteryLevel / 100
                console.log("Şarj istasyonuna ulaştı! Şarj başlatılıyor...")
            }
        } else {
            // Şarj istasyonundan uzaklaştıysa şarjı durdur
            if (isCharging) {
                isCharging = false
                chargingProgress = 0.0
                console.log("Şarj istasyonundan ayrıldı! Şarj durduruldu.")
            }
        }

        // Hedefe yakın mı kontrol et (5 piksel tolerans)
        if (distance < 5) {
            agvMoving = false
            agvReachedTarget = true
            console.log("AGV hedefe ulaştı!")

            // Auto mode'da hedefe ulaştıysa sonraki hedefe geç
            if (autoMode && !emergencyStop && systemRunning) {
                if (isGoingToCharging) {
                    // Şarj istasyonuna ulaştı, şarj başlayacak
                    console.log("Şarj istasyonuna ulaştı! Şarj bekleniyor...")
                } else {
                    // Normal hedefe ulaştı, sonraki hedefe geç
                    autoTargetAdvanceTimer.start()
                }
            }
            return
        }

        // Hareket yönünü hesapla
        var angle = Math.atan2(dy, dx)

        // AGV'yi hedefe doğru hareket ettir
        var moveDistance = agvSpeed * 0.05 // 50ms için hareket mesafesi
        agvCurrentX += Math.cos(angle) * moveDistance
        agvCurrentY += Math.sin(angle) * moveDistance

        // AGV'nin yönünü güncelle
        wheelAngle = angle * 180 / Math.PI

        // AGV modelini yeni pozisyona taşı
        agvModel.x = agvCurrentX
        agvModel.y = agvCurrentY

        // Mesafe ve ETA güncelle
        distanceToTarget = distance
        estimatedTime = distance / (agvSpeed * 20) // 20 FPS için düzeltme

        console.log("AGV hareket ediyor - Mesafe:", distance.toFixed(1), "ETA:", estimatedTime.toFixed(1))
    }

    // AGV'yi hedefe yönlendir
    function startAGVMovement() {
        if (hasTarget && !emergencyStop && systemRunning) {
            agvMoving = true
            agvReachedTarget = false
            console.log("AGV hareketi başlatıldı - Hedef:", targetX.toFixed(2), targetY.toFixed(2))
        }
    }

    // Auto mode için sonraki hedefi seç
    function selectNextAutoTarget() {
        if (autoTargets.length === 0) return

        // Sonraki hedefi seç
        var nextTarget = autoTargets[currentAutoTargetIndex]
        targetX = nextTarget.x
        targetY = nextTarget.y
        hasTarget = true
        targetsCleared = false

        // AGV hedefini güncelle
        agvTargetX = navigationCanvas.width * targetX
        agvTargetY = navigationCanvas.height * targetY

        // Mesafe hesaplama
        var dx = agvCurrentX - agvTargetX
        var dy = agvCurrentY - agvTargetY
        distanceToTarget = Math.sqrt(dx*dx + dy*dy)

        // ETA güncelleme
        estimatedTime = distanceToTarget / (speed + 0.1)

        // Hedef konumu güncelleme
        destination = "Auto: " + nextTarget.name

        console.log("Auto mode hedef seçildi:", nextTarget.name, "Koordinatlar:", targetX.toFixed(2), targetY.toFixed(2))

        // AGV hareketini başlat
        startAGVMovement()

        // Canvas'ı yeniden çiz
        navigationCanvas.requestPaint()
    }

    // Auto mode hedef indeksini artır
    function advanceAutoTargetIndex() {
        currentAutoTargetIndex = (currentAutoTargetIndex + 1) % autoTargets.length
        console.log("Auto mode hedef indeksi güncellendi:", currentAutoTargetIndex)
    }

    // Batarya seviyesini kontrol et ve gerekirse şarj istasyonuna git
    function checkBatteryLevel() {
        if (batteryLevel <= 75 && !isGoingToCharging && !isCharging) {
            // Batarya düşük, şarj istasyonuna git
            goToChargingStation()
        } else if (batteryLevel >= 80 && isGoingToCharging && !isCharging) {
            // Batarya yeterince doldu, normal hedeflere geri dön
            returnToNormalTargets()
        }
    }

    // Şarj istasyonuna git
    function goToChargingStation() {
        // Mevcut hedef indeksini kaydet
        lastAutoTargetIndex = currentAutoTargetIndex
        isGoingToCharging = true

        // Şarj istasyonunu hedef olarak ayarla
        targetX = chargingStationX
        targetY = chargingStationY
        hasTarget = true
        targetsCleared = false

        // AGV hedefini şarj istasyonuna ayarla
        agvTargetX = navigationCanvas.width * chargingStationX
        agvTargetY = navigationCanvas.height * chargingStationY

        // Mesafe hesaplama
        var dx = agvCurrentX - agvTargetX
        var dy = agvCurrentY - agvTargetY
        distanceToTarget = Math.sqrt(dx*dx + dy*dy)

        // ETA güncelleme
        estimatedTime = distanceToTarget / (speed + 0.1)

        // Hedef konumu güncelleme
                 destination = "Auto: Şarj İstasyonu 🔋 (Batarya: " + batteryLevel.toFixed(0) + "%)"

        console.log("Batarya düşük! Şarj istasyonuna gidiliyor... Batarya:", batteryLevel.toFixed(0) + "%")

        // AGV hareketini başlat
        startAGVMovement()

        // Canvas'ı yeniden çiz
        navigationCanvas.requestPaint()
    }

        // Normal hedeflere geri dön
    function returnToNormalTargets() {
        isGoingToCharging = false

        // Son hedef indeksine geri dön
        currentAutoTargetIndex = lastAutoTargetIndex

        // Normal hedef seçimi
        selectNextAutoTarget()

        console.log("Batarya doldu! Normal hedeflere geri dönülüyor...")
    }

    // Kullanıcı girişi kontrolü
    function checkLogin() {
        if (username === "admin" && password === "1234") {
            isLoggedIn = true
            showLogin = false
            loginError = false
            errorMessage = ""
            console.log("Giriş başarılı!")
        } else {
            loginError = true
            errorMessage = "Kullanıcı adı veya şifre hatalı!"
            password = ""
            console.log("Giriş başarısız!")
        }
    }

    // Hedef temizleme fonksiyonu
    function clearAllTargets() {
        console.log("clearAllTargets çağrıldı")

        // Auto mode'da hedefleri temizleme
        if (autoMode) {
            console.log("Auto mode aktif - Hedefler temizlenmedi")
            return
        }

        hasTarget = false
        targetX = 0.5
        targetY = 0.5
        distanceToTarget = 0
        estimatedTime = 0
        destination = "Hedef Temizlendi"
        forceRedraw = !forceRedraw
        targetsCleared = true

        // Şarjı durdur
        isCharging = false
        chargingProgress = 0.0
        isGoingToCharging = false

        // AGV hareketini durdur ve pozisyonu sıfırla
        agvMoving = false
        agvReachedTarget = false
        agvCurrentX = 100
        agvCurrentY = 200
        agvTargetX = 100
        agvTargetY = 200

        // Canvas'ı hemen yeniden çiz
        navigationCanvas.requestPaint()

        // Timer ile tekrar çiz
        clearTimer.start()
    }

    // AGV hareket timer'ı
    Timer {
        id: agvMovementTimer
        interval: 50 // 50ms = 20 FPS
        repeat: true
        running: agvMoving && !emergencyStop && systemRunning
        onTriggered: {
            if (agvMoving && hasTarget && !emergencyStop && systemRunning) {
                // AGV'yi hedefe doğru hareket ettir
                moveAGVToTarget()
            }
        }
    }

    // Temizleme işlemi için timer
    Timer {
        id: clearTimer
        interval: 100
        repeat: false
        onTriggered: {
            console.log("Clear timer tetiklendi")
            // hasTarget'ı tekrar false yap ve canvas'ı yeniden çiz
            hasTarget = false
            navigationCanvas.requestPaint()
        }
    }

    // Batarya şarj timer'ı
    Timer {
        id: chargingTimer
        interval: 100  // 100ms = 0.1 saniye
        repeat: true
        running: isCharging && systemRunning && !emergencyStop
        onTriggered: {
            if (isCharging && batteryLevel < 100) {
                // Bataryayı şarj et
                batteryLevel = Math.min(100, batteryLevel + chargingSpeed * 0.1)
                chargingProgress = batteryLevel / 100

                // Batarya tamamen dolduğunda şarjı durdur
                if (batteryLevel >= 100) {
                    isCharging = false
                    chargingProgress = 1.0
                    console.log("Batarya tamamen şarj oldu!")

                    // Auto mode'da şarj tamamlandıysa normal hedeflere dön
                    if (autoMode && isGoingToCharging) {
                        // 3 saniye bekle ve normal hedeflere dön
                        returnToNormalTargetsTimer.start()
                    }
                }
            }
        }
    }

    // Auto mode hedef seçimi timer'ı
    Timer {
        id: autoTargetTimer
        interval: 3000  // 3 saniye
        repeat: true
        running: autoMode && systemRunning && !emergencyStop && !hasTarget
        onTriggered: {
            if (autoMode && systemRunning && !emergencyStop && !hasTarget) {
                selectNextAutoTarget()
            }
        }
    }

    // Auto mode hedef geçiş timer'ı
    Timer {
        id: autoTargetAdvanceTimer
        interval: 2000  // 2 saniye bekle
        repeat: false
        onTriggered: {
            if (autoMode && !emergencyStop && systemRunning) {
                advanceAutoTargetIndex()
                selectNextAutoTarget()
            }
        }
    }

    // Auto mode batarya kontrol timer'ı
    Timer {
        id: batteryCheckTimer
        interval: 1000  // 1 saniye
        repeat: true
        running: autoMode && systemRunning && !emergencyStop
        onTriggered: {
            if (autoMode && systemRunning && !emergencyStop) {
                checkBatteryLevel()
            }
        }
    }

    // Şarj tamamlandıktan sonra normal hedeflere dönme timer'ı
    Timer {
        id: returnToNormalTargetsTimer
        interval: 3000  // 3 saniye bekle
        repeat: false
        onTriggered: {
            if (autoMode && systemRunning && !emergencyStop) {
                returnToNormalTargets()
            }
        }
    }

    // Intro animasyon timer'ları
    Timer {
        id: introStartTimer
        interval: 500  // 0.5 saniye bekle
        repeat: false
        running: showIntro
        onTriggered: {
            introAnimation.start()
        }
    }

    Timer {
        id: introEndTimer
        interval: 6000  // 6 saniye sonra intro'yu kapat
        repeat: false
        running: showIntro
        onTriggered: {
            endIntroAnimation.start()
        }
    }

    Component.onCompleted: {
        x = Screen.width / 2 - width / 2
        y = Screen.height / 2 - height / 2
    }

    // Intro Ekranı
    Rectangle {
        id: introScreen
        anchors.fill: parent
        color: "#000000"
        visible: showIntro
        z: 1000

        // Gradient arka plan
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0a0a0a" }
            GradientStop { position: 0.5; color: "#1a1a2e" }
            GradientStop { position: 1.0; color: "#16213e" }
        }



        // Şirket ismi
        Text {
            id: companyName
            text: "MODOYA"
            font.pixelSize: 72
            font.bold: true
            color: "#FFD700"  // Sarı renk
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -30
            opacity: textOpacity
        }

        // Glow efekti için arka plan text
        Text {
            text: "MODOYA"
            font.pixelSize: 72
            font.bold: true
            color: "#FFD700"
            opacity: 0.3
            anchors.centerIn: companyName
            z: -1
        }

        // Alt başlık
        Text {
            id: subtitle
            text: "Teknoloji Çözümleri"
            font.pixelSize: 24
            color: textSecondary
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 30
            opacity: subtitleOpacity
        }

        // Progress bar
        Rectangle {
            id: progressBar
            width: 300
            height: 4
            color: "#333333"
            radius: 2
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 200

            Rectangle {
                width: parent.width * introProgress
                height: parent.height
                color: primaryColor
                radius: 2

                Behavior on width {
                    NumberAnimation { duration: 100 }
                }
            }
        }

        // Loading text
        Text {
            text: "Loading..."
            font.pixelSize: 16
            color: textSecondary
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 220
            opacity: subtitleOpacity
        }

        // Animasyonlar
        SequentialAnimation {
            id: introAnimation
            running: false

            // Progress bar animasyonu
            NumberAnimation {
                target: introProgress
                from: 0.0
                to: 1.0
                duration: 4000
            }

            // Text animasyonları
            ParallelAnimation {
                NumberAnimation {
                    target: companyName
                    property: "opacity"
                    from: 0.0
                    to: 1.0
                    duration: 1000
                }
                NumberAnimation {
                    target: subtitle
                    property: "opacity"
                    from: 0.0
                    to: 1.0
                    duration: 1000
                }
            }
        }

        // Intro bitiş animasyonu
        SequentialAnimation {
            id: endIntroAnimation
            running: false

            // Fade out animasyonu
            NumberAnimation {
                target: introScreen
                property: "opacity"
                from: 1.0
                to: 0.0
                duration: 1000
            }

            // Intro'yu gizle ve giriş ekranını göster
            ScriptAction {
                script: {
                    showIntro = false
                    introScreen.visible = false
                    showLogin = true
                }
            }
        }
    }

    // Kullanıcı Giriş Ekranı
    Rectangle {
        id: loginScreen
        anchors.fill: parent
        color: "#000000"
        visible: showLogin
        z: 1000

        // Gradient arka plan
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#000000" }
            GradientStop { position: 0.3; color: "#0a0a0a" }
            GradientStop { position: 0.7; color: "#1a1a1a" }
            GradientStop { position: 1.0; color: "#2a2a2a" }
        }

        // Logo container
        Rectangle {
            id: loginLogoContainer
            width: 200
            height: 200
            radius: 100
            color: "transparent"
            border.color: "#FFD700"
            border.width: 4
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -150

            // İç halka
            Rectangle {
                width: 150
                height: 150
                radius: 75
                color: "transparent"
                border.color: "#FFA500"
                border.width: 2
                anchors.centerIn: parent

                // Dönen animasyon
                RotationAnimation {
                    target: parent
                    from: 0
                    to: 360
                    duration: 5000
                    loops: Animation.Infinite
                    running: showLogin
                }
            }

            // Merkez daire
            Rectangle {
                width: 80
                height: 80
                radius: 40
                color: "#FFD700"
                anchors.centerIn: parent

                // Kilit simgesi
                Text {
                    text: "🔒"
                    font.pixelSize: 40
                    anchors.centerIn: parent
                }
            }
        }

        // Giriş başlığı
        Text {
            text: "MODOYA AGV Control System"
            font.pixelSize: 36
            font.bold: true
            color: "#FFD700"
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -50
        }

        // Giriş formu
        Rectangle {
            width: 400
            height: 300
            color: "#1a1a1a"
            radius: 20
            border.color: "#FFD700"
            border.width: 2
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 50

            // Glow efekti
            Rectangle {
                anchors.fill: parent
                radius: 20
                color: "transparent"
                border.color: "#FFD700"
                border.width: 1
                opacity: 0.3
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 30
                spacing: 20

                // Kullanıcı adı
                ColumnLayout {
                    spacing: 10

                    Label {
                        text: "👤 Kullanıcı Adı"
                        color: "#FFD700"
                        font.pixelSize: 16
                        font.bold: true
                    }

                    TextField {
                        id: usernameField
                        text: username
                        onTextChanged: username = text
                        placeholderText: "Kullanıcı adınızı girin"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40

                        background: Rectangle {
                            color: "#333333"
                            radius: 8
                            border.color: "#FFD700"
                            border.width: 1
                        }

                        color: "#FFFFFF"
                        font.pixelSize: 14
                        selectByMouse: true

                        Keys.onReturnPressed: passwordField.focus = true
                    }
                }

                // Şifre
                ColumnLayout {
                    spacing: 10

                    Label {
                        text: "🔑 Şifre"
                        color: "#FFD700"
                        font.pixelSize: 16
                        font.bold: true
                    }

                    TextField {
                        id: passwordField
                        text: password
                        onTextChanged: password = text
                        placeholderText: "Şifrenizi girin"
                        echoMode: TextInput.Password
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40

                        background: Rectangle {
                            color: "#333333"
                            radius: 8
                            border.color: "#FFD700"
                            border.width: 1
                        }

                        color: "#FFFFFF"
                        font.pixelSize: 14
                        selectByMouse: true

                        Keys.onReturnPressed: checkLogin()
                    }
                }

                // Hata mesajı
                Label {
                    text: errorMessage
                    color: "#FF4757"
                    font.pixelSize: 12
                    visible: loginError
                    Layout.alignment: Qt.AlignHCenter
                }

                // Giriş butonu
                Button {
                    text: "🚪 GİRİŞ YAP"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    Layout.topMargin: 20

                    background: Rectangle {
                        color: parent.pressed ? "#FFA500" : "#FFD700"
                        radius: 10
                        border.color: "#000000"
                        border.width: 2
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#000000"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 16
                        font.bold: true
                    }

                    onClicked: checkLogin()
                }

                // Bilgi metni
                Label {
                    text: "Demo: admin / 1234"
                    color: "#CCCCCC"
                    font.pixelSize: 12
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 10
                }
            }
        }
    }

    // Üst Toolbar
    Rectangle {
        id: topToolbar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60
        color: cardBg
        border.color: borderColor
        border.width: 2
        visible: !showIntro && !showLogin && isLoggedIn

        RowLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 20

            // Logo/Başlık
            Label {
                text: " AGV Control Center "
                color: primaryColor
                font.pixelSize: fontSizeLarge
                font.bold: true
            }

            Item { Layout.fillWidth: true }

            // Tema seçici
            ComboBox {
                id: themeSelector
                model: ["Default Theme", "Dark Theme", "Light Theme"]
                currentIndex: selectedTheme
                onCurrentIndexChanged: selectedTheme = currentIndex

                background: Rectangle {
                    color: cardBgHover
                    radius: 5
                    border.color: borderColor
                    border.width: 1
                }

                contentItem: Text {
                    text: parent.displayText
                    color: textPrimary
                    font.pixelSize: fontSizeSmall
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            // Gece modu toggle
            Switch {
                id: nightModeSwitch
                checked: nightMode
                onCheckedChanged: nightMode = checked

                indicator: Rectangle {
                    width: 50
                    height: 25
                    radius: 12.5
                    color: parent.checked ? primaryColor : cardBgHover
                    border.color: borderColor
                    border.width: 1

                    Rectangle {
                        width: 21
                        height: 21
                        radius: 10.5
                        color: "white"
                        anchors.verticalCenter: parent.verticalCenter
                        x: parent.checked ? parent.width - width - 2 : 2

                        Behavior on x {
                            NumberAnimation { duration: 200 }
                        }
                    }
                }
            }

                        Label {
                text: "🌙"
                color: textSecondary
                font.pixelSize: fontSizeMedium
            }

            // Ses toggle
            Switch {
                id: soundSwitch
                checked: soundEnabled
                onCheckedChanged: soundEnabled = checked

                indicator: Rectangle {
                    width: 50
                    height: 25
                    radius: 12.5
                    color: parent.checked ? successColor : cardBgHover
                    border.color: borderColor
                    border.width: 1

                    Rectangle {
                        width: 21
                        height: 21
                        radius: 10.5
                        color: "white"
                        anchors.verticalCenter: parent.verticalCenter
                        x: parent.checked ? parent.width - width - 2 : 2

                        Behavior on x {
                            NumberAnimation { duration: 200 }
                        }
                    }
                }
            }

            Label {
                text: "🔊"
                color: textSecondary
                font.pixelSize: fontSizeMedium
            }

            // Uyarı sayısı
            Rectangle {
                width: 30
                height: 30
                radius: 15
                color: alertCount > 0 ? warningColor : cardBgHover
                border.color: borderColor
                border.width: 1

                Label {
                    anchors.centerIn: parent
                    text: alertCount.toString()
                    color: "white"
                    font.pixelSize: fontSizeSmall
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: showAlerts = !showAlerts
                }
            }
        }
    }

    // Ana layout
    RowLayout {
        anchors.fill: parent
        anchors.topMargin: 80
        anchors.margins: 20
        spacing: 20
        visible: !showIntro && !showLogin && isLoggedIn

        // Sol Panel - Kontrol Paneli
        Rectangle {
            Layout.preferredWidth: 400
            Layout.fillHeight: true
            color: cardBg
            radius: 15
            border.color: borderColor
            border.width: 2

            // Hover efekti
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: parent.color = cardBgHover
                onExited: parent.color = cardBg
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                // Başlık
                Label {
                    text: "AGV CONTROL PANEL"
                    color: primaryColor
                    font.pixelSize: fontSizeLarge
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                // Acil Durum Butonu
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: emergencyStop ? warningColor : "#333"
                    radius: 10
                    border.color: emergencyStop ? "#fff" : "transparent"
                    border.width: 2

                    Label {
                        anchors.centerIn: parent
                        text: emergencyStop ? "EMERGENCY STOP ACTIVE" : "EMERGENCY STOP"
                        color: "#fff"
                        font.pixelSize: fontSizeMedium
                        font.bold: true
                    }

                                         MouseArea {
                         anchors.fill: parent
                         onClicked: {
                             emergencyStop = !emergencyStop

                             // Emergency stop aktif olduğunda hızı sıfırla
                             if (emergencyStop) {
                                 speed = 0
                             }
                         }
                     }
                }

                // Normal Start/Stop Butonu
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: systemRunning ? successColor : "#333"
                    radius: 10
                    border.color: systemRunning ? "#fff" : "transparent"
                    border.width: 2

                    Label {
                        anchors.centerIn: parent
                        text: systemRunning ? "SYSTEM RUNNING" : "START SYSTEM"
                        color: "#fff"
                        font.pixelSize: fontSizeMedium
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            systemRunning = !systemRunning

                            // Sistem durduğunda hızı sıfırla
                            if (!systemRunning) {
                                speed = 0
                                agvMoving = false
                            }
                        }
                    }
                }

                // Mod Seçimi
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Button {
                        text: "AUTO"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        background: Rectangle {
                            color: autoMode ? accentColor : "#333"
                            radius: 8
                        }
                        contentItem: Text {
                            text: parent.text
                            color: autoMode ? "#000" : "#fff"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: fontSizeMedium
                            font.bold: true
                        }
                        onClicked: autoMode = true
                    }

                    Button {
                        text: "MANUAL"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        background: Rectangle {
                            color: !autoMode ? secondaryColor : "#333"
                            radius: 8
                        }
                        contentItem: Text {
                            text: parent.text
                            color: !autoMode ? "#000" : "#fff"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: fontSizeMedium
                            font.bold: true
                        }
                        onClicked: autoMode = false
                    }
                }

                // Hız Kontrolü
                GroupBox {
                    title: "SPEED CONTROL"
                    Layout.fillWidth: true
                    label: Label {
                        text: parent.title
                        color: primaryColor
                        font.pixelSize: fontSizeMedium
                        font.bold: true
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10

                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 10

                            Label {
                                text: "🏃"
                                font.pixelSize: fontSizeLarge
                            }

                            Label {
                                text: speed.toFixed(1) + " km/h"
                                color: accentColor
                                font.pixelSize: fontSizeLarge
                                font.bold: true
                            }
                        }

                        Slider {
                            id: speedSlider
                            from: 0
                            to: 25
                            value: speed
                            Layout.fillWidth: true
                            enabled: !autoMode
                            onValueChanged: if (!autoMode) speed = value

                            background: Rectangle {
                                x: speedSlider.leftPadding
                                y: speedSlider.topPadding + speedSlider.availableHeight / 2 - height / 2
                                width: speedSlider.availableWidth
                                height: 4
                                radius: 2
                                color: "#cccccc"

                                Rectangle {
                                    width: speedSlider.visualPosition * parent.width
                                    height: parent.height
                                    color: accentColor
                                    radius: 2
                                }
                            }

                            handle: Rectangle {
                                x: speedSlider.leftPadding + speedSlider.visualPosition * (speedSlider.availableWidth - width)
                                y: speedSlider.topPadding + speedSlider.availableHeight / 2 - height / 2
                                width: 20
                                height: 20
                                radius: 10
                                color: speedSlider.pressed ? "#fff" : accentColor
                                border.color: "#fff"
                                border.width: 2
                            }
                        }
                    }
                }

                // Yön Kontrolü
                GroupBox {
                    title: "DIRECTION CONTROL"
                    Layout.fillWidth: true
                    label: Label {
                        text: parent.title
                        color: primaryColor
                        font.pixelSize: fontSizeMedium
                        font.bold: true
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10

                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 10

                            Label {
                                text: "🎯"
                                font.pixelSize: fontSizeLarge
                            }

                            Label {
                                text: wheelAngle.toFixed(1) + "°"
                                color: secondaryColor
                                font.pixelSize: fontSizeLarge
                                font.bold: true
                            }
                        }

                        Slider {
                            id: angleSlider
                            from: -45
                            to: 45
                            value: wheelAngle
                            Layout.fillWidth: true
                            enabled: !autoMode
                            onValueChanged: if (!autoMode) wheelAngle = value

                            background: Rectangle {
                                x: angleSlider.leftPadding
                                y: angleSlider.topPadding + angleSlider.availableHeight / 2 - height / 2
                                width: angleSlider.availableWidth
                                height: 4
                                radius: 2
                                color: "#cccccc"

                                Rectangle {
                                    width: (angleSlider.value - angleSlider.from) / (angleSlider.to - angleSlider.from) * parent.width
                                    height: parent.height
                                    color: secondaryColor
                                    radius: 2
                                }
                            }

                            handle: Rectangle {
                                x: angleSlider.leftPadding + (angleSlider.value - angleSlider.from) / (angleSlider.to - angleSlider.from) * (angleSlider.availableWidth - width)
                                y: angleSlider.topPadding + angleSlider.availableHeight / 2 - height / 2
                                width: 20
                                height: 20
                                radius: 10
                                color: angleSlider.pressed ? "#fff" : secondaryColor
                                border.color: "#fff"
                                border.width: 2
                            }
                        }
                    }
                }

                // Yük Kontrolü
                GroupBox {
                    title: "LOAD MANAGEMENT"
                    Layout.fillWidth: true
                    label: Label {
                        text: parent.title
                        color: primaryColor
                        font.pixelSize: fontSizeMedium
                        font.bold: true
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10

                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 10

                            Label {
                                text: "📦"
                                font.pixelSize: fontSizeLarge
                            }

                            Label {
                                text: loadWeight.toFixed(1) + " kg"
                                color: loadWeight > 200 ? warningColor : successColor
                                font.pixelSize: fontSizeLarge
                                font.bold: true
                            }
                        }

                        ProgressBar {
                            value: loadWeight / 300
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20

                            background: Rectangle {
                                radius: 10
                                color: "#333"
                            }

                            contentItem: Item {
                                Rectangle {
                                    width: parent.width * parent.parent.value
                                    height: parent.height
                                    radius: 10
                                    color: loadWeight > 200 ? warningColor : successColor
                                }
                            }
                        }

                        Label {
                            text: "Max: 300 KG Capacity!"
                            color: textSecondary
                            font.pixelSize: fontSizeSmall
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }

                // Navigasyon Kontrolü
                GroupBox {
                    title: "NAVIGATION"
                    Layout.fillWidth: true
                    label: Label {
                        text: parent.title
                        color: primaryColor
                        font.pixelSize: fontSizeMedium
                        font.bold: true
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Label {
                                text: "🗺️"
                                font.pixelSize: fontSizeMedium
                            }

                            Switch {
                                text: "Navigation Active"
                                checked: navigationActive
                                Layout.fillWidth: true
                                onCheckedChanged: navigationActive = checked
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Label {
                                text: "🎯"
                                font.pixelSize: fontSizeSmall
                            }

                            Label {
                                text: "To: " + destination
                                color: textSecondary
                                font.pixelSize: fontSizeSmall
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }

                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 5

                            Label {
                                text: "📏"
                                font.pixelSize: fontSizeMedium
                            }

                            Label {
                                text: distanceToTarget.toFixed(1) + "m remaining"
                                color: accentColor
                                font.pixelSize: fontSizeMedium
                            }
                        }

                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 5

                            Label {
                                text: "⏱️"
                                font.pixelSize: fontSizeSmall
                            }

                            Label {
                                text: "ETA: " + estimatedTime.toFixed(1) + " min"
                                color: textSecondary
                                font.pixelSize: fontSizeSmall
                            }
                        }
                    }
                }
            }
        }

        // Orta Panel - AGV Modeli ve Harita
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: cardBg
            radius: 15
            border.color: borderColor
            border.width: 2

            // Hover efekti
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: parent.color = cardBgHover
                onExited: parent.color = cardBg
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                // Üst Bilgi Çubuğu
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20

                    // Batarya Durumu
                    Rectangle {
                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 60
                        color: cardBg
                        radius: 10
                        border.color: borderColor
                        border.width: 1

                        // Hover efekti
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: parent.color = cardBgHover
                            onExited: parent.color = cardBg
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10

                            Rectangle {
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                color: isCharging ? successColor : (batteryLevel > 20 ? successColor : warningColor)
                                radius: 5

                                Label {
                                    anchors.centerIn: parent
                                    text: isCharging ? "⚡" : "🔋"
                                    font.pixelSize: 20
                                }
                            }

                            ColumnLayout {
                                Label {
                                    text: batteryLevel.toFixed(1) + "%"
                                    color: textPrimary
                                    font.pixelSize: fontSizeMedium
                                    font.bold: true
                                }
                                Label {
                                    text: isCharging ? "Charging..." : "Battery"
                                    color: isCharging ? successColor : textSecondary
                                    font.pixelSize: fontSizeSmall
                                }
                            }
                        }
                    }

                    // Sıcaklık
                    Rectangle {
                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 60
                        color: cardBg
                        radius: 10
                        border.color: borderColor
                        border.width: 1

                        // Hover efekti
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: parent.color = cardBgHover
                            onExited: parent.color = cardBg
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10

                            Rectangle {
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                color: temperature > 50 ? warningColor : primaryColor
                                radius: 5

                                Label {
                                    anchors.centerIn: parent
                                    text: "🌡️"
                                    font.pixelSize: 20
                                }
                            }

                            ColumnLayout {
                                Label {
                                    text: temperature.toFixed(1) + "°C"
                                    color: textPrimary
                                    font.pixelSize: fontSizeMedium
                                    font.bold: true
                                }
                                Label {
                                    text: "Temperature"
                                    color: textSecondary
                                    font.pixelSize: fontSizeSmall
                                }
                            }
                        }
                    }

                                                // Motor RPM
                            Rectangle {
                                Layout.preferredWidth: 200
                                Layout.preferredHeight: 60
                                color: cardBg
                                radius: 10
                                border.color: borderColor
                                border.width: 1

                                // Hover efekti
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: parent.color = cardBgHover
                                    onExited: parent.color = cardBg
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10

                                    Rectangle {
                                        Layout.preferredWidth: 40
                                        Layout.preferredHeight: 40
                                        color: motorRPM > 2000 ? warningColor : accentColor
                                        radius: 5

                                        Label {
                                            anchors.centerIn: parent
                                            text: "⚙️"
                                            font.pixelSize: 20
                                        }
                                    }

                            ColumnLayout {
                                Label {
                                    text: motorRPM.toFixed(0) + " RPM"
                                    color: textPrimary
                                    font.pixelSize: fontSizeMedium
                                    font.bold: true
                                }
                                Label {
                                    text: "Motor"
                                    color: textSecondary
                                    font.pixelSize: fontSizeSmall
                                }
                            }
                        }
                    }

                    // Voltaj
                    Rectangle {
                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 60
                        color: cardBg
                        radius: 10
                        border.color: borderColor
                        border.width: 1

                        // Hover efekti
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: parent.color = cardBgHover
                            onExited: parent.color = cardBg
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10

                            Rectangle {
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                color: voltage < 40 ? warningColor : successColor
                                radius: 5

                                Label {
                                    anchors.centerIn: parent
                                    text: "⚡"
                                    font.pixelSize: 20
                                }
                            }

                            ColumnLayout {
                                Label {
                                    text: voltage.toFixed(1) + "V"
                                    color: textPrimary
                                    font.pixelSize: fontSizeMedium
                                    font.bold: true
                                }
                                Label {
                                    text: "Voltage"
                                    color: textSecondary
                                    font.pixelSize: fontSizeSmall
                                }
                            }
                        }
                    }
                }

                // AGV Modeli ve Harita Alanı
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                                             color: "#f0f0f0"
                    radius: 10

                                         // AGV Modeli (Modern 2D Temsil)
                     Rectangle {
                         id: agvModel
                         width: 240
                         height: 140

                         // Modern gradient renk - daha sofistike
                         gradient: Gradient {
                             GradientStop { position: 0.0; color: "#2c3e50" }
                             GradientStop { position: 0.3; color: "#34495e" }
                             GradientStop { position: 0.7; color: "#3498db" }
                             GradientStop { position: 1.0; color: "#2980b9" }
                         }

                         radius: 25

                         // Gelişmiş gölge efekti
                         border.color: "#1a252f"
                         border.width: 3

                         // AGV'nin dinamik pozisyonu
                         x: agvCurrentX
                         y: agvCurrentY

                         // AGV durumu güncelleme
                         Component.onCompleted: {
                             // AGV'nin başlangıç pozisyonunu ayarla
                             agvCurrentX = 100
                             agvCurrentY = 200
                             agvTargetX = 100
                             agvTargetY = 200
                         }

                         // Ana gövde detayları
                         Rectangle {
                             width: parent.width * 0.85
                             height: parent.height * 0.7
                             color: "transparent"
                             radius: 20
                             anchors.centerIn: parent
                             border.color: "#ecf0f1"
                             border.width: 2
                             opacity: 0.3
                         }

                         // Üst panel
                         Rectangle {
                             width: parent.width * 0.9
                             height: parent.height * 0.25
                             color: "#34495e"
                             radius: 15
                             anchors.top: parent.top
                             anchors.topMargin: 8
                             anchors.horizontalCenter: parent.horizontalCenter

                             // Üst panel detayları
                             Rectangle {
                                 width: parent.width * 0.8
                                 height: 3
                                 color: "#3498db"
                                 radius: 2
                                 anchors.centerIn: parent
                             }
                         }

                         // Alt panel
                         Rectangle {
                             width: parent.width * 0.9
                             height: parent.height * 0.25
                             color: "#2c3e50"
                             radius: 15
                             anchors.bottom: parent.bottom
                             anchors.bottomMargin: 8
                             anchors.horizontalCenter: parent.horizontalCenter
                         }

                                                 // Modern Tekerlekler
                         Rectangle {
                             id: leftWheel
                             width: 35
                             height: 35
                             color: "#2c3e50"
                             radius: 17.5
                             anchors.left: parent.left
                             anchors.leftMargin: 15
                             anchors.verticalCenter: parent.verticalCenter
                             border.color: "#ecf0f1"
                             border.width: 2

                             // Tekerlek detayları
                             Rectangle {
                                 width: parent.width * 0.6
                                 height: parent.height * 0.6
                                 color: "#34495e"
                                 radius: parent.radius * 0.6
                                 anchors.centerIn: parent
                                 border.color: "#3498db"
                                 border.width: 1
                             }

                             // Tekerlek döndürme animasyonu
                             RotationAnimation {
                                 target: leftWheel
                                 from: 0
                                 to: 360
                                 duration: (emergencyStop || !agvMoving || !systemRunning) ? 0 : 2000
                                 loops: Animation.Infinite
                                 running: !emergencyStop && agvMoving && systemRunning
                             }
                         }

                         Rectangle {
                             id: rightWheel
                             width: 35
                             height: 35
                             color: "#2c3e50"
                             radius: 17.5
                             anchors.right: parent.right
                             anchors.rightMargin: 15
                             anchors.verticalCenter: parent.verticalCenter
                             border.color: "#ecf0f1"
                             border.width: 2

                             // Tekerlek detayları
                             Rectangle {
                                 width: parent.width * 0.6
                                 height: parent.height * 0.6
                                 color: "#34495e"
                                 radius: parent.radius * 0.6
                                 anchors.centerIn: parent
                                 border.color: "#3498db"
                                 border.width: 1
                             }

                             // Tekerlek döndürme animasyonu
                             RotationAnimation {
                                 target: rightWheel
                                 from: 0
                                 to: 360
                                 duration: (emergencyStop || !agvMoving || !systemRunning) ? 0 : 2000
                                 loops: Animation.Infinite
                                 running: !emergencyStop && agvMoving && systemRunning
                             }
                         }

                        // Modern yön göstergesi
                        Rectangle {
                            width: 6
                            height: 50
                            color: "#e74c3c"
                            radius: 3
                            anchors.centerIn: parent
                            transform: Rotation {
                                origin.x: 3
                                origin.y: 25
                                angle: wheelAngle
                            }

                            // Yön göstergesi detayı
                            Rectangle {
                                width: 8
                                height: 8
                                color: "#c0392b"
                                radius: 4
                                anchors.top: parent.top
                                anchors.topMargin: -4
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }

                                                 // Modern Sensör göstergeleri
                         Rectangle {
                             id: frontSensor
                             width: 12
                             height: 12
                             color: frontDistance < 1 ? "#e74c3c" : "#27ae60"
                             radius: 6
                             anchors.top: parent.top
                             anchors.topMargin: 8
                             anchors.horizontalCenter: parent.horizontalCenter
                             border.color: "#ffffff"
                             border.width: 1

                             // Sensör yanıp sönme animasyonu
                             SequentialAnimation {
                                 running: !emergencyStop && agvMoving && systemRunning
                                 loops: Animation.Infinite
                                 NumberAnimation {
                                     target: frontSensor
                                     property: "opacity"
                                     from: 0.4
                                     to: 1.0
                                     duration: 2000
                                 }
                                 NumberAnimation {
                                     target: frontSensor
                                     property: "opacity"
                                     from: 1.0
                                     to: 0.4
                                     duration: 2000
                                 }
                             }

                             // Sensör ışık efekti
                             Rectangle {
                                 width: parent.width * 1.5
                                 height: parent.height * 1.5
                                 color: "transparent"
                                 radius: parent.radius * 1.5
                                 anchors.centerIn: parent
                                 border.color: frontDistance < 1 ? "#e74c3c" : "#27ae60"
                                 border.width: 1
                                 opacity: 0.3
                             }
                         }

                         Rectangle {
                             id: rearSensor
                             width: 12
                             height: 12
                             color: rearDistance < 1 ? "#e74c3c" : "#27ae60"
                             radius: 6
                             anchors.bottom: parent.bottom
                             anchors.bottomMargin: 8
                             anchors.horizontalCenter: parent.horizontalCenter
                             border.color: "#ffffff"
                             border.width: 1

                             // Sensör yanıp sönme animasyonu
                             SequentialAnimation {
                                 running: !emergencyStop && agvMoving && systemRunning
                                 loops: Animation.Infinite
                                 NumberAnimation {
                                     target: rearSensor
                                     property: "opacity"
                                     from: 0.4
                                     to: 1.0
                                     duration: 2400
                                 }
                                 NumberAnimation {
                                     target: rearSensor
                                     property: "opacity"
                                     from: 1.0
                                     to: 0.4
                                     duration: 2400
                                 }
                             }

                             // Sensör ışık efekti
                             Rectangle {
                                 width: parent.width * 1.5
                                 height: parent.height * 1.5
                                 color: "transparent"
                                 radius: parent.radius * 1.5
                                 anchors.centerIn: parent
                                 border.color: rearDistance < 1 ? "#e74c3c" : "#27ae60"
                                 border.width: 1
                                 opacity: 0.3
                             }
                         }

                         Rectangle {
                             id: leftSensor
                             width: 12
                             height: 12
                             color: leftDistance < 0.5 ? "#e74c3c" : "#27ae60"
                             radius: 6
                             anchors.left: parent.left
                             anchors.leftMargin: 8
                             anchors.verticalCenter: parent.verticalCenter
                             border.color: "#ffffff"
                             border.width: 1

                             // Sensör yanıp sönme animasyonu
                             SequentialAnimation {
                                 running: !emergencyStop && agvMoving && systemRunning
                                 loops: Animation.Infinite
                                 NumberAnimation {
                                     target: leftSensor
                                     property: "opacity"
                                     from: 0.4
                                     to: 1.0
                                     duration: 2800
                                 }
                                 NumberAnimation {
                                     target: leftSensor
                                     property: "opacity"
                                     from: 1.0
                                     to: 0.4
                                     duration: 2800
                                 }
                             }

                             // Sensör ışık efekti
                             Rectangle {
                                 width: parent.width * 1.5
                                 height: parent.height * 1.5
                                 color: "transparent"
                                 radius: parent.radius * 1.5
                                 anchors.centerIn: parent
                                 border.color: leftDistance < 0.5 ? "#e74c3c" : "#27ae60"
                                 border.width: 1
                                 opacity: 0.3
                             }
                         }

                         Rectangle {
                             id: rightSensor
                             width: 12
                             height: 12
                             color: rightDistance < 0.5 ? "#e74c3c" : "#27ae60"
                             radius: 6
                             anchors.right: parent.right
                             anchors.rightMargin: 8
                             anchors.verticalCenter: parent.verticalCenter
                             border.color: "#ffffff"
                             border.width: 1

                             // Sensör yanıp sönme animasyonu
                             SequentialAnimation {
                                 running: !emergencyStop && agvMoving && systemRunning
                                 loops: Animation.Infinite
                                 NumberAnimation {
                                     target: rightSensor
                                     property: "opacity"
                                     from: 0.4
                                     to: 1.0
                                     duration: 3200
                                 }
                                 NumberAnimation {
                                     target: rightSensor
                                     property: "opacity"
                                     from: 1.0
                                     to: 0.4
                                     duration: 3200
                                 }
                             }

                             // Sensör ışık efekti
                             Rectangle {
                                 width: parent.width * 1.5
                                 height: parent.height * 1.5
                                 color: "transparent"
                                 radius: parent.radius * 1.5
                                 anchors.centerIn: parent
                                 border.color: rightDistance < 0.5 ? "#e74c3c" : "#27ae60"
                                 border.width: 1
                                 opacity: 0.3
                             }
                         }

                        // Modern yük göstergesi
                        Rectangle {
                            width: parent.width * 0.85
                            height: 25
                            color: loadWeight > 200 ? "#e74c3c" : "#27ae60"
                            radius: 12
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 8
                            anchors.horizontalCenter: parent.horizontalCenter
                            border.color: "#ffffff"
                            border.width: 1

                            // Yük göstergesi detayları
                            Rectangle {
                                width: parent.width * 0.9
                                height: 3
                                color: "#ffffff"
                                radius: 2
                                anchors.centerIn: parent
                                opacity: 0.5
                            }

                            Label {
                                anchors.centerIn: parent
                                text: loadWeight.toFixed(0) + " kg"
                                color: "#ffffff"
                                font.pixelSize: fontSizeSmall
                                font.bold: true
                            }

                            // Yük ikonu
                            Label {
                                text: "📦"
                                font.pixelSize: 12
                                anchors.left: parent.left
                                anchors.leftMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    // Mesafe göstergeleri
                    Label {
                        text: frontDistance.toFixed(1) + "m"
                        color: frontDistance < 1 ? warningColor : textSecondary
                        font.pixelSize: fontSizeSmall
                        anchors.top: agvModel.top
                        anchors.topMargin: -30
                        anchors.horizontalCenter: agvModel.horizontalCenter
                    }

                    Label {
                        text: rearDistance.toFixed(1) + "m"
                        color: rearDistance < 1 ? warningColor : textSecondary
                        font.pixelSize: fontSizeSmall
                        anchors.bottom: agvModel.bottom
                        anchors.bottomMargin: -30
                        anchors.horizontalCenter: agvModel.horizontalCenter
                    }

                    Label {
                        text: leftDistance.toFixed(1) + "m"
                        color: leftDistance < 0.5 ? warningColor : textSecondary
                        font.pixelSize: fontSizeSmall
                        anchors.left: agvModel.left
                        anchors.leftMargin: -40
                        anchors.verticalCenter: agvModel.verticalCenter
                    }

                    Label {
                        text: rightDistance.toFixed(1) + "m"
                        color: rightDistance < 0.5 ? warningColor : textSecondary
                        font.pixelSize: fontSizeSmall
                        anchors.right: agvModel.right
                        anchors.rightMargin: -40
                        anchors.verticalCenter: agvModel.verticalCenter
                    }

                    // Lidar verisi
                    Label {
                        text: "LiDAR: " + lidarData.toFixed(1) + "m"
                        color: textSecondary
                        font.pixelSize: fontSizeSmall
                        anchors.top: parent.top
                        anchors.topMargin: 20
                        anchors.right: parent.right
                        anchors.rightMargin: 20
                    }
                }
            }
        }

        // Sağ Panel - Veri Monitörü ve Navigasyon
        Rectangle {
            Layout.preferredWidth: 450
            Layout.fillHeight: true
            color: cardBg
            radius: 15
            border.color: borderColor
            border.width: 2

            // Hover efekti
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: parent.color = cardBgHover
                onExited: parent.color = cardBg
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                // Başlık
                Label {
                    text: "DATA MONITOR & NAVIGATION"
                    color: primaryColor
                    font.pixelSize: fontSizeLarge
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                // Gerçek Zamanlı Veriler
                GroupBox {
                    title: "REAL-TIME DATA"
                    Layout.fillWidth: true
                    label: Label {
                        text: parent.title
                        color: primaryColor
                        font.pixelSize: fontSizeMedium
                        font.bold: true
                    }

                    GridLayout {
                        anchors.fill: parent
                        columns: 2
                        rowSpacing: 10
                        columnSpacing: 15

                        // Hız
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            color: cardBg
                            radius: 8
                            border.color: borderColor
                            border.width: 1

                            // Hover efekti
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.color = cardBgHover
                                onExited: parent.color = cardBg
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10

                                Label {
                                    text: "Speed:"
                                    color: textSecondary
                                    font.pixelSize: fontSizeSmall
                                }

                                Label {
                                    text: speed.toFixed(1) + " km/h"
                                    color: accentColor
                                    font.pixelSize: fontSizeMedium
                                    font.bold: true
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignRight
                                }
                            }
                        }

                        // Akım
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            color: cardBg
                            radius: 8
                            border.color: borderColor
                            border.width: 1

                            // Hover efekti
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.color = cardBgHover
                                onExited: parent.color = cardBg
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10

                                Label {
                                    text: "Current:"
                                    color: textSecondary
                                    font.pixelSize: fontSizeSmall
                                }

                                Label {
                                    text: current.toFixed(1) + " A"
                                    color: secondaryColor
                                    font.pixelSize: fontSizeMedium
                                    font.bold: true
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignRight
                                }
                            }
                        }

                        // Tekerlek Açısı
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            color: cardBg
                            radius: 8
                            border.color: borderColor
                            border.width: 1

                            // Hover efekti
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.color = cardBgHover
                                onExited: parent.color = cardBg
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10

                                Label {
                                    text: "Wheel Angle:"
                                    color: textSecondary
                                    font.pixelSize: fontSizeSmall
                                }

                                Label {
                                    text: wheelAngle.toFixed(1) + "°"
                                    color: secondaryColor
                                    font.pixelSize: fontSizeMedium
                                    font.bold: true
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignRight
                                }
                            }
                        }

                        // Yük Ağırlığı
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            color: cardBg
                            radius: 8
                            border.color: borderColor
                            border.width: 1

                            // Hover efekti
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.color = cardBgHover
                                onExited: parent.color = cardBg
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10

                                Label {
                                    text: "Load Weight:"
                                    color: textSecondary
                                    font.pixelSize: fontSizeSmall
                                }

                                Label {
                                    text: loadWeight.toFixed(1) + " kg"
                                    color: loadWeight > 200 ? warningColor : successColor
                                    font.pixelSize: fontSizeMedium
                                    font.bold: true
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignRight
                                }
                            }
                        }
                    }
                }

                // Navigasyon Haritası
                GroupBox {
                    title: "NAVIGATION MAP"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    label: Label {
                        text: parent.title
                        color: primaryColor
                        font.pixelSize: fontSizeMedium
                        font.bold: true
                    }

                    // Temizleme butonu
                    Button {
                        id: clearTargetButton
                        text: autoMode ? "AUTO MODE" : "🗑️ TEMİZLE"
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: 5
                        anchors.rightMargin: 10
                        width: 100
                        height: 30
                        z: 10
                        enabled: !autoMode

                        background: Rectangle {
                            color: autoMode ? "#666666" : (clearTargetButton.pressed ? "#ff6b6b" : "#ff4757")
                            radius: 5
                            border.color: "#ffffff"
                            border.width: 1
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "#ffffff"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: fontSizeSmall
                            font.bold: true
                        }

                        onClicked: {
                            console.log("Temizle butonu tıklandı")
                            clearAllTargets()
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: "#f0f0f0"
                        radius: 10

                        // Basit harita temsili
                        Canvas {
                            id: navigationCanvas
                            anchors.fill: parent
                            anchors.margins: 20

                            // Property değişikliklerini dinle ve Canvas'ı yeniden çiz
                            property bool lastHasTarget: hasTarget
                            property bool lastForceRedraw: forceRedraw
                            property bool lastTargetsCleared: targetsCleared
                            property real lastAgvCurrentX: agvCurrentX
                            property real lastAgvCurrentY: agvCurrentY

                            onLastHasTargetChanged: {
                                console.log("hasTarget değişti:", hasTarget)
                                requestPaint()
                            }
                            onLastForceRedrawChanged: {
                                console.log("forceRedraw değişti:", forceRedraw)
                                requestPaint()
                            }
                            onLastTargetsClearedChanged: {
                                console.log("targetsCleared değişti:", targetsCleared)
                                requestPaint()
                            }
                            onLastAgvCurrentXChanged: {
                                console.log("AGV X pozisyonu değişti:", agvCurrentX)
                                requestPaint()
                            }
                            onLastAgvCurrentYChanged: {
                                console.log("AGV Y pozisyonu değişti:", agvCurrentY)
                                requestPaint()
                            }

                            onPaint: {
                                var ctx = getContext("2d")

                                // Canvas'ı tamamen temizle
                                ctx.clearRect(0, 0, width, height)

                                ctx.strokeStyle = "#666666"
                                ctx.lineWidth = 1

                                // Grid çizgileri
                                for (var i = 0; i < width; i += 50) {
                                    ctx.beginPath()
                                    ctx.moveTo(i, 0)
                                    ctx.lineTo(i, height)
                                    ctx.stroke()
                                }
                                for (var j = 0; j < height; j += 50) {
                                    ctx.beginPath()
                                    ctx.moveTo(0, j)
                                    ctx.lineTo(width, j)
                                    ctx.stroke()
                                }

                                // AGV pozisyonu (gerçek pozisyon)
                                ctx.fillStyle = primaryColor
                                ctx.beginPath()
                                ctx.arc(agvCurrentX, agvCurrentY, 15, 0, 2 * Math.PI)
                                ctx.fill()

                                // AGV etiketi
                                ctx.fillStyle = "#000000"
                                ctx.font = "12px Arial"
                                ctx.textAlign = "center"
                                ctx.fillText("AGV", agvCurrentX, agvCurrentY + 5)

                                // Hedef nokta mouse kontrolü
                                console.log("Canvas çiziliyor - hasTarget değeri:", hasTarget, "targetsCleared:", targetsCleared)
                                if (hasTarget === true && !targetsCleared) {
                                    // Auto mode'da şarj istasyonuna gidiyorsa farklı renk kullan
                                    var targetColor = (autoMode && isGoingToCharging) ? warningColor : accentColor
                                    var targetText = (autoMode && isGoingToCharging) ? "ŞARJ" : "HEDEF"

                                    ctx.fillStyle = targetColor
                                    ctx.beginPath()
                                    ctx.arc(width * targetX, height * targetY, 12, 0, 2 * Math.PI)
                                    ctx.fill()

                                    // Hedef etiketi
                                    ctx.fillStyle = "#000000"
                                    ctx.font = "10px Arial"
                                    ctx.textAlign = "center"
                                    ctx.fillText(targetText, width * targetX, height * targetY + 5)

                                    // Rota çizgisi
                                    ctx.strokeStyle = targetColor
                                    ctx.lineWidth = 3
                                    ctx.beginPath()
                                    ctx.moveTo(agvCurrentX, agvCurrentY)
                                    ctx.lineTo(width * targetX, height * targetY)
                                    ctx.stroke()
                                }

                                // Şarj istasyonu
                                var chargingStationCanvasX = width * chargingStationX
                                var chargingStationCanvasY = height * chargingStationY

                                // Şarj istasyonu arka planı
                                ctx.fillStyle = isCharging ? successColor : primaryColor
                                ctx.beginPath()
                                ctx.arc(chargingStationCanvasX, chargingStationCanvasY, 25, 0, 2 * Math.PI)
                                ctx.fill()

                                // Şarj istasyonu etiketi
                                ctx.fillStyle = "#ffffff"
                                ctx.font = "bold 12px Arial"
                                ctx.textAlign = "center"
                                                                 ctx.fillText("🔋", chargingStationCanvasX, chargingStationCanvasY + 4)

                                // Şarj durumu göstergesi
                                if (isCharging) {
                                    // Şarj progress bar
                                    ctx.strokeStyle = "#ffffff"
                                    ctx.lineWidth = 3
                                    ctx.beginPath()
                                    ctx.arc(chargingStationCanvasX, chargingStationCanvasY, 30, -Math.PI/2, -Math.PI/2 + 2 * Math.PI * chargingProgress)
                                    ctx.stroke()

                                    // Şarj yazısı
                                    ctx.fillStyle = "#ffffff"
                                    ctx.font = "10px Arial"
                                    ctx.textAlign = "center"
                                    ctx.fillText("ŞARJ", chargingStationCanvasX, chargingStationCanvasY + 40)
                                }

                                // Auto mode hedefleri (sadece auto mode'da göster)
                                if (autoMode) {
                                    for (var i = 0; i < autoTargets.length; i++) {
                                        var autoTarget = autoTargets[i]
                                        var autoTargetCanvasX = width * autoTarget.x
                                        var autoTargetCanvasY = height * autoTarget.y

                                        // Mevcut hedef mi kontrol et
                                        var isCurrentTarget = (i === currentAutoTargetIndex && hasTarget && !targetsCleared)

                                        // Auto hedef noktası
                                        ctx.fillStyle = isCurrentTarget ? accentColor : secondaryColor
                                        ctx.beginPath()
                                        ctx.arc(autoTargetCanvasX, autoTargetCanvasY, 8, 0, 2 * Math.PI)
                                        ctx.fill()

                                        // Auto hedef etiketi
                                        ctx.fillStyle = "#000000"
                                        ctx.font = "bold 10px Arial"
                                        ctx.textAlign = "center"
                                        ctx.fillText(autoTarget.name, autoTargetCanvasX, autoTargetCanvasY + 20)

                                        // Mevcut hedef için rota çizgisi
                                        if (isCurrentTarget) {
                                            ctx.strokeStyle = accentColor
                                            ctx.lineWidth = 2
                                            ctx.setLineDash([5, 5])  // Kesikli çizgi
                                            ctx.beginPath()
                                            ctx.moveTo(agvCurrentX, agvCurrentY)
                                            ctx.lineTo(autoTargetCanvasX, autoTargetCanvasY)
                                            ctx.stroke()
                                            ctx.setLineDash([])  // Kesikli çizgiyi sıfırla
                                        }
                                    }
                                }

                                // Engeller
                                ctx.fillStyle = warningColor
                                ctx.fillRect(width * 0.3, height * 0.4, 30, 30)
                                ctx.fillRect(width * 0.6, height * 0.7, 25, 25)

                                // Mouse pozisyonu göstergesi - kaldırıldı çünkü mouseX/mouseY readonly
                            }

                            // Mouse kontrolü
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true

                                onPositionChanged: {
                                    // mouseX ve mouseY readonly olduğu için bu satırları kaldırıyoruz
                                    // Sadece Canvas'ı yeniden çiz
                                    navigationCanvas.requestPaint()
                                }

                                onClicked: {
                                    // Sadece manuel mode'da mouse click çalışsın
                                    if (!autoMode) {
                                        // Şarj istasyonuna tıklanıp tıklanmadığını kontrol et
                                        var chargingStationCanvasX = parent.width * chargingStationX
                                        var chargingStationCanvasY = parent.height * chargingStationY
                                        var distanceToChargingStation = Math.sqrt(
                                            Math.pow(mouse.x - chargingStationCanvasX, 2) +
                                            Math.pow(mouse.y - chargingStationCanvasY, 2)
                                        )

                                        // Şarj istasyonuna tıklandıysa
                                        if (distanceToChargingStation < 25) {
                                            targetX = chargingStationX
                                            targetY = chargingStationY
                                            hasTarget = true
                                            targetsCleared = false

                                            // AGV hedefini şarj istasyonuna ayarla
                                            agvTargetX = chargingStationCanvasX
                                            agvTargetY = chargingStationCanvasY

                                            // Mesafe hesaplama
                                            var dx = agvCurrentX - chargingStationCanvasX
                                            var dy = agvCurrentY - chargingStationCanvasY
                                            distanceToTarget = Math.sqrt(dx*dx + dy*dy)

                                            // ETA güncelleme
                                            estimatedTime = distanceToTarget / (speed + 0.1)

                                            // Hedef konumu güncelleme
                                            destination = "Şarj İstasyonu 🔋"

                                            console.log("Şarj istasyonuna gidiliyor...")
                                        } else {
                                            // Normal hedef seçimi
                                            targetX = mouse.x / parent.width
                                            targetY = mouse.y / parent.height
                                            hasTarget = true
                                            targetsCleared = false

                                            // AGV hedefini güncelle (Canvas koordinatlarından AGV koordinatlarına çevir)
                                            agvTargetX = mouse.x
                                            agvTargetY = mouse.y

                                            // Mesafe hesaplama
                                            var dx = (targetX - 0.5) * 100
                                            var dy = (targetY - 0.5) * 100
                                            distanceToTarget = Math.sqrt(dx*dx + dy*dy)

                                            // ETA güncelleme
                                            estimatedTime = distanceToTarget / (speed + 0.1)

                                            // Hedef konumu güncelleme
                                            destination = "Manuel: (" + targetX.toFixed(2) + ", " + targetY.toFixed(2) + ")"
                                        }

                                        // AGV hareketini başlat
                                        startAGVMovement()

                                        navigationCanvas.requestPaint()
                                    } else {
                                        console.log("Auto mode aktif - Manuel hedef seçimi devre dışı")
                                    }
                                }

                                onPressed: {
                                    mousePressed = true
                                    navigationCanvas.requestPaint()
                                }

                                onReleased: {
                                    mousePressed = false
                                    navigationCanvas.requestPaint()
                                }
                            }
                        }

                        // Harita bilgileri
                        ColumnLayout {
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.topMargin: 40
                            anchors.rightMargin: 20
                            spacing: 10

                            Rectangle {
                                Layout.preferredWidth: 150
                                Layout.preferredHeight: 30
                                color: cardBg
                                radius: 5
                                border.color: borderColor
                                border.width: 1

                                // Hover efekti
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: parent.color = cardBgHover
                                    onExited: parent.color = cardBg
                                }

                                Label {
                                    anchors.centerIn: parent
                                    text: "Current: " + currentLocation
                                    color: textPrimary
                                    font.pixelSize: fontSizeSmall
                                    font.bold: true
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: 150
                                Layout.preferredHeight: 30
                                color: cardBg
                                radius: 5
                                border.color: borderColor
                                border.width: 1

                                // Hover efekti
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: parent.color = cardBgHover
                                    onExited: parent.color = cardBg
                                }

                                Label {
                                    anchors.centerIn: parent
                                    text: "Target: " + destination
                                    color: textPrimary
                                    font.pixelSize: fontSizeSmall
                                    font.bold: true
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: 150
                                Layout.preferredHeight: 30
                                color: cardBg
                                radius: 5
                                border.color: borderColor
                                border.width: 1

                                // Hover efekti
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: parent.color = cardBgHover
                                    onExited: parent.color = cardBg
                                }

                                Label {
                                    anchors.centerIn: parent
                                    text: "Distance: " + distanceToTarget.toFixed(1) + "m"
                                    color: textPrimary
                                    font.pixelSize: fontSizeSmall
                                    font.bold: true
                                }
                            }

                            // Şarj durumu göstergesi
                            Rectangle {
                                Layout.preferredWidth: 150
                                Layout.preferredHeight: 30
                                color: isCharging ? successColor : cardBg
                                radius: 5
                                border.color: borderColor
                                border.width: 1
                                visible: isCharging

                                // Hover efekti
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: parent.color = isCharging ? successColor : cardBgHover
                                    onExited: parent.color = isCharging ? successColor : cardBg
                                }

                                Label {
                                    anchors.centerIn: parent
                                    text: "Charging: " + batteryLevel.toFixed(0) + "%"
                                    color: isCharging ? "#000" : textPrimary
                                    font.pixelSize: fontSizeSmall
                                    font.bold: true
                                }
                            }
                        }
                    }
                }



                // Sistem Durumu
                GroupBox {
                    title: "SYSTEM STATUS"
                    Layout.fillWidth: true
                    label: Label {
                        text: parent.title
                        color: primaryColor
                        font.pixelSize: fontSizeMedium
                        font.bold: true
                    }

                    GridLayout {
                        anchors.fill: parent
                        columns: 2
                        rowSpacing: 10
                        columnSpacing: 15

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            color: autoMode ? successColor : cardBg
                            radius: 8
                            border.color: autoMode ? "transparent" : borderColor
                            border.width: autoMode ? 0 : 1

                            // Hover efekti
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.color = autoMode ? successColor : cardBgHover
                                onExited: parent.color = autoMode ? successColor : cardBg
                            }

                            Label {
                                anchors.centerIn: parent
                                text: autoMode ? "AUTO MODE" : "MANUAL MODE"
                                color: autoMode ? "#f2f2f2" : textPrimary
                                font.pixelSize: fontSizeSmall
                                font.bold: true
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            color: navigationActive ? successColor : cardBg
                            radius: 8
                            border.color: navigationActive ? "transparent" : borderColor
                            border.width: navigationActive ? 0 : 1

                            // Hover efekti
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.color = navigationActive ? successColor : cardBgHover
                                onExited: parent.color = navigationActive ? successColor : cardBg
                            }

                            Label {
                                anchors.centerIn: parent
                                text: navigationActive ? "NAV ACTIVE" : "NAV INACTIVE"
                                color: navigationActive ? "#000" : textPrimary
                                font.pixelSize: fontSizeSmall
                                font.bold: true
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            color: emergencyStop ? warningColor : (systemRunning ? successColor : "#4e4e4e")
                            radius: 8

                            Label {
                                anchors.centerIn: parent
                                text: emergencyStop ? "EMERGENCY STOP" : (systemRunning ? "SYSTEM RUNNING" : "SYSTEM STOPPED")
                                color: emergencyStop ? "#fff" : (systemRunning ? "#000" : "#fff")
                                font.pixelSize: fontSizeSmall
                                font.bold: true
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            color: isCharging ? successColor : (batteryLevel > 20 ? successColor : warningColor)
                            radius: 8

                            Label {
                                anchors.centerIn: parent
                                text: isCharging ? "CHARGING " + batteryLevel.toFixed(0) + "%" : (batteryLevel > 20 ? "BATTERY OK" : "LOW BATTERY")
                                color: isCharging ? "#000" : (batteryLevel > 20 ? "#000" : "#fff")
                                font.pixelSize: fontSizeSmall
                                font.bold: true
                            }
                        }
                    }
                }
            }
        }
    }

    // Animasyonlar
    Timeline {
        id: timeline
        animations: [
            TimelineAnimation {
                id: pulseAnimation
                duration: 2000
                loops: -1
                from: 0
                to: 1000
            }
        ]
    }

    // Kapatma Butonu
    Rectangle {
        id: closeButton
        width: 30
        height: 30
        radius: 15
        color: closeButtonMouseArea.containsMouse ? "#FF4757" : "#333333"
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 20
        anchors.rightMargin: 20
        z: 1000
        visible: !showIntro && !showLogin && isLoggedIn

        // Border
        border.color: "#FFD700"
        border.width: 2

        // Glow efekti
        Rectangle {
            anchors.fill: parent
            radius: 15
            color: "transparent"
            border.color: "#FFD700"
            border.width: 1
            opacity: 0.3
        }

        // X ikonu
        Label {
            anchors.centerIn: parent
            text: "✕"
            color: "#FFFFFF"
            font.pixelSize: 16
            font.bold: true
        }

        // Mouse area
        MouseArea {
            id: closeButtonMouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                Qt.quit()
            }
        }

        // Tooltip
        Rectangle {
            width: 120
            height: 30
            color: cardBg
            radius: 5
            border.color: borderColor
            border.width: 1
            anchors.left: parent.right
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            visible: closeButtonMouseArea.containsMouse

            Label {
                anchors.centerIn: parent
                text: "Uygulamayı Kapat"
                color: textPrimary
                font.pixelSize: fontSizeSmall
            }
        }
    }

    // AGV durumu göstergesi
    Rectangle {
        id: agvStatusIndicator
        width: 20
        height: 20
        radius: 10
        color: !systemRunning ? "#666" : (agvMoving ? successColor : (agvReachedTarget ? accentColor : cardBg))
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 100
        anchors.rightMargin: 20
        z: 1000
        visible: !showIntro && !showLogin && isLoggedIn

        Label {
            anchors.centerIn: parent
            text: !systemRunning ? "⏸" : (agvMoving ? "▶" : (agvReachedTarget ? "✓" : "●"))
            color: "white"
            font.pixelSize: 12
            font.bold: true
        }

        // Tooltip
        Rectangle {
            width: 150
            height: 30
            color: cardBg
            radius: 5
            border.color: borderColor
            border.width: 1
            anchors.left: parent.right
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            visible: agvStatusIndicatorMouseArea.containsMouse

            Label {
                anchors.centerIn: parent
                text: !systemRunning ? "Sistem Durdu" : (agvMoving ? "AGV Hareket Ediyor" : (agvReachedTarget ? "Hedefe Ulaştı" : "AGV Bekliyor"))
                color: textPrimary
                font.pixelSize: fontSizeSmall
            }
        }

        MouseArea {
            id: agvStatusIndicatorMouseArea
            anchors.fill: parent
            hoverEnabled: true
        }
    }
}
