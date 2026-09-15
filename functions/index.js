const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const { onDocumentCreated, onDocumentDeleted } = require('firebase-functions/v2/firestore');
const functionsV1 = require('firebase-functions/v1');

initializeApp();
const db = getFirestore();

async function createNotification({ recipientId, actorId, type, decisionId }) {
  if (recipientId === actorId) return; // no notificarse a uno mismo
  await db.collection('notifications').add({
    recipientId,
    actorId,
    type,
    decisionId: decisionId ?? null,
    read: false,
    createdAt: FieldValue.serverTimestamp(),
  });
}

// Crea el perfil público (users/{uid}) apenas alguien se registra en
// Firebase Authentication, con los contadores en 0.
//
// OJO: a propósito no toca el campo "username" acá. Ese lo define el
// cliente (con el usuario que eligió al registrarse, o el uid como
// respaldo para logins con Google/Microsoft) — si esta función lo pisara
// con `user.uid` en cada corrida, se comía cualquier usuario elegido a
// mano, sin importar el orden en que corran los dos escrituras.
exports.onAuthUserCreate = functionsV1.auth.user().onCreate(async (user) => {
  await db.doc(`users/${user.uid}`).set(
    {
      displayName: user.displayName ?? '',
      avatarUrl: user.photoURL ?? '',
      bio: '',
      followersCount: 0,
      followingCount: 0,
      decisionsCount: 0,
      createdAt: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
});

// Voto creado -> suma el contador de la decisión, el de la opción elegida,
// y notifica al autor de la decisión.
exports.onVoteCreated = onDocumentCreated('votes/{voteId}', async (event) => {
  const vote = event.data.data();
  const decisionRef = db.doc(`decisions/${vote.decisionId}`);
  const optionRef = decisionRef.collection('options').doc(vote.optionId);

  const decisionSnap = await decisionRef.get();
  const decision = decisionSnap.data();

  await Promise.all([
    decisionRef.update({ voteCount: FieldValue.increment(1) }),
    optionRef.update({ voteCount: FieldValue.increment(1) }),
  ]);

  if (decision) {
    await createNotification({
      recipientId: decision.authorId,
      actorId: vote.userId,
      type: 'vote',
      decisionId: vote.decisionId,
    });
  }
});

// Like creado/eliminado -> ajusta el contador de la decisión.
exports.onLikeCreated = onDocumentCreated('likes/{likeId}', async (event) => {
  const like = event.data.data();
  await db.doc(`decisions/${like.decisionId}`).update({ likeCount: FieldValue.increment(1) });
});

exports.onLikeDeleted = onDocumentDeleted('likes/{likeId}', async (event) => {
  const like = event.data.data();
  await db.doc(`decisions/${like.decisionId}`).update({ likeCount: FieldValue.increment(-1) });
});

// Comentario creado/eliminado -> ajusta el contador y notifica al autor.
exports.onCommentCreated = onDocumentCreated('comments/{commentId}', async (event) => {
  const comment = event.data.data();
  const decisionRef = db.doc(`decisions/${comment.decisionId}`);

  const decisionSnap = await decisionRef.get();
  const decision = decisionSnap.data();

  await decisionRef.update({ commentCount: FieldValue.increment(1) });

  if (decision) {
    await createNotification({
      recipientId: decision.authorId,
      actorId: comment.authorId,
      type: 'comment',
      decisionId: comment.decisionId,
    });
  }
});

exports.onCommentDeleted = onDocumentDeleted('comments/{commentId}', async (event) => {
  const comment = event.data.data();
  await db.doc(`decisions/${comment.decisionId}`).update({ commentCount: FieldValue.increment(-1) });
});

// Follow creado/eliminado -> ajusta contadores de ambos usuarios y notifica.
exports.onFollowCreated = onDocumentCreated('follows/{followId}', async (event) => {
  const follow = event.data.data();

  await Promise.all([
    db.doc(`users/${follow.followerId}`).update({ followingCount: FieldValue.increment(1) }),
    db.doc(`users/${follow.followingId}`).update({ followersCount: FieldValue.increment(1) }),
  ]);

  await createNotification({
    recipientId: follow.followingId,
    actorId: follow.followerId,
    type: 'follow',
  });
});

exports.onFollowDeleted = onDocumentDeleted('follows/{followId}', async (event) => {
  const follow = event.data.data();

  await Promise.all([
    db.doc(`users/${follow.followerId}`).update({ followingCount: FieldValue.increment(-1) }),
    db.doc(`users/${follow.followingId}`).update({ followersCount: FieldValue.increment(-1) }),
  ]);
});

// Decisión creada/eliminada -> ajusta el contador de decisiones del autor.
exports.onDecisionCreated = onDocumentCreated('decisions/{decisionId}', async (event) => {
  const decision = event.data.data();
  await db.doc(`users/${decision.authorId}`).update({ decisionsCount: FieldValue.increment(1) });
});

exports.onDecisionDeleted = onDocumentDeleted('decisions/{decisionId}', async (event) => {
  const decision = event.data.data();
  await db.doc(`users/${decision.authorId}`).update({ decisionsCount: FieldValue.increment(-1) });

  // Las subcolecciones de Firestore no se borran solas: limpiamos las opciones.
  const optionsSnap = await event.data.ref.collection('options').get();
  await Promise.all(optionsSnap.docs.map((doc) => doc.ref.delete()));
});
