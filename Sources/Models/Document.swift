import Foundation

struct Document {
    var fileURL: URL?
    var content: String
    var isDirty: Bool
    
    var fileName: String {
        return fileURL?.lastPathComponent ?? "Untitled"
    }
    
    init(fileURL: URL? = nil, content: String = "", isDirty: Bool = false) {
        self.fileURL = fileURL
        self.content = content
        self.isDirty = isDirty
    }
}
