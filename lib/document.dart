part of writer;

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
    id = 'document-$hashCode';
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

  int get wordCount {
    int count = 0;
    _content.split(new RegExp(r"([^a-zA-z0-9\']|\s)+")).forEach((word) {
      if (!word.isEmpty) {
        count++;
      }
    });
    if (count == 1) {
      return '$count word';
    }
    return '$count words';
  }

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
}
