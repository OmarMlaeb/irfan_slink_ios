import Foundation

struct Inbox{
    var id: Int
    var date: String
    var subject: String
    var message: String
    var creator_name: String
    var creator_id: Int
    var attachment_link: String
    var attachment_content_type: String
    var attachment_file_name: String
    var attachment_file_size: String
    var canReply: Bool
    var unreadMessages: Int
 
    public init(id: Int, date: String, subject: String, message: String, creator_name: String, creator_id: Int, attachment_link: String, attachment_content_type: String, attachment_file_name: String, attachment_file_size: String, canReply: Bool, unreadMessages: Int) {
        self.id = id
        self.date = date
        self.subject = subject
        self.message = message
        self.creator_name = creator_name
        self.creator_id = creator_id
        self.attachment_link = attachment_link
        self.attachment_content_type = attachment_content_type
        self.attachment_file_name = attachment_file_name
        self.attachment_file_size = attachment_file_size
        self.canReply = canReply
        self.unreadMessages = unreadMessages
    }
}
