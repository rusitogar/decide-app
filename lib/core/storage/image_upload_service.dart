import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Elige una foto de la galería y la sube a Firebase Storage, devolviendo la
/// URL pública para guardar en Firestore. Usado tanto para el avatar de
/// perfil como para las fotos de las opciones de una decisión.
class ImageUploadService {
  ImageUploadService({FirebaseStorage? storage, ImagePicker? picker})
      : _storage = storage ?? FirebaseStorage.instance,
        _picker = picker ?? ImagePicker();

  final FirebaseStorage _storage;
  final ImagePicker _picker;

  Future<XFile?> pickImage() {
    return _picker.pickImage(source: ImageSource.gallery, maxWidth: 1600, imageQuality: 85);
  }

  Future<String> upload({required XFile file, required String path}) async {
    final bytes = await file.readAsBytes();
    final ref = _storage.ref(path);
    await ref.putData(bytes, SettableMetadata(contentType: file.mimeType ?? 'image/jpeg'));
    return ref.getDownloadURL();
  }
}
