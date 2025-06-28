const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

admin.initializeApp();

const db = admin.firestore();
const auth = admin.auth();

// Configuração do email
const transporter = nodemailer.createTransporter({
  service: 'gmail',
  auth: {
    user: functions.config().email.user,
    pass: functions.config().email.pass
  }
});

// Função para enviar notificações diárias
exports.sendDailyNotifications = functions.pubsub.schedule('0 9,15 * * *').timeZone('America/Sao_Paulo').onRun(async (context) => {
  try {
    // Buscar usuários que ativaram notificações
    const usersSnapshot = await db.collection('users')
      .where('notificationsEnabled', '==', true)
      .get();

    if (usersSnapshot.empty) {
      console.log('Nenhum usuário com notificações ativadas');
      return null;
    }

    // Buscar conhecimento aleatório
    const knowledgeSnapshot = await db.collection('knowledge')
      .where('isApproved', '==', true)
      .get();

    if (knowledgeSnapshot.empty) {
      console.log('Nenhum conhecimento disponível');
      return null;
    }

    const knowledgeDocs = knowledgeSnapshot.docs;
    const randomKnowledge = knowledgeDocs[Math.floor(Math.random() * knowledgeDocs.length)].data();

    // Enviar notificação para cada usuário
    const notifications = usersSnapshot.docs.map(async (userDoc) => {
      const user = userDoc.data();
      
      const message = {
        notification: {
          title: '🤓 Novo Conhecimento Aleatório!',
          body: randomKnowledge.title
        },
        data: {
          knowledgeId: randomKnowledge.id,
          category: randomKnowledge.category,
          click_action: 'FLUTTER_NOTIFICATION_CLICK'
        },
        token: user.fcmToken
      };

      try {
        await admin.messaging().send(message);
        console.log(`Notificação enviada para ${user.name}`);
      } catch (error) {
        console.error(`Erro ao enviar notificação para ${user.name}:`, error);
      }
    });

    await Promise.all(notifications);
    console.log('Notificações diárias enviadas com sucesso');
    return null;
  } catch (error) {
    console.error('Erro ao enviar notificações:', error);
    return null;
  }
});

// Função para processar contribuições
exports.processContribution = functions.firestore
  .document('contributions/{contributionId}')
  .onCreate(async (snap, context) => {
    const contribution = snap.data();
    
    try {
      // Enviar email para o admin
      const mailOptions = {
        from: functions.config().email.user,
        to: functions.config().email.admin,
        subject: 'Nova Contribuição - Aleatoriamente',
        html: `
          <h2>Nova Contribuição Recebida</h2>
          <p><strong>Título:</strong> ${contribution.title}</p>
          <p><strong>Categoria:</strong> ${contribution.category}</p>
          <p><strong>Conteúdo:</strong> ${contribution.content}</p>
          <p><strong>Fonte:</strong> ${contribution.source || 'Não informada'}</p>
          <p><strong>Usuário:</strong> ${contribution.userId}</p>
          <p><strong>Data:</strong> ${contribution.createdAt.toDate().toLocaleString()}</p>
          <br>
          <p>Acesse o painel admin para revisar esta contribuição.</p>
        `
      };

      await transporter.sendMail(mailOptions);
      console.log('Email de notificação enviado para o admin');
    } catch (error) {
      console.error('Erro ao enviar email:', error);
    }
  });

