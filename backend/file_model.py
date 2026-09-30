import os
from datetime import datetime
from pathlib import Path

from PySide6.QtCore import (
    QByteArray,
    QAbstractListModel,
    QModelIndex,
    Property,
    Qt,
    Signal,
    Slot,
)


class FileModel(QAbstractListModel):
    name_role = Qt.UserRole + 1
    path_role = Qt.UserRole + 2
    is_dir_role = Qt.UserRole + 3
    size_role = Qt.UserRole + 4
    modified_role = Qt.UserRole + 5

    current_path_changed = Signal()
    error_message_changed = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)

        self._items = []
        self._current_path = ""
        self._error_message = ""

        self.set_path(str(Path.home()))

    def roleNames(self):
        return {
            self.name_role: QByteArray(b"name"),
            self.path_role: QByteArray(b"path"),
            self.is_dir_role: QByteArray(b"is_dir"),
            self.size_role: QByteArray(b"size"),
            self.modified_role: QByteArray(b"modified"),
        }

    def rowCount(self, parent=QModelIndex()):
        if parent.isValid():
            return 0

        return len(self._items)

    def data(self, index, role=Qt.DisplayRole):
        if not index.isValid():
            return None

        if index.row() < 0 or index.row() >= len(self._items):
            return None

        item = self._items[index.row()]

        if role == self.name_role:
            return item["name"]

        if role == self.path_role:
            return item["path"]

        if role == self.is_dir_role:
            return item["is_dir"]

        if role == self.size_role:
            return item["size"]

        if role == self.modified_role:
            return item["modified"]

        return None

    @Property(str, notify=current_path_changed)
    def current_path(self):
        return self._current_path

    @Property(str, notify=error_message_changed)
    def error_message(self):
        return self._error_message

    def _set_error(self, message):
        if message == self._error_message:
            return

        self._error_message = message
        self.error_message_changed.emit()

    @Slot(str, result=bool)
    def set_path(self, path):
        try:
            path = os.path.abspath(os.path.expanduser(path))

            if not os.path.isdir(path):
                self._set_error(f"Not a directory: {path}")
                return False

            items = []

            with os.scandir(path) as entries:
                for entry in entries:
                    try:
                        is_dir = entry.is_dir()
                        stat = entry.stat(follow_symlinks=False)

                        items.append(
                            {
                                "name": entry.name,
                                "path": entry.path,
                                "is_dir": is_dir,
                                "size": "" if is_dir else self._format_size(stat.st_size),
                                "modified": datetime.fromtimestamp(
                                    stat.st_mtime
                                ).strftime("%Y-%m-%d %H:%M"),
                            }
                        )

                    except OSError:
                        continue

            items.sort(
                key=lambda item: (
                    not item["is_dir"],
                    item["name"].casefold(),
                )
            )

            self.beginResetModel()
            self._items = items
            self.endResetModel()

            if path != self._current_path:
                self._current_path = path
                self.current_path_changed.emit()

            self._set_error("")
            return True

        except OSError as exc:
            self._set_error(str(exc))
            return False

    @Slot(result=bool)
    def go_up(self):
        if not self._current_path:
            return False

        parent = os.path.dirname(self._current_path)

        if parent == self._current_path:
            return False

        return self.set_path(parent)

    @Slot(str, result=bool)
    def open_path(self, path):
        if not os.path.isdir(path):
            return False

        return self.set_path(path)

    @staticmethod
    def _format_size(size):
        units = ("B", "KB", "MB", "GB", "TB", "PB")
        value = float(size)

        for unit in units:
            if value < 1024.0 or unit == units[-1]:
                if unit == "B":
                    return f"{int(value)} {unit}"

                return f"{value:.1f} {unit}"

            value /= 1024.0