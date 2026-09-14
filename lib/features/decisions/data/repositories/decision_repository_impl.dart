import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/logging/app_logger.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/decision.dart';
import '../../domain/entities/decision_option.dart';
import '../../domain/entities/decision_stats.dart';
import '../../domain/repositories/decision_repository.dart';

class DecisionRepositoryImpl implements DecisionRepository {
  DecisionRepositoryImpl({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Decision _decisionFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Decision(
      id: doc.id,
      authorId: data['authorId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      closesAt: (data['closesAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  DecisionOption _optionFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return DecisionOption(
      id: doc.id,
      text: data['text'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      link: data['link'] as String? ?? '',
      order: data['order'] as int? ?? 0,
    );
  }

  @override
  Future<Result<List<Category>>> getCategories() async {
    try {
      final snap = await _firestore.collection('categories').orderBy('order').get();
      return Result.success(snap.docs
          .map((d) => Category(id: d.id, name: d.data()['name'] as String? ?? d.id, order: d.data()['order'] as int? ?? 0))
          .toList());
    } catch (e, st) {
      appLogger.e('getCategories failed', error: e, stackTrace: st);
      return const Result.failure(NetworkFailure());
    }
  }

  @override
  Future<Result<String>> createDecision({
    required String authorId,
    required String title,
    required String description,
    required String category,
    required List<({String text, String link})> options,
    DateTime? closesAt,
  }) async {
    if (title.trim().isEmpty) {
      return const Result.failure(ValidationFailure('El título es obligatorio.'));
    }
    if (options.length < 2 || options.length > 5) {
      return const Result.failure(ValidationFailure('Tiene que haber entre 2 y 5 opciones.'));
    }
    if (options.any((o) => o.text.trim().isEmpty)) {
      return const Result.failure(ValidationFailure('Todas las opciones necesitan texto.'));
    }
    if (options.any((o) => o.link.trim().isNotEmpty && !_isValidLink(o.link))) {
      return const Result.failure(ValidationFailure('Alguno de los links no es válido (tiene que empezar con http:// o https://).'));
    }

    try {
      final decisionRef = _firestore.collection('decisions').doc();
      final batch = _firestore.batch();

      batch.set(decisionRef, {
        'authorId': authorId,
        'title': title.trim(),
        'description': description.trim(),
        'category': category,
        'imageUrl': '',
        'closesAt': closesAt != null ? Timestamp.fromDate(closesAt) : null,
        'createdAt': FieldValue.serverTimestamp(),
        'voteCount': 0,
        'likeCount': 0,
        'commentCount': 0,
        'shareCount': 0,
      });

      for (var i = 0; i < options.length; i++) {
        final optionRef = decisionRef.collection('options').doc();
        batch.set(optionRef, {
          'text': options[i].text.trim(),
          'imageUrl': '',
          'link': options[i].link.trim(),
          'order': i,
          'voteCount': 0,
          'authorId': authorId,
        });
      }

      await batch.commit();
      return Result.success(decisionRef.id);
    } catch (e, st) {
      appLogger.e('createDecision failed', error: e, stackTrace: st);
      return const Result.failure(UnknownFailure());
    }
  }

  bool _isValidLink(String link) {
    final uri = Uri.tryParse(link.trim());
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
  }

  @override
  Stream<Decision?> watchDecision(String id) {
    return _firestore.collection('decisions').doc(id).snapshots().map(
          (doc) => doc.exists ? _decisionFromDoc(doc) : null,
        );
  }

  @override
  Stream<List<DecisionOption>> watchOptions(String decisionId) {
    return _firestore
        .collection('decisions')
        .doc(decisionId)
        .collection('options')
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs.map(_optionFromDoc).toList());
  }

  @override
  Future<Result<DecisionStats>> getDecisionStats(String decisionId) async {
    try {
      final results = await Future.wait([
        _firestore.collection('votes').where('decisionId', isEqualTo: decisionId).count().get(),
        _firestore.collection('comments').where('decisionId', isEqualTo: decisionId).count().get(),
        _firestore.collection('likes').where('decisionId', isEqualTo: decisionId).count().get(),
      ]);
      return Result.success(DecisionStats(
        votes: results[0].count ?? 0,
        comments: results[1].count ?? 0,
        likes: results[2].count ?? 0,
      ));
    } catch (e, st) {
      appLogger.e('getDecisionStats failed', error: e, stackTrace: st);
      return const Result.failure(NetworkFailure());
    }
  }

  @override
  Future<Result<List<Decision>>> listByAuthor(String authorId) async {
    try {
      final snap = await _firestore
          .collection('decisions')
          .where('authorId', isEqualTo: authorId)
          .orderBy('createdAt', descending: true)
          .get();
      return Result.success(snap.docs.map(_decisionFromDoc).toList());
    } catch (e, st) {
      appLogger.e('listByAuthor failed', error: e, stackTrace: st);
      return const Result.failure(NetworkFailure());
    }
  }

  @override
  Future<Result<void>> updateDecision({
    required String id,
    required String title,
    required String description,
    required String category,
    DateTime? closesAt,
  }) async {
    if (title.trim().isEmpty) {
      return const Result.failure(ValidationFailure('El título es obligatorio.'));
    }
    try {
      await _firestore.collection('decisions').doc(id).update({
        'title': title.trim(),
        'description': description.trim(),
        'category': category,
        'closesAt': closesAt != null ? Timestamp.fromDate(closesAt) : null,
      });
      return const Result.success(null);
    } catch (e, st) {
      appLogger.e('updateDecision failed', error: e, stackTrace: st);
      return const Result.failure(UnknownFailure());
    }
  }

  @override
  Future<Result<void>> deleteDecision(String id) async {
    try {
      final decisionRef = _firestore.collection('decisions').doc(id);
      final optionsSnap = await decisionRef.collection('options').get();
      final batch = _firestore.batch();
      for (final doc in optionsSnap.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(decisionRef);
      await batch.commit();
      return const Result.success(null);
    } catch (e, st) {
      appLogger.e('deleteDecision failed', error: e, stackTrace: st);
      return const Result.failure(UnknownFailure());
    }
  }
}