// Função para aprovar contribuição
exports.approveContribution = functions.https.onCall(async (data, context) => {
  // Verificar se o usuário é admin
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Usuário não autenticado');
  }

  const userDoc = await db.collection('users').doc(context.auth.uid).get();
  if (!userDoc.exists || !userDoc.data().isAdmin) {
    throw new functions.https.HttpsError('permission-denied', 'Acesso negado');
  }

  const { contributionId } = data;

  try {
    const contributionRef = db.collection('contributions').doc(contributionId);
    const contributionDoc = await contributionRef.get();

    if (!contributionDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Contribuição não encontrada');
    }

    const contribution = contributionDoc.data();

    // Criar novo conhecimento
    const knowledgeData = {
      title: contribution.title,
      content: contribution.content,
      category: contribution.category,
      source: contribution.source,
      isAdultContent: contribution.isAdultContent,
      authorId: contribution.userId,
      authorName: contribution.authorName,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      favoriteCount: 0,
      isApproved: true
    };

    const knowledgeRef = await db.collection('knowledge').add(knowledgeData);

    // Atualizar status da contribuição
    await contributionRef.update({
      status: 'approved',
      approvedAt: admin.firestore.FieldValue.serverTimestamp(),
      knowledgeId: knowledgeRef.id
    });

    // Atualizar estatísticas do usuário
    const userRef = db.collection('users').doc(contribution.userId);
    await userRef.update({
      contributionCount: admin.firestore.FieldValue.increment(1),
      totalPoints: admin.firestore.FieldValue.increment(100)
    });

    // Enviar notificação para o usuário
    const userDoc = await userRef.get();
    const user = userDoc.data();

    if (user.fcmToken) {
      const message = {
        notification: {
          title: '🎉 Sua Contribuição foi Aprovada!',
          body: `"${contribution.title}" foi adicionado à biblioteca`
        },
        data: {
          knowledgeId: knowledgeRef.id,
          type: 'contribution_approved'
        },
        token: user.fcmToken
      };

      await admin.messaging().send(message);
    }

    return { success: true, knowledgeId: knowledgeRef.id };
  } catch (error) {
    console.error('Erro ao aprovar contribuição:', error);
    throw new functions.https.HttpsError('internal', 'Erro interno do servidor');
  }
});

// Função para rejeitar contribuição
exports.rejectContribution = functions.https.onCall(async (data, context) => {
  // Verificar se o usuário é admin
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Usuário não autenticado');
  }

  const userDoc = await db.collection('users').doc(context.auth.uid).get();
  if (!userDoc.exists || !userDoc.data().isAdmin) {
    throw new functions.https.HttpsError('permission-denied', 'Acesso negado');
  }

  const { contributionId, reason } = data;

  try {
    const contributionRef = db.collection('contributions').doc(contributionId);
    const contributionDoc = await contributionRef.get();

    if (!contributionDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Contribuição não encontrada');
    }

    const contribution = contributionDoc.data();

    // Atualizar status da contribuição
    await contributionRef.update({
      status: 'rejected',
      rejectedAt: admin.firestore.FieldValue.serverTimestamp(),
      rejectionReason: reason
    });

    // Enviar notificação para o usuário
    const userRef = db.collection('users').doc(contribution.userId);
    const userDoc = await userRef.get();
    const user = userDoc.data();

    if (user.fcmToken) {
      const message = {
        notification: {
          title: '📝 Contribuição Revisada',
          body: `"${contribution.title}" não foi aprovado. Motivo: ${reason}`
        },
        data: {
          type: 'contribution_rejected',
          reason: reason
        },
        token: user.fcmToken
      };

      await admin.messaging().send(message);
    }

    return { success: true };
  } catch (error) {
    console.error('Erro ao rejeitar contribuição:', error);
    throw new functions.https.HttpsError('internal', 'Erro interno do servidor');
  }
});

// Função para processar reports
exports.processReport = functions.firestore
  .document('reports/{reportId}')
  .onCreate(async (snap, context) => {
    const report = snap.data();
    
    try {
      // Enviar email para o admin
      const mailOptions = {
        from: functions.config().email.user,
        to: functions.config().email.admin,
        subject: 'Novo Report - Aleatoriamente',
        html: `
          <h2>Novo Report Recebido</h2>
          <p><strong>Conhecimento ID:</strong> ${report.knowledgeId}</p>
          <p><strong>Motivo:</strong> ${report.reason}</p>
          <p><strong>Reportado por:</strong> ${report.reportedBy}</p>
          <p><strong>Data:</strong> ${report.reportedAt.toDate().toLocaleString()}</p>
          <br>
          <p>Acesse o painel admin para revisar este report.</p>
        `
      };

      await transporter.sendMail(mailOptions);
      console.log('Email de report enviado para o admin');
    } catch (error) {
      console.error('Erro ao enviar email de report:', error);
    }
  });

