import 'dart:async';
import 'dart:html';
import 'dart:json' as JSON;

//import 'package:web_ui/observe.dart';
//import 'package:web_ui/observe/list.dart';

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
    _content.split(new RegExp(r"([^a-zA-z1-9\']|\s)+")).forEach((word) {
      if (!word.isEmpty) {
        count++;
      }
    });
    return count;
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

class WriterApp {
  List<Document> documents = [];
  List<String> documentIds = [];
  Document activeDocument;

  String searchFilter = '';

  const String DOCUMENT_ID_KEY = 'writer-document-id';

  WriterApp() {
    if (window.localStorage[DOCUMENT_ID_KEY] != null) {
      documentIds = JSON.parse(window.localStorage[DOCUMENT_ID_KEY]);
    }
    for (var id in documentIds) {
      loadDocument(id);
    }
  }

  void createDocument() {
    // We only want to create a new document if the user doesn't have an
    // unmodified new document that was just created.
    if (documents.length > 0) {
      if (documents.last.created == documents.last.modified) {
        selectDocument(documents.last);
        return;
      }
    }
    // Create a new document.
    var doc = new Document('Untitled', '');
    documents.add(doc);
    selectDocument(doc);
  }

  void deleteDocument(Document doc) {
    documents.remove(doc);
    if (documents.length > 0) {
      if (activeDocument == doc) {
        selectDocument(documents.last);
      } else {
        selectDocument(activeDocument);
      }
    }
    if (activeDocument == doc) {
      activeDocument = null;
    }
    unsave(doc);
  }

  void saveActiveDocument() {
    window.localStorage[activeDocument.id] = activeDocument.toJson();
    if (!documentIds.contains(activeDocument.id)) {
      documentIds.add(activeDocument.id);
      window.localStorage[DOCUMENT_ID_KEY] = JSON.stringify(documentIds);
    }
  }

  // Removes a document from local storage.
  void unsave(Document doc) {
    documentIds.remove(doc.id);
    window.localStorage[DOCUMENT_ID_KEY] = JSON.stringify(documentIds);
    window.localStorage.remove(doc.id);
  }

  // Load a document from local storage, provided the local storage key.
  void loadDocument(String key) {
    var doc = new Document.fromJson(window.localStorage[key]);
    documents.add(doc);
    selectDocument(doc);
  }

  selectDocument(Document doc) {
    activeDocument = doc;
    // We have to wait until the content element is instantiated to focus on it.
    Timer.run(() {
      query('#main .content').focus();
    });
  }

  // Returns true if the provided document matches the current search filter.
  matchesFilter(Document doc) {
    return doc.title.toLowerCase().contains(searchFilter.toLowerCase()) ||
           doc.content.toLowerCase().contains(searchFilter.toLowerCase());
  }

}

WriterApp app;

void main() {
  app = new WriterApp();
}
