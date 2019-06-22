const admin = require("firebase-admin");
const axios = require("axios");
const functions = require("firebase-functions");

admin.initializeApp(functions.config().firebase);

const ref = admin.database().ref();

const sendNewDealNotification = (dealName, dealImageURL) => {
  const payload = {
    data: {
      "attachment-url": dealImageURL
    },
    notification: {
      content_available: "true",
      title: "Check out this new deal!",
      body: dealName,
      mutable_content: "true"
    }
  };

  return sendNotification(payload);
};

const sendDealSoldOutNotification = (dealName, dealImageURL) => {
  const payload = {
    data: {
      "attachment-url": dealImageURL
    },
    notification: {
      content_available: "true",
      title: "The current deal has sold out!",
      body: `There are no more ${dealName} left`,
      mutable_content: "true"
    }
  };

  return sendNotification(payload);
};

const sendDealItemSoldOutNotification = (dealName, dealImageURL) => {
  const payload = {
    data: {
      "attachment-url": dealImageURL
    },
    notification: {
      content_available: "true",
      title: "One of the deal's items has sold out!",
      body: `Meh is running out of ${dealName}`,
      mutable_content: "true"
    }
  };

  return sendNotification(payload);
};

const sendNotification = (payload) => {
  let tokens = [];

  return admin.database().ref("/notifications").once("value", (snapshot) => {
    snapshot.forEach(childSnapshot => {
      if (childSnapshot.val() === true) tokens.push(childSnapshot.key);
    });

    return admin.messaging().sendToDevice(tokens, payload).then((res) => {
      console.log("Successfully sent message:", JSON.stringify(res));
      return true;
    }).catch((err) => {
      console.log("Error sending message:", JSON.stringify(err));
      return err;
    });
  });
};

const sendFeedbaclNotification = (payload) => {
  return admin.database().ref("/feedback/tokens").once("value", snapshot => {
    let tokens = [];
    snapshot.forEach(childSnapshot => {
      tokens.push(childSnapshot.key);
    });

    return admin.messaging().sendToDevice(tokens, payload).then(res => {
      console.log("Successfully sent message:", JSON.stringify(res));
      return true;
    }).catch(err => {
      console.error("Error sending message:", JSON.stringify(err));
      return err;
    });
  });
};

exports.updateItem = functions.https.onRequest((request, response) => {
  return ref.child("API_KEY").once("value", (snapshot) => {
    const API_KEY = snapshot.val();
    return axios.get(`https://api.meh.com/1/current.json?apikey=${API_KEY}`).then((res) => {
      return ref.child("currentDeal").once("value").then((snapshot) => {
        let dealId = snapshot.child("deal/id").val();
        return ref.child(`previousDeal/${dealId}`).update(snapshot.val()).then(() => {
          return ref.child(`previousDeal/${dealId}/time`).once("value").then(childSnapshot => {
            if (!childSnapshot.exists()) {
              let date = new Date();
              ref.child(`previousDeal/${dealId}/time`).set(date.getTime());
              ref.child(`previousDeal/${dealId}/date`).set({
                day: date.getDate(),
                month: date.getMonth(),
                year: date.getFullYear()
              });
            }
            Object.keys(res.data).forEach(key => ref.child(`currentDeal/${key}`).set(res.data[key]));
            response.send("Updated.");
            return true;
          }).catch(err => {
            console.error("Unable to update previous deal time:", err);
            return err;
          });
        }).catch(err => {
          console.error("Unable to update previous deal:", err);
          return err;
        });
      });
    }).catch((err) => {
      console.error("Error fetching meh data...", err);
      return err;
    })
  });
});

exports.sendDealUpdate = functions.database.ref("currentDeal/deal").onUpdate((change, context) => {
  const previousDeal = change.before.val();
  const deal = change.after.val();

  if (previousDeal.id === deal.id) {
    if (
      (!previousDeal.soldOutAt && deal.soldOutAt) ||
      (previousDeal.launches &&
        (previousDeal.launches.length !== previousDeal.items.length) &&
        deal.launches && (deal.launches.length === deal.items.length)
      )
    ) {
      console.log(`${deal.id} has sold out.`);
      return sendDealSoldOutNotification(deal.title, deal.photos[0].replace("http://", "https://"));
    } else if (
      (deal.launches && !previousDeal.launches) ||
      (deal.launches && previousDeal.launches &&
      (deal.launches.length !== previousDeal.launches.length))
    ) {
      console.log(`${deal.id} has an item that sold out.`);
      return sendDealItemSoldOutNotification(deal.title, deal.photos[0].replace("http://", "https://"));
    } else {
      console.log('No notification required.');
      return true;
    }
  } else {
    console.log(`${previousDeal.id} has ended, ${deal.id} has started.`);
    return sendNewDealNotification(deal.title, deal.photos[0].replace("http://", "https://"));
  }
});

exports.sendFeedbackSubmittedNotification = functions.database.ref("feedback/{feedback}").onCreate((snapshot, context) => {
  let feedbackId = context.params.feedback;
  const bucket = admin.storage().bucket();
  const payload = {
    notification: {
      content_available: "true",
      title: `New feedback submitted (${feedbackId})!`,
      body: snapshot.child("content").val(),
      mutable_content: "true"
    }
  };

  let file = bucket.file(`/feedback/${feedbackId}.JPG`);
  return file.getSignedUrl({
    action: 'read',
    expires: new Date(new Date().getTime() + 86400000)
  }).then(signedUrl => {
    if (signedUrl.length) {
      payload.data = {
        "attachment-url": signedUrl[0]
      };
    }
    return sendFeedbaclNotification(payload);
  }).catch(err => {
    console.error(err);
    return sendFeedbaclNotification(payload);
  });
});