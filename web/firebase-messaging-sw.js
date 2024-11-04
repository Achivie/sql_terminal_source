importScripts( "https://www.gstatic.com/firebasejs/10.8.1/firebase-app.js");
importScripts('https://www.gstatic.com/firebasejs/10.8.1/firebase-messaging.js');

firebase.initializeApp({
    apiKey: "AIzaSyDTNGiXeUCNmwMJjQA-dcYkc-cwbBR1GA8",
    authDomain: "sql-terminal-e79c6.firebaseapp.com",
    projectId: "sql-terminal-e79c6",
    storageBucket: "sql-terminal-e79c6.appspot.com",
    messagingSenderId: "249126883370",
    appId: "1:249126883370:web:461c82f70c85b240fff353",
    measurementId: "G-MDESN0Z5R1"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
    console.log('Received background message ', payload);

    const notificationTitle = payload.notification.title;
    const notificationOptions = {
      body: payload.notification.body,
    };

    self.registration.showNotification(notificationTitle,
      notificationOptions);
  });