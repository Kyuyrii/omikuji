// push from any thread; bridge drains on a poll tick and emits a signal per item

use std::collections::VecDeque;
use std::sync::Mutex;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Level {
    Info,
    Success,
    Warning,
    Error,
}

impl Level {
    pub fn as_str(&self) -> &'static str {
        match self {
            Level::Info => "info",
            Level::Success => "success",
            Level::Warning => "warning",
            Level::Error => "error",
        }
    }
}

#[derive(Debug, Clone)]
pub struct Notification {
    pub level: Level,
    pub title: String,
    pub message: String,
}

lazy_static::lazy_static! {
    static ref QUEUE: Mutex<VecDeque<Notification>> = Mutex::new(VecDeque::new());
}

pub fn push(level: Level, title: impl Into<String>, message: impl Into<String>) {
    let Ok(mut q) = QUEUE.lock() else { return };
    q.push_back(Notification {
        level,
        title: title.into(),
        message: message.into(),
    });
    while q.len() > 50 {
        q.pop_front();
    }
}

pub fn info(title: impl Into<String>, message: impl Into<String>) {
    push(Level::Info, title, message);
}

pub fn success(title: impl Into<String>, message: impl Into<String>) {
    push(Level::Success, title, message);
}

pub fn warning(title: impl Into<String>, message: impl Into<String>) {
    push(Level::Warning, title, message);
}

pub fn error(title: impl Into<String>, message: impl Into<String>) {
    push(Level::Error, title, message);
}

pub fn take_pending() -> Vec<Notification> {
    QUEUE
        .lock()
        .map(|mut q| q.drain(..).collect())
        .unwrap_or_default()
}
