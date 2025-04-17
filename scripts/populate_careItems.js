const fetch = (...args) => import("node-fetch").then(({ default: fetch }) => fetch(...args));
const { initializeApp } = require("firebase/app");
const { getFirestore, collection, doc, setDoc, writeBatch } = require("firebase/firestore");
a;
// Initialiser Firebase
const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

// Fonction pour générer un ID basé sur careType et name
function generateId(careType, name) {
  return `${careType.substring(0, 3).toUpperCase()}_${name.substring(0, 3).toUpperCase()}`;
}

// Fonction pour peupler la collection careItems
async function populateCareItems() {
  const careItems = [
    { careType: "Injection", name: "AAA" },
    { careType: "Injection", name: "BBB" },
    { careType: "Injection", name: "CCC" },
    { careType: "Toilette", name: "DDD" },
    { careType: "Toilette", name: "EEE" },
    { careType: "Toilette", name: "FFF" },
    { careType: "Soin", name: "III" },
    { careType: "Soin", name: "JJJ" },
    { careType: "Soin", name: "KKK" },
  ];

  const batch = writeBatch(db);

  careItems.forEach((item) => {
    const id = generateId(item.careType, item.name);
    const docRef = doc(collection(db, "careItems"), id);
    batch.set(docRef, {
      careType: item.careType,
      name: item.name,
    });
  });

  try {
    await batch.commit();
    console.log("Care items successfully added to the database!");
  } catch (error) {
    console.error("Error populating care items:", error);
  }
}

// Exécuter le script
populateCareItems();
