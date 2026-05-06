// Small C++ shim for app-icon + desktop-file-name setup.
//
// On X11, QGuiApplication::setWindowIcon sets the _NET_WM_ICON atoms
// and taskbars read that directly. On Wayland, the compositor
// (Hyprland / KWin / GNOME Shell) ignores per-window icons and
// instead resolves the app_id → .desktop file → Icon= entry. So we
// also set the desktop filename here; the compositor uses that to
// derive app_id for lookup.
//
// Neither QML's Window nor ApplicationWindow exposes an assignable
// `icon` property in the Qt version we're on, so calling into
// QGuiApplication from C++ is the only working path.

#include <QtCore/QString>
#include <QtGui/QGuiApplication>
#include <QtGui/QIcon>

extern "C" void omikuji_set_window_icon(const char* path) {
    if (!path) return;
    QGuiApplication::setWindowIcon(QIcon(QString::fromUtf8(path)));
}

// Tells the Wayland compositor the basename (no .desktop suffix) of
// the .desktop file describing this app. The compositor uses this to
// match the surface against an installed desktop entry and renders
// its Icon= value in the taskbar / alt-tab / overview.
extern "C" void omikuji_set_desktop_file_name(const char* name) {
    if (!name) return;
    QGuiApplication::setDesktopFileName(QString::fromUtf8(name));
}