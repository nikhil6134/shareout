const functions = require("firebase-functions");
const admin = require('firebase-admin');
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

exports.onCreateFollower =  functions.firestore.document("/followers/{userId}/userFollowers/{followerId}").onCreate((snapshot,context) => {
 
 console.log("Follower Created",snapshot.data());
    const userId =  context.params.userId;
 const followerId =  context.params.followerId;

 //1) Get followed users posts

 const followedUserRef =  admin.firestore().collections('posts').doc(userId).collection("userPosts");

 //2) create following users timeline ref

 const timelinePostRef = admin.firestore().collection('timeline').doc(followerId).collection('timelinePosts');

 //3) Get followed users posts

 const querySnapshot = await followedUserRef.get();

 //4) Add each user post to following users timeline

 querySnapshot.forEach(doc => {
  if(doc.exists){
      const postId = doc.id;
      const postData =  doc.data();
      timelinePostRef.doc(postId).set(postData)
  }
 });
});