import Foundation

internal class FileWriter {
    private let path: String;
    private let fileSizeLimitBytes: Int
    private let rollingInterval: RollingInteval
    private let fileQueue = DispatchQueue.init(label: "FileWriter", qos: .utility)
    
    private var filePath: URL = URL(fileURLWithPath: "output.log")
    private var nextFilePathGenerationDate: Date? = nil
    private var fileHandle: FileHandle? = nil
    private var fileSize: Int = 0
    
    init(path: String, rollingInterval: RollingInteval = .day, fileSizeLimitBytes: Int = 10485760) {
        self.path = path
        self.rollingInterval = rollingInterval
        self.fileSizeLimitBytes = fileSizeLimitBytes
    }
    
    deinit {
        if let file = self.fileHandle {
            try? file.close()
            self.fileHandle = nil
        }
    }
    
    func write(message: Data?) {
        guard let data = message else {
            print("[FileWriter] Logged message cannot be nil.")
            return
        }
        
        if self.shouldCreateNewFile() {
            self.setNewFile()
        }
        
        self.saveToFile(data: data)
    }
    
    private func saveToFile(data: Data) {
        fileQueue.async {
            do {
                if let file = self.fileHandle {
                    file.write(data)
                    self.fileSize += data.count
                } else if let file = try? FileHandle(forWritingTo: self.filePath) {
                    file.seekToEndOfFile()
                    file.write(data)

                    self.fileHandle = file
                    self.fileSize = self.getFileSize()
                } else {
                    try data.write(to: self.filePath, options: .atomic)
                }
            } catch(let error) {
                print("[FileWriter] Could not write to file: \(self.filePath), error: \(error).")
            }
        }
    }
    
    private func shouldCreateNewFile() -> Bool {
        return self.nextFilePathGenerationDate == nil
            || self.nextFilePathGenerationDate! < Date()
            || self.fileSize > self.fileSizeLimitBytes
    }
    
    private func setNewFile() {
        if let file = self.fileHandle {
            try? file.close()
            self.fileHandle = nil
        }

        self.filePath = self.getFilePathWithDateStamp()
        self.nextFilePathGenerationDate = self.getNextFilePathGenerationDate()
        self.fileSize = 0
        self.createDirectories()
    }
    
    private func getFilePathWithDateStamp() -> URL {
        var filePath = self.getFilePath()
        
        let pathExtension = filePath.pathExtension
        let timeStamp = getTimeStamp()
        
        filePath.deletePathExtension()
        filePath.appendPathExtension(timeStamp + "." + pathExtension)
        
        return filePath
    }
    
    private func getTimeStamp() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self.rollingInterval.rawValue
        return dateFormatter.string(from: Date())
    }
    
    private func getNextFilePathGenerationDate() -> Date {
        switch(self.rollingInterval) {
        case .year:
            return Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        case .month:
            return Calendar.current.date(byAdding: .month, value: 1, to: Date())!
        case .day:
            return Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        case .hour:
            return Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        case .minute:
            return Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
        default:
            return Calendar.current.date(byAdding: .year, value: 10, to: Date())!
        }
    }
    
    private func getFilePath() -> URL {
        if (self.path.starts(with: "/")) {
            return URL(fileURLWithPath: self.path)
        }
        
        return getWorkingDirectory().appendingPathComponent(self.path)
    }
    
    private func getWorkingDirectory() -> URL {
        // get actual working directory
        let cwd = getcwd(nil, Int(PATH_MAX))
        defer {
            free(cwd)
        }

        let workingDirectory: String

        if let cwd = cwd, let string = String(validatingUTF8: cwd) {
            workingDirectory = string
        } else {
            workingDirectory = "./"
        }
        
        return URL(fileURLWithPath: workingDirectory)
    }
    
    private func getFileSize() -> Int {
        do {
            let values = try self.filePath.resourceValues(forKeys: [URLResourceKey.fileSizeKey])
            if let fileSize = values.fileSize {
                 return fileSize
            }
        } catch (let error) {
            print("[FileWriter] Cannot read file size: \(self.filePath.absoluteString), error: \(error).")
        }
        
        return 0
    }
    
    private func createDirectories() {
        do {
            try FileManager.default.createDirectory(at: self.filePath.deletingLastPathComponent(),
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
        } catch (let error) {
            print("[FileWriter] Could not create directory for file: \(self.filePath), error: \(error).")
        }
    }
}
