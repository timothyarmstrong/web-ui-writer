library writer;

import 'dart:async';
import 'dart:html' hide Document;
import 'dart:json' as JSON;
import 'dart:math' show Random;

import 'package:web_ui/web_ui.dart';

part 'package:writer/document.dart'; 

// This class encapsulates the application state and logic.
@observable
class WriterApp {
  final List<Document> documents = toObservable([]);
  List<String> documentIds = [];
  Document activeDocument;

  String searchFilter = '';

  // Used to control which panel is displayed in the mobile mode.
  bool sidebarActive = true;
  bool contentActive = false;

  const String DOCUMENT_ID_KEY = 'writer-document-id';

  WriterApp() {
    loadDocuments();
  }

  // Creates a new empty document in the application.
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

  // Deletes the provided document from the application.
  void deleteDocument(Document doc) {
    documents.remove(doc);
    if (documents.length > 0) {
      if (activeDocument == doc) {
        selectDocument(documents.last);
      } else {
        selectDocument(activeDocument);
      }
    } else {
      activeDocument = null;
    }
    removeDocumentFromStorage(doc);
  }

  // Save the currently active document to local storage.
  void saveActiveDocument() {
    window.localStorage[activeDocument.id] = activeDocument.toJson();
    if (!documentIds.contains(activeDocument.id)) {
      documentIds.add(activeDocument.id);
      window.localStorage[DOCUMENT_ID_KEY] = JSON.stringify(documentIds);
    }
  }

  // Removes a document from local storage.
  void removeDocumentFromStorage(Document doc) {
    documentIds.remove(doc.id);
    window.localStorage[DOCUMENT_ID_KEY] = JSON.stringify(documentIds);
    window.localStorage.remove(doc.id);
  }

  // Load all of the documents from local storage into the application.
  void loadDocuments() {
    if (window.localStorage[DOCUMENT_ID_KEY] != null) {
      documentIds = JSON.parse(window.localStorage[DOCUMENT_ID_KEY]);
    }
    for (var id in documentIds) {
      var doc = new Document.fromJson(window.localStorage[id]);
      documents.add(doc);
      selectDocument(doc);
    }
  }

  // Makes the provided document the active document.
  void selectDocument(Document doc, [bool markActive = false]) {
    // Ensure the document being selected wasn't just deleted.
    if (!documents.contains(doc)) {
      return;
    }
    activeDocument = doc;
    if (markActive) {
      sidebarActive = false;
      contentActive = true;
    }
    // We have to wait until the content element is instantiated to focus on it.
    Timer.run(() {
      //query('#main .content').focus();
    });
  }

  void showMenu() {
    sidebarActive = true;
    contentActive = false;
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
