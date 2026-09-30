# nuitka-project: --enable-plugin=pyside6
# nuitka-project: --include-qt-plugins=qml
# nuitka-project: --include-data-dir={MAIN_DIRECTORY}/qml=qml
# nuitka-project-if: {OS} == "Windows":
#    nuitka-project: --windows-console-mode=disable

import sys
from pathlib import Path

from PySide6.QtCore import QCoreApplication
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from backend.file_model import FileModel


def main():
    QCoreApplication.setApplicationName("explorer")

    app = QGuiApplication(sys.argv)

    engine = QQmlApplicationEngine()

    file_model = FileModel()
    engine.rootContext().setContextProperty("file_model", file_model)

    qml_path = Path(__file__).resolve().parent / "qml" / "main.qml"
    engine.load(qml_path)

    if not engine.rootObjects():
        return 1

    return app.exec()


if __name__ == "__main__":
    raise SystemExit(main())