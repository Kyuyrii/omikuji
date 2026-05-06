mod bridge;
mod cli;

use cxx_qt_lib::{QGuiApplication, QQmlApplicationEngine, QUrl};
use std::ffi::CString;

// QML Window doesn't expose `icon` as assignable afaik; see app_icon.cpp shim
unsafe extern "C" {
    fn omikuji_set_window_icon(path: *const std::os::raw::c_char);
    fn omikuji_set_desktop_file_name(name: *const std::os::raw::c_char);
}

#[tokio::main]
async fn main() {
    if let Some(code) = cli::try_dispatch() {
        std::process::exit(code);
    }

    let mut app = QGuiApplication::new();

    if let Ok(name) = CString::new("omikuji") {
        unsafe { omikuji_set_desktop_file_name(name.as_ptr()) };
    }

    if let Ok(path) = CString::new(":/qt/qml/omikuji/qml/icons/app.png") {
        unsafe { omikuji_set_window_icon(path.as_ptr()) };
    }

    let mut engine = QQmlApplicationEngine::new();

    if let Some(engine) = engine.as_mut() {
        engine.load(&QUrl::from("qrc:/qt/qml/omikuji/qml/Main.qml"));
    }

    if let Some(app) = app.as_mut() {
        app.exec();
    }
}