// Função para atualizar estatísticas em tempo real
exports.updateStats = functions.firestore
  .document('knowledge/{knowledgeId}')
  .onUpdate(async (change, context) => {
    const newData = change.after.data();
    const previousData = change.before.data();
    
    // Se o número de favoritos mudou, atualizar ranking
    if (newData.favoriteCount !== previousData.favoriteCount) {
      try {
        // Atualizar ranking de fatos mais favoritados
        await db.collection('rankings').doc('topFacts').set({
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          knowledgeId: context.params.knowledgeId,
          favoriteCount: newData.favoriteCount
        }, { merge: true });
        
        console.log('Ranking atualizado');
      } catch (error) {
        console.error('Erro ao atualizar ranking:', error);
      }
    }
  });

// Função para limpar dados antigos
exports.cleanupOldData = functions.pubsub.schedule('0 2 * * 0').timeZone('America/Sao_Paulo').onRun(async (context) => {
  try {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    // Limpar reports antigos
    const reportsSnapshot = await db.collection('reports')
      .where('reportedAt', '<', thirtyDaysAgo)
      .get();

    const deletePromises = reportsSnapshot.docs.map(doc => doc.ref.delete());
    await Promise.all(deletePromises);

    console.log(`${reportsSnapshot.size} reports antigos removidos`);
    return null;
  } catch (error) {
    console.error('Erro na limpeza de dados:', error);
    return null;
  }
});

// Função para gerar relatório semanal
exports.generateWeeklyReport = functions.pubsub.schedule('0 9 * * 1').timeZone('America/Sao_Paulo').onRun(async (context) => {
  try {
    const oneWeekAgo = new Date();
    oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);

    // Estatísticas da semana
    const stats = {
      newUsers: 0,
      newContributions: 0,
      newFavorites: 0,
      newReports: 0,
      topKnowledge: null
    };

    // Contar novos usuários
    const newUsersSnapshot = await db.collection('users')
      .where('createdAt', '>=', oneWeekAgo)
      .get();
    stats.newUsers = newUsersSnapshot.size;

    // Contar novas contribuições
    const newContributionsSnapshot = await db.collection('contributions')
      .where('createdAt', '>=', oneWeekAgo)
      .get();
    stats.newContributions = newContributionsSnapshot.size;

    // Contar novos favoritos
    const newFavoritesSnapshot = await db.collection('userFavorites')
      .where('createdAt', '>=', oneWeekAgo)
      .get();
    stats.newFavorites = newFavoritesSnapshot.size;

    // Contar novos reports
    const newReportsSnapshot = await db.collection('reports')
      .where('reportedAt', '>=', oneWeekAgo)
      .get();
    stats.newReports = newReportsSnapshot.size;

    // Buscar conhecimento mais favoritado da semana
    const topKnowledgeSnapshot = await db.collection('knowledge')
      .where('createdAt', '>=', oneWeekAgo)
      .orderBy('favoriteCount', 'desc')
      .limit(1)
      .get();

    if (!topKnowledgeSnapshot.empty) {
      stats.topKnowledge = topKnowledgeSnapshot.docs[0].data();
    }

    // Salvar relatório
    await db.collection('reports').doc('weekly').set({
      weekOf: oneWeekAgo,
      stats: stats,
      generatedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    console.log('Relatório semanal gerado com sucesso');
    return null;
  } catch (error) {
    console.error('Erro ao gerar relatório semanal:', error);
    return null;
  }
}); 