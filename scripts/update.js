const { initializeApp } = require("firebase/app");
const { getFirestore, collection, getDocs, updateDoc, doc } = require("firebase/firestore");

// Configuration Firebase
const firebaseConfig = {
  apiKey: "AIzaSyBFoaiZ4hF1QtFeBMaE3OuqAl7Vnr6_GIU",
  appId: "1:651483392870:web:8ca144e76373e881e1f6a7",
  messagingSenderId: "651483392870",
  projectId: "Infyz-12b4c",
  authDomain: "Infyz-12b4c.firebaseapp.com",
  storageBucket: "Infyz-12b4c.firebasestorage.app",
  measurementId: "G-KPR7FQX8RG",
};

// Initialiser Firebase
const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

// Fonction pour générer les mots-clés pour la recherche
function generateSearchKeywords(prenom, nom, id) {
  return [prenom.toLowerCase(), nom.toLowerCase(), id.toLowerCase()];
}

// Fonction pour mettre à jour les patients avec le champ `searchKeywords`
async function updateSearchKeywords() {
  try {
    // Récupérer tous les patients
    const patientsSnapshot = await getDocs(collection(db, "patients"));

    for (const patientDoc of patientsSnapshot.docs) {
      const patientData = patientDoc.data();

      // Vérifier que les champs `prenom` et `nom` existent
      if (patientData.prenom && patientData.nom) {
        const searchKeywords = generateSearchKeywords(patientData.prenom, patientData.nom, patientData.id);

        // Mettre à jour le document avec le champ `searchKeywords`
        await updateDoc(doc(db, "patients", patientDoc.id), {
          searchKeywords,
        });

        console.log(`Patient ${patientDoc.id} mis à jour avec les mots-clés : ${searchKeywords}`);
      } else {
        console.warn(`Patient ${patientDoc.id} ignoré : prénom ou nom manquant.`);
      }
    }

    console.log("Mise à jour des mots-clés terminée.");
  } catch (error) {
    console.error("Erreur lors de la mise à jour des mots-clés :", error);
  }
}

// Exécuter le script
updateSearchKeywords();
