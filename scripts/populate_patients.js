const fetch = (...args) => import("node-fetch").then(({ default: fetch }) => fetch(...args));
const { initializeApp } = require("firebase/app");
const { getFirestore, collection, doc, setDoc, getDocs, query, where } = require("firebase/firestore");
const firebaseConfig = require("./private.firebase_config");

// Initialiser Firebase
const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

// Fonction pour générer un ID unique
function generateUniqueId() {
  const now = new Date();
  const year = now.getFullYear() % 100; // Les deux derniers chiffres de l'année
  const dayOfYear = Math.floor((now - new Date(now.getFullYear(), 0, 0)) / 1000 / 60 / 60 / 24); // Jour de l'année
  const dayHex = dayOfYear.toString(16).toUpperCase().padStart(3, "0"); // Hexadécimal sur 3 caractères
  const chars = "ABCDEFGHIJKLMNPQRSTUVWXYZ123456789";
  const randomPart = Array.from({ length: 4 })
    .map(() => chars[Math.floor(Math.random() * chars.length)])
    .join("");
  return `${year}${dayHex}${randomPart}`;
}

// Fonction pour créer un patient
async function createPatient() {
  const response = await fetch("https://randomuser.me/api/?nat=fr");
  const data = await response.json();
  const user = data.results[0];

  const patient = {
    prenom: user.name.first,
    nom: user.name.last,
    dateNaissance: new Date(user.dob.date), // Convertir la date de naissance
    id: generateUniqueId(),
    adresse: `${user.location.street.number} ${user.location.street.name}, ${user.location.postcode}, ${user.location.city}`,
    autresInfos: null, // Pas d'autres informations pour l'instant
    infirmiers: ["YqIMZG0vYPeGdc9yzRnK9SkTiEi1"], // Liste vide d'infirmiers
  };

  return patient;
}

// Fonction pour vérifier si un patient existe déjà dans Firestore
async function patientExists(firstname, lastname) {
  const patientsRef = collection(db, "patients");
  const querySnapshot = await getDocs(query(patientsRef, where("firstname", "==", firstname), where("lastname", "==", lastname)));
  return !querySnapshot.empty;
}

// Fonction pour enregistrer un patient dans Firestore
async function savePatientToFirestore(patient) {
  try {
    const exists = await patientExists(patient.prenom, patient.nom);
    if (exists) {
      console.log(`Patient ${patient.prenom} ${patient.nom} existe déjà. Ignoré.`);
      return;
    }

    const patientRef = doc(collection(db, "patients"), patient.id);
    await setDoc(patientRef, {
      firstname: patient.prenom,
      lastname: patient.nom,
      dob: patient.dateNaissance.toISOString(),
      address: patient.adresse,
      autresInfos: patient.autresInfos,
      caregivers: patient.infirmiers,
    });
    console.log(`Patient ${patient.id} enregistré avec succès.`);
  } catch (error) {
    console.error(`Erreur lors de l'enregistrement du patient ${patient.id}:`, error);
  }
}

// Fonction principale pour créer et enregistrer 30 patients
async function main() {
  for (let i = 0; i < 30; i++) {
    const patient = await createPatient();
    await savePatientToFirestore(patient);
  }
  console.log("Tous les patients ont été enregistrés.");
}

main().catch(console.error);
