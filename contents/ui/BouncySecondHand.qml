/*
 * Tick-and-bounce second hand with numerically continuous rotation.
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import QtGraphicalEffects 1.0

PlasmaCore.SvgItem {
    id: handRoot

    property alias rotation: handRotation.angle
    property double svgScale
    property double horizontalRotationOffset: 0
    property double verticalRotationOffset: 0
    property string rotationCenterHintId

    readonly property double horizontalRotationCenter: {
        if (svg.hasElement(rotationCenterHintId)) {
            var hintedCenterRect = svg.elementRect(rotationCenterHintId),
                handRect = svg.elementRect(elementId),
                hintedX = hintedCenterRect.x - handRect.x + hintedCenterRect.width / 2;
            return Math.round(hintedX * svgScale) + Math.round(hintedX * svgScale) % 2;
        }
        return width / 2;
    }
    readonly property double verticalRotationCenter: {
        if (svg.hasElement(rotationCenterHintId)) {
            var hintedCenterRect = svg.elementRect(rotationCenterHintId),
                handRect = svg.elementRect(elementId),
                hintedY = hintedCenterRect.y - handRect.y + hintedCenterRect.height / 2;
            return Math.round(hintedY * svgScale) + width % 2;
        }
        return width / 2;
    }

    width: Math.round(naturalSize.width * svgScale) + Math.round(naturalSize.width * svgScale) % 2
    height: Math.round(naturalSize.height * svgScale) + width % 2
    anchors {
        top: clock.verticalCenter
        topMargin: -verticalRotationCenter + verticalRotationOffset
        left: clock.horizontalCenter
        leftMargin: -horizontalRotationCenter + horizontalRotationOffset
    }

    svg: PlasmaCore.Svg {
        imagePath: plasmoid.file("images", "clock.svg")
        multipleImages: true
    }

    layer.enabled: true
    layer.effect: DropShadow {
        transparentBorder: true
        color: Qt.rgba(1, 1, 1, 0.4)
        radius: 8
        samples: 16
        horizontalOffset: 0
        verticalOffset: 0
        visible: !handRoot.elementId.includes("Shadow")
    }

    transform: Rotation {
        id: handRotation
        angle: 0
        origin {
            x: handRoot.horizontalRotationCenter
            y: handRoot.verticalRotationCenter
        }

        Behavior on angle {
            RotationAnimation {
                duration: 400
                direction: RotationAnimation.Numerical
                easing.type: Easing.OutBack
                easing.overshoot: 0.3
            }
        }
    }
}
