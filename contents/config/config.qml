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

import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
         name: i18n("Appearance")
         icon: "preferences-desktop-color"
         source: "configGeneral.qml"
    }
}
