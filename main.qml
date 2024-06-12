import QtQuick 2.15
import QtQuick.Controls 2.15
import QtLocation 5.15
import QtPositioning 5.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    visible: true
    width: 800
    height: 600

    // Menggunakan ColumnLayout untuk mengatur tata letak utama
    ColumnLayout {
        anchors.fill: parent

        // Layout untuk TextField dan Button pencarian lokasi
        Column {
            spacing: 10
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true

            TextField {
                id: searchField
                placeholderText: "Enter location"
                width: parent.width / 2
                anchors.horizontalCenter: parent.horizontalCenter
                onAccepted: {
                    // Implementasikan logika pencarian lokasi
                    // Gunakan API geocoding untuk mendapatkan koordinat dari alamat
                }
            }

            Button {
                text: "Search"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    // Implementasikan logika pencarian lokasi
                    // Gunakan API geocoding untuk mendapatkan koordinat dari alamat
                }
            }
        }

        // Layout untuk slider zoom dan panning
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 40  // Jarak antara slider dan label

            // Slider vertikal untuk zoom in dan zoom out
            ColumnLayout {
                Layout.alignment: Qt.AlignVCenter

                Slider {
                    id: zoomSlider
                    from: 1
                    to: 20
                    stepSize: 1
                    orientation: Qt.Horizontal
                    value: map.zoomLevel
                    height: parent.height / 4  // Tinggi slider menjadi seperempat dari tinggi aplikasi
                    width: 40  // Lebar slider lebih kecil
                    onValueChanged: {
                        map.zoomLevel = value
                    }
                }

                // Label untuk menampilkan level zoom
                Label {
                    text: "Zoom Level: " + zoomSlider.value
                    rotation: 0
                }
            }

            // Slider horizontal untuk panning longitude
            ColumnLayout {
                Layout.alignment: Qt.AlignVCenter

                Slider {
                    id: horizontalPanSlider
                    from: 95  // Minimum nilai untuk longitude Indonesia
                    to: 141    // Maksimum nilai untuk longitude Indonesia
                    value: map.center.longitude  // Nilai awal adalah longitude pusat peta
                    orientation: Qt.Horizontal
                    width: parent.width / 2  // Set lebar slider menjadi setengah dari lebar aplikasi
                    height: 40  // Tinggi slider lebih kecil
                    onValueChanged: {
                        map.center = QtPositioning.coordinate(map.center.latitude, value)
                    }
                }

                // Label untuk menampilkan nilai panning horizontal
                Label {
                    text: "Longitude: " + horizontalPanSlider.value
                    rotation: 0
                }
            }

            // Slider vertikal untuk panning latitude
            ColumnLayout {
                Layout.alignment: Qt.AlignVCenter

                Slider {
                    id: verticalPanSlider
                    from: -10  // Minimum nilai untuk latitude Indonesia
                    to: 6    // Maksimum nilai untuk latitude Indonesia
                    value: map.center.latitude  // Nilai awal adalah latitude pusat peta
                    orientation: Qt.Horizontal
                    height: parent.height / 5  // Set tinggi slider menjadi seperempat dari tinggi aplikasi
                    width: 40  // Lebar slider lebih kecil
                    onValueChanged: {
                        map.center = QtPositioning.coordinate(value, map.center.longitude)
                    }
                }

                // Label untuk menampilkan nilai panning vertikal
                Label {
                    text: "Latitude: " + verticalPanSlider.value
                    rotation: 0
                }
            }

            // Label untuk menampilkan nilai aktual dari latitude dan longitude
            ColumnLayout {
                Layout.alignment: Qt.AlignVCenter

                Label {
                    text: "Latitude: " + verticalPanSlider.value.toFixed(6)  // Menampilkan hingga 6 angka di belakang koma
                    rotation: 0
                }

                Label {
                    text: "Longitude: " + horizontalPanSlider.value.toFixed(6)  // Menampilkan hingga 6 angka di belakang koma
                    rotation: 0
                }
            }
        }

        // Widget untuk tampilan peta
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Map {
                id: map
                anchors.fill: parent
                plugin: Plugin {
                    name: "osm"  // Menggunakan OpenStreetMap
                }
                center: QtPositioning.coordinate(-6.737246, 108.550659)  // Koordinat awal peta
                zoomLevel: 14
                property var startCentroid

                PinchHandler {
                    id: pinch
                    target: null
                    onActiveChanged: if (active) {
                        map.startCentroid = map.toCoordinate(pinch.centroid.position, false)
                    }
                    onScaleChanged: (delta) => {
                        map.zoomLevel += Math.log2(delta)
                        map.alignCoordinateToPoint(map.startCentroid, pinch.centroid.position)
                    }
                    onRotationChanged: (delta) => {
                        map.bearing -= delta
                        map.alignCoordinateToPoint(map.startCentroid, pinch.centroid.position)
                    }
                    grabPermissions: PointerHandler.TakeOverForbidden
                }

                WheelHandler {
                    id: wheel
                    acceptedDevices: Qt.platform.pluginName === "cocoa" || Qt.platform.pluginName === "wayland"
                                     ? PointerDevice.Mouse | PointerDevice.TouchPad
                                     : PointerDevice.Mouse
                    rotationScale: 1/120
                    property: "zoomLevel"
                }

                DragHandler {
                    id: drag
                    target: null
                    onTranslationChanged: (delta) => map.pan(-delta.x, -delta.y)
                }

                MouseArea {
                    anchors.fill: parent
                    onDoubleClicked: {
                        // Ubah pusat peta menjadi lokasi klik dan perbesar (zoom in)
                        map.center = map.toCoordinate(Qt.point(mouse.x, mouse.y));
                        map.zoomLevel += 1;
                    }
                }

                Shortcut {
                    enabled: map.zoomLevel < map.maximumZoomLevel
                    sequence: StandardKey.ZoomIn
                    onActivated: map.zoomLevel = Math.round(map.zoomLevel + 1)
                }

                Shortcut {
                    enabled: map.zoomLevel > map.minimumZoomLevel
                    sequence: StandardKey.ZoomOut
                    onActivated: map.zoomLevel = Math.round(map.zoomLevel - 1)
                }
            }

            PositionSource {
                id: positionSource
                active: true
                onPositionChanged: {
                    map.center = positionSource.position.coordinate
                }
            }
        }

    }
}
