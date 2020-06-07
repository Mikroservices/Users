import Foundation
import Logging

public struct FileLogger: LogHandler {
    
    public var metadata = Logger.Metadata() {
        didSet {
            self.logFormatter.metadata = self.metadata
        }
    }

    public var logLevel: Logger.Level = .info        
    private let fileWriter: FileWriter
    private var logFormatter: LogFormatter
    
    public init(label: String,
                path: String,
                level: Logger.Level = .debug,
                metadata: Logger.Metadata = [:],
                logFormatter: LogFormatter = SingleLineFormatter(),
                rollingInterval: RollingInteval = .day,
                fileSizeLimitBytes: Int = 10485760) {
        self.label = label
        self.logLevel = level
        self.metadata = metadata
        self.logFormatter = logFormatter
        self.fileWriter = FileWriter(path: path, rollingInterval: rollingInterval, fileSizeLimitBytes: fileSizeLimitBytes)
    }

    public let label: String
    
    public func log(level: Logger.Level,
                    message: Logger.Message,
                    metadata: Logger.Metadata?,
                    file: String,
                    function: String,
                    line: UInt) {

        let message = try? self.logFormatter.format(label: self.label,
                                               level: level,
                                               message: message,
                                               metadata: metadata,
                                               file: file,
                                               function: function,
                                               line: line)

        self.fileWriter.write(message: message)
    }
    
    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            return self.metadata[metadataKey]
        }
        set {
            self.metadata[metadataKey] = newValue
        }
    }
}
