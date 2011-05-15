# Snapshot UI
Rack App intended to help navigating a snapshotting filesystem.
It includes a two-pane view, checking for differences between snapshots to produce 'versions' and presenting diffs of plain text files between snapshots.

Currently only works on ZFS, and starts in the user's home directory by default.

I make no positive claims as regards the quality of the code…

## Known Issues
* Copes poorly with snapshots disappearing.
* Very little in the way of sanitizing requests.

## Future Development
* Continued attempts to make the code less awful.
* Support for diffing directories and image files.
* Support for diffing files with a sensible textual representation.

## License
Copyright (C) 2010 Adam Watkins

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the [GNU General Public License](https://www.gnu.org/licenses/gpl-2.0.html)
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.