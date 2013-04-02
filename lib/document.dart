part of writer;

@observable
class Document {

  String _title;
  String _content;

  DateTime created;
  DateTime modified;

  String id;

  // This construtor is for creating the object naturally.
  Document(this._title, this._content) {
    // Use the object's hashCode as the unique key.
    // TODO: Maybe generate something longer?
    var random = new Random();
    id = 'document-${random.nextInt(1000000)}';
    created = new DateTime.now();
    modified = new DateTime.now();
  }

  // This constructor is for re-creating an existing document from JSON.
  Document.fromJson(json) {
    var data = JSON.parse(json);
    id = data['id'];
    _title = data['title'];
    _content = data['content'];
    created = DateTime.parse(data['created']);
    modified = DateTime.parse(data['modified']);
  }

  // Serialize this object into a JSON string.
  String toJson() {
    var data = {
      'id': id,
      'title': _title,
      'content': _content,
      'created': created.toString(),
      'modified': modified.toString()
    };
    return JSON.stringify(data);
  }

  set title(String title) {
    _title = title;
    modified = new DateTime.now();
  }

  String get title => _title;

  set content(String content) {
    _content = content;
    modified = new DateTime.now();
  }

  String get content => _content;

  String get wordCount {
    int count = new RegExp(r"(\w|\')+").allMatches(_content).length;
    if (count == 1) {
      return '$count word';
    }
    return '$count words';
  }
}
