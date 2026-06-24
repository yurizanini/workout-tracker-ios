import Foundation
import CloudKit

@MainActor
class CloudKitManager: ObservableObject {
    static let shared = CloudKitManager()

    private var container: CKContainer?
    private var privateDB: CKDatabase?

    // Record types
    private let scheduleRecordType = "Schedule"
    private let workoutLogRecordType = "WorkoutLog"

    // Fixed record ID for the single schedule record
    private let scheduleRecordID = CKRecord.ID(recordName: "user_schedule")

    // Set to true when you have a paid Apple Developer account and have
    // added the iCloud capability + CloudKit container in Xcode.
    private let cloudKitEnabled = false

    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncError: String?

    private init() {}

    func checkAndSetup() async -> Bool {
        guard cloudKitEnabled else { return false }
        if container != nil { return true }

        let ck = CKContainer(identifier: "iCloud.com.yurizanini.WorkoutTracker")
        do {
            let status = try await ck.accountStatus()
            guard status == .available else { return false }
        } catch {
            print("CloudKit: account status check failed – \(error)")
            return false
        }

        self.container = ck
        self.privateDB = ck.privateCloudDatabase
        return true
    }

    // MARK: - Account Status

    func checkAccountStatus() async -> Bool {
        return await checkAndSetup()
    }

    // MARK: - Schedule Sync

    func saveSchedule(_ schedule: [WorkoutDay]) async {
        guard let privateDB = privateDB else { return }
        let record = CKRecord(recordType: scheduleRecordType, recordID: scheduleRecordID)
        let rawValues = schedule.map { $0.rawValue }
        record["days"] = rawValues as CKRecordValue

        do {
            try await privateDB.modifyRecords(saving: [record], deleting: [], savePolicy: .changedKeys)
        } catch {
            print("CloudKit save schedule error: \(error)")
            syncError = "Failed to sync schedule"
        }
    }

    func fetchSchedule() async -> [WorkoutDay]? {
        guard let privateDB = privateDB else { return nil }
        do {
            let record = try await privateDB.record(for: scheduleRecordID)
            guard let rawDays = record["days"] as? [String] else { return nil }
            return rawDays.compactMap { WorkoutDay(rawValue: $0) }
        } catch {
            print("CloudKit fetch schedule: \(error)")
            return nil
        }
    }

    // MARK: - Workout Logs Sync

    func saveWorkoutLog(_ entry: WorkoutLogEntry, weekKey: String) async {
        guard let privateDB = privateDB else { return }
        let recordID = CKRecord.ID(recordName: "log_\(entry.id.uuidString)")
        let record = CKRecord(recordType: workoutLogRecordType, recordID: recordID)

        record["entryID"] = entry.id.uuidString as CKRecordValue
        record["workoutName"] = entry.workoutName as CKRecordValue
        record["date"] = entry.date as CKRecordValue
        record["weekKey"] = weekKey as CKRecordValue

        if let data = try? JSONEncoder().encode(entry.exerciseLogs),
           let jsonString = String(data: data, encoding: .utf8) {
            record["exerciseLogsJSON"] = jsonString as CKRecordValue
        }

        do {
            try await privateDB.modifyRecords(saving: [record], deleting: [], savePolicy: .changedKeys)
        } catch {
            print("CloudKit save log error: \(error)")
            syncError = "Failed to sync workout log"
        }
    }

    func fetchAllLogs() async -> [String: [WorkoutLogEntry]]? {
        guard let privateDB = privateDB else { return nil }
        let query = CKQuery(recordType: workoutLogRecordType, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        do {
            var allRecords: [CKRecord] = []
            var cursor: CKQueryOperation.Cursor? = nil

            let (results, nextCursor) = try await privateDB.records(matching: query, resultsLimit: 200)
            allRecords.append(contentsOf: results.compactMap { try? $0.1.get() })
            cursor = nextCursor

            while let activeCursor = cursor {
                let (moreResults, moreCursor) = try await privateDB.records(continuingMatchFrom: activeCursor, resultsLimit: 200)
                allRecords.append(contentsOf: moreResults.compactMap { try? $0.1.get() })
                cursor = moreCursor
            }

            var logs: [String: [WorkoutLogEntry]] = [:]

            for record in allRecords {
                guard let entryIDString = record["entryID"] as? String,
                      let entryID = UUID(uuidString: entryIDString),
                      let workoutName = record["workoutName"] as? String,
                      let date = record["date"] as? String,
                      let weekKey = record["weekKey"] as? String else {
                    continue
                }

                var exerciseLogs: [ExerciseLog] = []
                if let jsonString = record["exerciseLogsJSON"] as? String,
                   let data = jsonString.data(using: .utf8) {
                    exerciseLogs = (try? JSONDecoder().decode([ExerciseLog].self, from: data)) ?? []
                }

                let entry = WorkoutLogEntry(id: entryID, workoutName: workoutName, date: date, exerciseLogs: exerciseLogs)
                logs[weekKey, default: []].append(entry)
            }

            for key in logs.keys {
                logs[key]?.sort { $0.date < $1.date }
            }

            return logs
        } catch {
            print("CloudKit fetch logs error: \(error)")
            syncError = "Failed to fetch workout history"
            return nil
        }
    }

    func deleteWorkoutLog(entryID: UUID) async {
        guard let privateDB = privateDB else { return }
        let recordID = CKRecord.ID(recordName: "log_\(entryID.uuidString)")
        do {
            try await privateDB.deleteRecord(withID: recordID)
        } catch {
            print("CloudKit delete log error: \(error)")
        }
    }

    // MARK: - Full Sync

    func performFullSync(localSchedule: [WorkoutDay], localLogs: [String: [WorkoutLogEntry]]) async -> (schedule: [WorkoutDay]?, logs: [String: [WorkoutLogEntry]]?) {
        guard await checkAndSetup() else { return (nil, nil) }

        isSyncing = true
        syncError = nil

        defer {
            isSyncing = false
            lastSyncDate = Date()
        }

        let remoteSchedule = await fetchSchedule()
        let remoteLogs = await fetchAllLogs()

        if remoteSchedule == nil {
            await saveSchedule(localSchedule)
        }

        if let remoteLogs = remoteLogs {
            for (weekKey, entries) in localLogs {
                for entry in entries {
                    let remoteEntries = remoteLogs[weekKey] ?? []
                    if !remoteEntries.contains(where: { $0.id == entry.id }) {
                        await saveWorkoutLog(entry, weekKey: weekKey)
                    }
                }
            }
        } else {
            for (weekKey, entries) in localLogs {
                for entry in entries {
                    await saveWorkoutLog(entry, weekKey: weekKey)
                }
            }
        }

        let finalSchedule = remoteSchedule ?? localSchedule
        var finalLogs = localLogs
        if let remoteLogs = remoteLogs {
            for (weekKey, entries) in remoteLogs {
                var merged = finalLogs[weekKey] ?? []
                for entry in entries {
                    if !merged.contains(where: { $0.id == entry.id }) {
                        merged.append(entry)
                    }
                }
                merged.sort { $0.date < $1.date }
                finalLogs[weekKey] = merged
            }
        }

        return (finalSchedule, finalLogs)
    }
}
