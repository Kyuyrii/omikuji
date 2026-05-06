
use std::collections::{HashMap, HashSet, VecDeque};
use std::sync::Mutex;

// 2 MiB is plenty for default verbosity; WINEDEBUG=+all will just rotate older lines out
const MAX_BYTES_PER_GAME: usize = 2 * 1024 * 1024;

#[derive(Default)]
struct Buffer {
    lines: VecDeque<String>,
    bytes: usize,
}

impl Buffer {
    fn push(&mut self, line: String) {
        self.bytes += line.len() + 1;
        self.lines.push_back(line);
        while self.bytes > MAX_BYTES_PER_GAME {
            match self.lines.pop_front() {
                Some(dropped) => self.bytes = self.bytes.saturating_sub(dropped.len() + 1),
                None => break,
            }
        }
    }

    fn snapshot(&self) -> String {
        let mut out = String::with_capacity(self.bytes);
        for line in &self.lines {
            out.push_str(line);
            out.push('\n');
        }
        out
    }
}

static BUFFERS: Mutex<Option<HashMap<String, Buffer>>> = Mutex::new(None);
static DIRTY: Mutex<Option<HashSet<String>>> = Mutex::new(None);

pub fn append_line(game_id: &str, line: String) {
    {
        let mut guard = BUFFERS.lock().unwrap();
        let map = guard.get_or_insert_with(HashMap::new);
        map.entry(game_id.to_string()).or_default().push(line);
    }
    let mut d = DIRTY.lock().unwrap();
    d.get_or_insert_with(HashSet::new).insert(game_id.to_string());
}

pub fn get_log(game_id: &str) -> String {
    let guard = BUFFERS.lock().unwrap();
    guard
        .as_ref()
        .and_then(|m| m.get(game_id))
        .map(|b| b.snapshot())
        .unwrap_or_default()
}

pub fn clear_log(game_id: &str) {
    let mut guard = BUFFERS.lock().unwrap();
    if let Some(map) = guard.as_mut()
        && let Some(buf) = map.get_mut(game_id) {
            buf.lines.clear();
            buf.bytes = 0;
        }
}

pub fn reset_log(game_id: &str) {
    let mut guard = BUFFERS.lock().unwrap();
    if let Some(map) = guard.as_mut() {
        map.remove(game_id);
    }
    let mut d = DIRTY.lock().unwrap();
    if let Some(set) = d.as_mut() {
        set.insert(game_id.to_string());
    }
}

pub fn drain_dirty() -> Vec<String> {
    let mut d = DIRTY.lock().unwrap();
    d.take()
        .map(|set| set.into_iter().collect())
        .unwrap_or_default()
}
