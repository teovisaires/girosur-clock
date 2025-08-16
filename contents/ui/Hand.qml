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

import org.kde.plasma.core 2.0 as PlasmaCore

PlasmaCore.SvgItem {
    id: handRoot

    property alias rotation: rotation.angle
    property double svgScale
    property double horizontalRotationOffset: 0
    property double verticalRotationOffset: 0
    property string rotationCenterHintId
    readonly property double horizontalRotationCenter: {
        if (svg.hasElement(rotationCenterHintId)) {
            var hintedCenterRect = svg.elementRect(rotationCenterHintId),
                handRect = svg.elementRect(elementId),
                hintedX = hintedCenterRect.x - handRect.x + hintedCenterRect.width/2;
            return Math.round(hintedX * svgScale) + Math.round(hintedX * svgScale) % 2;
        }
        return width/2;
    }
    readonly property double verticalRotationCenter: {
        if (svg.hasElement(rotationCenterHintId)) {
            var hintedCenterRect = svg.elementRect(rotationCenterHintId),
                handRect = svg.elementRect(elementId),
                hintedY = hintedCenterRect.y - handRect.y + hintedCenterRect.height/2;
            return Math.round(hintedY * svgScale) + width % 2;
        }
        return width/2;
    }

    width: Math.round(naturalSize.width * svgScale) + Math.round(naturalSize.width * svgScale) % 2
    height: Math.round(naturalSize.height * svgScale) + width % 2
    anchors {
        top: clock.verticalCenter
        topMargin: -verticalRotationCenter + verticalRotationOffset
        left: clock.horizontalCenter
        leftMargin: -horizontalRotationCenter + horizontalRotationOffset
    }

    svg: clockSvg
    transform: Rotation {
        id: rotation
        angle: 0
        origin {
            x: handRoot.horizontalRotationCenter
            y: handRoot.verticalRotationCenter
        }
        Behavior on angle {
            RotationAnimation {
                id: anim
                duration: 200
                direction: RotationAnimation.AntiClockwise
                easing.type: Easing.OutElastic
                easing.overshoot: 0.5
            }
        }
    }
}
