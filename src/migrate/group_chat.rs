#[rustfmt::skip]
pub(super) const GROUP_CHAT_VERSIONS: [&str; 6] = [
  "CREATE TABLE IF NOT EXISTS groups(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    height INTEGER NOT NULL,
    owner TEXT NOT NULL,
    gcd TEXT NOT NULL,
    gtype INTEGER NOT NULL,
    addr TEXT NOT NULL,
    name TEXT NOT NULL,
    bio TEXT NOT NULL,
    is_ok INTEGER NOT NULL,
    is_need_agree INTEGER NOT NULL,
    is_closed INTEGER NOT NULL,
    key TEXT NOT NULL,
    datetime INTEGER NOT NULL,
    is_remote INTEGER NOT NULL,
    is_deleted INTEGER NOT NULL);",
  "CREATE TABLE IF NOT EXISTS requests(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    fid INTEGER NOT NULL,
    rid INTEGER NOT NULL,
    gid TEXT NOT NULL,
    addr TEXT NOT NULL,
    name TEXT NOT NULL,
    remark TEXT NOT NULL,
    key TEXT NOT NULL,
    is_ok INTEGER NOT NULL,
    is_over INTEGER NOT NULL,
    datetime INTEGER NOT NULL,
    is_deleted INTEGER NOT NULL);",
  "CREATE TABLE IF NOT EXISTS members(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    fid INTEGER NOT NULL,
    mid TEXT NOT NULL,
    addr TEXT NOT NULL,
    name TEXT NOT NULL,
    is_manager INTEGER NOT NULL,
    is_block INTEGER NOT NULL,
    datetime INTEGER NOT NULL,
    is_deleted INTEGER NOT NULL);",
  "CREATE TABLE IF NOT EXISTS messages(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    height INTEGER NOT NULL,
    fid INTEGER NOT NULL,
    mid INTEGER NOT NULL,
    is_me INTEGER NOT NULL,
    m_type INTEGER NOT NULL,
    content TEXT NOT NULL,
    is_delivery INTEGER NOT NULL,
    datetime INTEGER NOT NULL,
    is_deleted INTEGER NOT NULL);",
 "CREATE TABLE IF NOT EXISTS consensus(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    fid INTEGER NOT NULL,
    height INTEGER NOT NULL,
    ctype INTEGER NOT NULL,
    cid INTEGER NOT NULL);",
 "CREATE TABLE IF NOT EXISTS providers(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    name TEXT NOT NULL,
    addr TEXT NOT NULL,
    kinds INTEGER NOT NULL,
    remain INTEGER NOT NULL,
    is_ok INTEGER NOT NULL);",
];
