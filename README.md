#  Jeu d'Aventure Textuel - Swift

Bienvenue dans le jeu d'aventure textuel développé en Swift ! Ce projet vous plonge dans un univers d'exploration, de logique et de réflexion, où chaque salle peut contenir des objets, des énigmes ou des personnages mystérieux.

---

##  Objectif du jeu

Vous incarnez un aventurier explorant un monde fantastique composé de différentes salles. Votre mission est de :
- Explorer les lieux
- Résoudre des énigmes
- Récupérer des objets utiles
- Combiner des objets pour créer de nouveaux outils
- Parler à des personnages qui vous aideront ou vous défieront
- Atteindre la **Salle du Trésor** pour remporter la partie

---

##  Lancer le jeu

1. Assurez-vous d’avoir **Swift installé** sur votre machine.
2. Placez tous les fichiers dans le même dossier :
   - `main.swift`
   - `world.json`
   - `objets.json`
   - `personnages.json`
   - `enigmes.json`
3. Compilez et exécutez avec les commandes suivantes :

```bash
swiftc main.swift -o main
./main
```

---

##  Commandes disponibles

- `nord`, `sud`, `est`, `ouest` : se déplacer
- `prendre` : ramasser un objet
- `inventaire` : voir votre sac
- `jeter` : libérer de l’espace dans l’inventaire
- `combiner` : fusionner deux objets compatibles
- `enigme` : tenter une énigme
- `parler` : discuter avec un personnage
- `aide` : liste de toutes les commandes
- `carte` : voir les salles visitées
- `attendre` : faire passer le temps
- `quetes` : voir vos objectifs en cours
- `quitter` : sauvegarder et quitter

---

##  Astuces

- Certaines salles sont **verrouillées** : il faut posséder l'objet requis pour y entrer.
- Les **PNJ** peuvent donner des objets importants après une énigme.
- Résolvez les énigmes pour obtenir des points et progresser.
- Le jeu se termine lorsque vous atteignez la **Salle du Trésor**.

---

##  Sauvegarde

Un fichier `save.json` est généré automatiquement à la fin de la partie. Il enregistre :
- Le nom du joueur
- Le score
- Les salles visitées
- l’inventaire et la vie restante

---

##  Exemple de parcours pour gagner

```text
start
↓ nord
hall → enigme : abracadabra → parler : cle en argent
↓ ouest
tenebres → parler : cle en or
← est ← hall ← est
bibliotheque → prendre : cle sacree
← ouest ← hall ← sud
salle5 → ouest → salle6 → ouest → salle7
→ enigme : une bougie → ouest → victoire 
```

---


