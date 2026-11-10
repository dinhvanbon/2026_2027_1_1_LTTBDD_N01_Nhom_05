importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyDHm10y3AkrJLTt-B4a0N84LYSmLFzZtGg",
  authDomain: "life-rpg-app-94f1c.firebaseapp.com",
  projectId: "life-rpg-app-94f1c",
  storageBucket: "life-rpg-app-94f1c.firebasestorage.app",
  messagingSenderId: "888213272879",
  appId: "1:888213272879:web:40bfd42baef477c2c549da",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log("Background message received:", payload);
});
