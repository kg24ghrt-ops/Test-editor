import Foundation

struct Document {
    var fileURL: URL?
    var content: String
    var isDirty: Bool
    
    init(fileURL: URL? = nil, content: String = "", isDirty: Bool = false) {
        self.fileURL = fileURL
        self.content = content
        self.isDirty = isDirty
    }
}
