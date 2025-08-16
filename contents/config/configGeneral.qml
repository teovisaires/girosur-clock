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


import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

Item {
    id: root
    width: 420
    implicitHeight: column.implicitHeight

    ColumnLayout {
        id: column
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        // --- Mostrar/ocultar fondo ---
        RowLayout {
            spacing: 8
            PlasmaComponents.Label {
                text: i18n("Mostrar fondo")
                Layout.alignment: Qt.AlignVCenter
            }
            Switch {
                id: showBgSwitch
                checked: plasmoid.configuration.showBackground === undefined ? true : plasmoid.configuration.showBackground
                onToggled: plasmoid.configuration.showBackground = checked
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // --- Selección de archivo de fondo ---
        ColumnLayout {
            spacing: 4

            PlasmaComponents.Label {
                text: i18n("Archivo de fondo (en contents/images)")
            }

            ComboBox {
                id: bgCombo
                // Lista básica; podés ampliar luego agregando más nombres
                // Si agregás más fondos, sumalos acá: ["fondo01.svg","fondo02.svg",...]
                model: [ "fondo01.svg" ]

                // Selecciona el actual si existe, sino por defecto "fondo01.svg"
                Component.onCompleted: {
                    if (!plasmoid.configuration.backgroundSource) {
                        plasmoid.configuration.backgroundSource = "fondo01.svg"
                    }
                    const current = plasmoid.configuration.backgroundSource
                    const idx = model.indexOf(current)
                    currentIndex = idx >= 0 ? idx : model.indexOf("fondo01.svg")
                }

                onActivated: (index) => {
                    plasmoid.configuration.backgroundSource = model[index]
                }

                Layout.fillWidth: true
            }
        }

        // --- Opacidad ---
        ColumnLayout {
            spacing: 4

            PlasmaComponents.Label {
                text: i18n("Opacidad del fondo")
            }

            Slider {
                id: opacitySlider
                from: 0.0
                to: 1.0
                stepSize: 0.05
                live: true
                value: plasmoid.configuration.backgroundOpacity === undefined ? 0.85 : plasmoid.configuration.backgroundOpacity
                onValueChanged: plasmoid.configuration.backgroundOpacity = value
                Layout.fillWidth: true
            }
        }

        // separador visual (opcional)
        Rectangle {
            height: 1
            color: Qt.rgba(1,1,1,0.12)
            Layout.fillWidth: true
        }

        // Ayuda breve
        PlasmaComponents.Label {
            text: i18n("Colocá tus SVG en contents/images/. Si agregás más archivos, sumalos al ComboBox.")
            wrapMode: Text.WordWrap
            opacity: 0.7
            Layout.fillWidth: true
        }

        // expansor de layout
        Item { Layout.fillHeight: true }
    }
}
