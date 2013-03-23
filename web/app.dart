library writer;

import 'dart:async';
import 'dart:html' hide Document;
import 'dart:json' as JSON;

//import 'package:web_ui/observe.dart';
//import 'package:web_ui/observe/list.dart';

part 'package:writer/document.dart'; 

// This class encapsulates my application state and logic.
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

  // Makes the provided document the active document.
  void selectDocument(Document doc) {
    activeDocument = doc;
    // We have to wait until the content element is instantiated to focus on it.
    Timer.run(() {
      query('#main .content').focus();
    });
  }

  // Returns true if the provided document matches the current search filter.
  bool matchesSearchFilter(Document doc) {
    if (searchFilter.isEmpty) {
      return true;
    }
    return doc.title.toLowerCase().contains(searchFilter.toLowerCase()) ||
           doc.content.toLowerCase().contains(searchFilter.toLowerCase());
  }

}

WriterApp app;

void main() {
  app = new WriterApp();
}
