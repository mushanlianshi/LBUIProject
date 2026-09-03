//
//  ChatDatabase.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/3.
//

import Foundation
import FMDB

/// FMDB 数据库管家：单例、串行队列（FMDatabaseQueue 官方线程安全姿势）、建库建表
final class ChatDatabase {

    static let shared = ChatDatabase()

    let queue: FMDatabaseQueue

    private init() {
        let dbPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            .first!
            .appending("/chat.sqlite")
        debugPrint("LBLog chat db path \(dbPath)")

        guard let queue = FMDatabaseQueue(path: dbPath) else {
            fatalError("chat.sqlite 打开失败：\(dbPath)")
        }
        self.queue = queue
        setupSchema()
    }

    // MARK: - 建表
    private func setupSchema() {
        queue.inDatabase { db in
            /// FMDB/SQLite 默认关外键，每次连接都要开（删会话级联删消息依赖它）
            db.executeUpdate("PRAGMA foreign_keys = ON", withArgumentsIn: [])

            let createSession = """
            CREATE TABLE IF NOT EXISTS chat_session (
                id          TEXT PRIMARY KEY,
                title       TEXT NOT NULL DEFAULT '',
                created_at  REAL NOT NULL,
                updated_at  REAL NOT NULL
            );
            """
            db.executeUpdate(createSession, withArgumentsIn: [])

            let createMessage = """
            CREATE TABLE IF NOT EXISTS chat_message (
                id              TEXT PRIMARY KEY,
                session_id      TEXT NOT NULL,
                role            INTEGER NOT NULL,
                content         TEXT NOT NULL,
                rendered_height REAL NOT NULL DEFAULT 0,
                created_at      REAL NOT NULL,
                FOREIGN KEY(session_id) REFERENCES chat_session(id) ON DELETE CASCADE
            );
            CREATE INDEX IF NOT EXISTS idx_msg_session ON chat_message(session_id, created_at);
            """
            db.executeStatements(createMessage)
        }
    }
}
