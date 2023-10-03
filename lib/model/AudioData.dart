// ignore: file_names
import 'package:flutter/material.dart';

class AudioData extends ChangeNotifier {
  String imageUrl =
      "https://image.jimcdn.com/app/cms/image/transf/dimension=1920x10000:format=jpg/path/sfe162db7f5417cfe/image/if0d5387e710379d2/version/1515333113/image.jpg";
  String audioUrl = "";
  String titel =
      "Bitte drücken sie auf Play um die Audio zu ihere Sehenswürdigkeit zu hören";
  String description = "";
  String creator = "";
  bool isPlaying = false;

  // Methode zum Aktualisieren der Image-URL
  void setImageUrl(String url) {
    imageUrl = url;
    notifyListeners(); // Benachrichtigen Sie die Listener über die Änderung
  }

  // Methode zum Aktualisieren der Audio-URL
  void setAudioUrl(String url) {
    audioUrl = url;
    notifyListeners();
  }

  // Methode zum Aktualisieren des Titels
  void setTitel(String newTitel) {
    titel = newTitel;
    notifyListeners();
  }

  // Methode zum Aktualisieren der Beschreibung
  void setDescription(String newDescription) {
    description = newDescription;
    notifyListeners();
  }

  // Methode zum Aktualisieren des Erstellers
  void setCreator(String newCreator) {
    creator = newCreator;
    notifyListeners();
  }

  // Methode zum Aktualisieren des Wiedergabezustands
  void setIsPlaying(bool playing) {
    isPlaying = playing;
    notifyListeners();
  }
}
