/*
 *   GiroSur Clock – counterclockwise version
 *   Reloj “GiroSur”: rotación antihoraria y numeración invertida
 *   Copyright (C) 2025 Teodoro Visaires <teovisaires@gmx.com>
 *   Based on KDE Plasma Analog Clock by:
 *   Viranch Mehta, Marco Martin, David Edmundson, Michail Vourlakos
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 2 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.calendar 2.0 as PlasmaCalendar
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

import "calendar" as LocalCalendar
import "."

Item {
    id: girosurclock
    width: units.gridUnit * 15
    height: units.gridUnit * 15

    property int hours
    property int minutes
    property int seconds
    property bool showSecondsHand: plasmoid.configuration.showSecondHand
    property bool showTimezone: plasmoid.configuration.showTimezoneString
    property int tzOffset

    Plasmoid.backgroundHints: "NoBackground"
    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation
    Plasmoid.toolTipMainText: Qt.formatDate(dataSource.data["Local"]["DateTime"], "dddd")
    Plasmoid.toolTipSubText: Qt.formatDate(
        dataSource.data["Local"]["DateTime"],
        Qt.locale().dateFormat(Locale.LongFormat).replace(/(^dddd.?\s)|(,?\sdddd$)/, "")
    )

    PlasmaCore.DataSource {
        id: dataSource
        engine: "time"
        connectedSources: "Local"
        interval: showSecondsHand ? 1000 : 30000
        onDataChanged: {
            var date = new Date(data["Local"]["DateTime"])
            hours = date.getHours()
            minutes = date.getMinutes()
            seconds = date.getSeconds()
        }
        Component.onCompleted: onDataChanged()
    }

    function dateTimeChanged() {
        var currentTZOffset = dataSource.data["Local"]["Offset"] / 60
        if (currentTZOffset !== tzOffset) {
            tzOffset = currentTZOffset
            Date.timeZoneUpdated()
        }
    }

    Component.onCompleted: {
        tzOffset = new Date().getTimezoneOffset()
        dataSource.onDataChanged.connect(dateTimeChanged)
    }

    Plasmoid.compactRepresentation: Item {
        id: representation
        Layout.minimumWidth: latteBridge ? -1 : (plasmoid.formFactor !== PlasmaCore.Types.Vertical ? representation.height : units.gridUnit)
        Layout.minimumHeight: latteBridge ? -1 : (plasmoid.formFactor === PlasmaCore.Types.Vertical ? representation.width : units.gridUnit)

        property QtObject latteBridge: null
        onLatteBridgeChanged: if (latteBridge) latteBridge.actions.setProperty(plasmoid.id, "latteSideColoringEnabled", false)

        MouseArea { anchors.fill: parent; onClicked: plasmoid.expanded = !plasmoid.expanded }

        Item {
            id: contentArea
            anchors.fill: parent
            anchors.topMargin: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? plasmoid.configuration.thicknessPadding : 0
            anchors.bottomMargin: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? plasmoid.configuration.thicknessPadding : 0
            anchors.leftMargin: plasmoid.formFactor === PlasmaCore.Types.Vertical ? plasmoid.configuration.thicknessPadding : 0
            anchors.rightMargin: plasmoid.formFactor === PlasmaCore.Types.Vertical ? plasmoid.configuration.thicknessPadding : 0

            /* ================= FONDO ALINEADO AL CÍRCULO ================= */
            Item {
                id: bgWrap
                anchors.centerIn: clock
                width: clock.circleSize
                height: clock.circleSize
                visible: plasmoid.configuration.showBackground === undefined ? true : plasmoid.configuration.showBackground
                opacity: plasmoid.configuration.backgroundOpacity === undefined ? 0.85 : plasmoid.configuration.backgroundOpacity
                z: -1000

                Image {
                    anchors.fill: parent
                    source: plasmoid.file("images", plasmoid.configuration.backgroundSource || "fondo01.svg")
                    fillMode: Image.PreserveAspectFit   // usar PreserveAspectCrop si querés que “llene” sin bandas
                    antialiasing: true
                    smooth: true
                }
            }
            /* ============================================================= */

            PlasmaCore.Svg {
                id: clockSvg
                imagePath: "widgets/clock"
                function estimateHorizontalHandShadowOffset() {
                    var id = "hint-hands-shadow-offset-to-west"
                    if (hasElement(id)) return -elementSize(id).width
                    id = "hint-hands-shadows-offset-to-east"
                    if (hasElement(id)) return elementSize(id).width
                    return 0
                }
                function estimateVerticalHandShadowOffset() {
                    var id = "hint-hands-shadow-offset-to-north"
                    if (hasElement(id)) return -elementSize(id).height
                    id = "hint-hands-shadow-offset-to-south"
                    if (hasElement(id)) return elementSize(id).height
                    return 0
                }
                property double naturalHorizontalHandShadowOffset: estimateHorizontalHandShadowOffset()
                property double naturalVerticalHandShadowOffset: estimateVerticalHandShadowOffset()
                onRepaintNeeded: {
                    naturalHorizontalHandShadowOffset = estimateHorizontalHandShadowOffset()
                    naturalVerticalHandShadowOffset = estimateVerticalHandShadowOffset()
                }
            }

            /* CONTENEDOR DEL RELOJ */
            Item {
                id: clock
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: showTimezone ? timezoneBg.top : parent.bottom

                readonly property real circleSize: Math.min(width, height)

                readonly property real svgBase: clockSvg.hasElement("ClockFace")
                                               ? clockSvg.elementSize("ClockFace").width
                                               : 256
                readonly property real svgScale: circleSize / svgBase

                readonly property int horizontalShadowOffset: Math.round(clockSvg.naturalHorizontalHandShadowOffset * svgScale) + Math.round(clockSvg.naturalHorizontalHandShadowOffset * svgScale) % 2
                readonly property int verticalShadowOffset: Math.round(clockSvg.naturalVerticalHandShadowOffset * svgScale) + Math.round(clockSvg.naturalVerticalHandShadowOffset * svgScale) % 2

                /* ── Aguja de horas y sombra (antihorario) ── */
                Hand {
                    elementId: "HourHandShadow"
                    rotationCenterHintId: "hint-hourhandshadow-rotation-center-offset"
                    horizontalRotationOffset: clock.horizontalShadowOffset
                    verticalRotationOffset: clock.verticalShadowOffset
                    rotation: 180 - (hours * 30 + minutes / 2)
                    svgScale: clock.svgScale
                }
                Hand {
                    elementId: "HourHand"
                    rotationCenterHintId: "hint-hourhand-rotation-center-offset"
                    rotation: 180 - (hours * 30 + minutes / 2)
                    svgScale: clock.svgScale
                }

                /* ── Aguja de minutos y sombra (antihorario) ── */
                Hand {
                    elementId: "MinuteHandShadow"
                    rotationCenterHintId: "hint-minutehandshadow-rotation-center-offset"
                    horizontalRotationOffset: clock.horizontalShadowOffset
                    verticalRotationOffset: clock.verticalShadowOffset
                    rotation: 180 - minutes * 6
                    svgScale: clock.svgScale
                }
                Hand {
                    elementId: "MinuteHand"
                    rotationCenterHintId: "hint-minutehand-rotation-center-offset"
                    rotation: 180 - minutes * 6
                    svgScale: clock.svgScale
                }

                /* ── Aguja de segundos y sombra (antihorario) ── */
                Hand {
                    elementId: "SecondHandShadow"
                    rotationCenterHintId: "hint-secondhandshadow-rotation-center-offset"
                    horizontalRotationOffset: clock.horizontalShadowOffset
                    verticalRotationOffset: clock.verticalShadowOffset
                    rotation: 180 - seconds * 6
                    visible: showSecondsHand
                    svgScale: clock.svgScale
                }
                Hand {
                    elementId: "SecondHand"
                    rotationCenterHintId: "hint-secondhand-rotation-center-offset"
                    rotation: 180 - seconds * 6
                    visible: showSecondsHand
                    svgScale: clock.svgScale
                }

                /* Centro y “Glass” (opcional del tema) */
                PlasmaCore.SvgItem {
                    id: center
                    anchors.centerIn: clock
                    width: naturalSize.width * clock.svgScale
                    height: naturalSize.height * clock.svgScale
                    svg: clockSvg
                    elementId: "HandCenterScrew"
                    z: 1000
                    visible: clockSvg.hasElement("HandCenterScrew")
                }
                PlasmaCore.SvgItem {
                    anchors.centerIn: clock
                    width: clock.circleSize
                    height: clock.circleSize
                    svg: clockSvg
                    elementId: "Glass"
                    visible: clockSvg.hasElement("Glass")
                }
            }

            PlasmaCore.FrameSvgItem {
                id: timezoneBg
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10
                imagePath: "widgets/background"
                width: childrenRect.width + margins.left + margins.right
                height: childrenRect.height + margins.top + margins.bottom
                visible: showTimezone

                PlasmaComponents.Label {
                    id: timezoneText
                    x: timezoneBg.margins.left
                    y: timezoneBg.margins.top
                    text: dataSource.data["Local"]["Timezone"]
                }
            }
        }
    }

    Plasmoid.fullRepresentation: LocalCalendar.MonthView {
        Layout.minimumWidth: units.gridUnit * 20
        Layout.minimumHeight: units.gridUnit * 20
        today: dataSource.data["Local"]["DateTime"]
        borderOpacity: plasmoid.configuration.drawCalendarLines ? 0.4 : 0
        circleStyle: plasmoid.configuration.circleStyle
    }
}
