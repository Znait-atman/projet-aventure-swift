# 🧾 Rapport détaillé - Projet Jeu d'Aventure Textuel en Swift

## 🎯 Objectif du projet
Le projet consiste à développer un jeu d’aventure textuel sur terminal à l’aide du langage Swift. Le joueur incarne un aventurier évoluant dans un univers composé de différentes salles connectées, avec pour mission de :
- Explorer les salles disponibles dans un monde fictif
- Résoudre des énigmes pour progresser
- Ramasser et combiner des objets
- Interagir avec des personnages non-joueurs (PNJ)
- Atteindre la salle finale ("victoire") pour gagner la partie

Ce projet est réalisé dans le cadre de l’unité d’enseignement iOS de Licence 3 Informatique à l’Université Paris 8.

---

## 🧱 Conception et Modélisation

### 📦 Données JSON utilisées
Le jeu repose sur la lecture de plusieurs fichiers JSON représentant les entités suivantes :

- **`world.json`** : liste des salles du jeu. Chaque salle est définie par un identifiant (`id`), un nom (`name`), une description (`description`) et un dictionnaire des sorties (`exits`). Certaines salles peuvent être verrouillées et nécessiter un objet pour y entrer (`locked`, `requiredItem`).

- **`objets.json`** : liste des objets présents dans l’univers du jeu. Chaque objet comprend un nom, une description, une localisation (`location`), et des champs optionnels pour la combinaison (`combinableWith`, `result`).

- **`personnages.json`** : liste des personnages (PNJ). Chaque personnage a un nom, un message de dialogue, une salle associée (`roomId`), et des options pour offrir un objet ou exiger une énigme résolue avant de parler.

- **`enigmes.json`** : liste des énigmes. Chaque énigme contient une question, une réponse attendue et une salle (`roomId`). Certaines énigmes peuvent être fatales si mal répondues (`deadly`).

- **`save.json`** : sauvegarde automatique contenant :
  - Le nom du joueur (`player`)
  - Le score final (`score`)
  - La liste des salles visitées (`visited`)
  - La vie restante (`vie`) *(optionnel)*
  - L'inventaire final (`inventory`) *(optionnel)*

### 🔧 Structures Swift (Codable)
Les entités JSON sont modélisées en Swift à l’aide de `struct` conformes au protocole `Codable` :
- `Room`
- `ObjectItem`
- `Puzzle`
- `CharacterNPC`

La logique principale est contenue dans la classe `Game`, qui gère :
- Le déroulement du jeu (boucle principale `loop()`)
- Les interactions (`parler`, `prendre`, `enigme`, `combiner`, etc.)
- Le système de navigation (`move(direction:)`)
- La sauvegarde (`saveGame`) et résumé final (`showSummary()`)

---

## ⚙️ Fonctionnalités principales

### 📌 Commandes implémentées dans le jeu :
- **`nord`, `sud`, `est`, `ouest`** : permet de se déplacer selon les sorties de la salle actuelle.
- **`prendre`** : ramasse un objet présent dans la salle (si inventaire non plein).
- **`inventaire`** : affiche les objets possédés.
- **`jeter`** : permet de libérer de l’espace dans l’inventaire.
- **`combiner`** : fusionne deux objets compatibles en un nouvel objet.
- **`parler`** : interagit avec un PNJ présent dans la salle.
- **`enigme`** : déclenche une énigme si disponible.
- **`aide`** : affiche toutes les commandes disponibles.
- **`carte`** : affiche une carte textuelle des salles visitées.
- **`attendre`** : simule le passage du temps dans le jeu.
- **`quetes`** : affiche la liste des quêtes en cours.
- **`quitter`** : sauvegarde et termine la partie.

### 🧮 Sauvegarde JSON générée automatiquement :
- `save.json` contient le nom du joueur, son score, sa progression et son inventaire.
- Le fichier est écrasé à chaque fin de partie, une seule sauvegarde est conservée.

---

## ✨ Fonctionnalités avancées

- **Carte textuelle** : permet de visualiser la progression de l’exploration (avec `[X]` pour la salle actuelle, `[ ]` pour les salles visitées, et `?` pour les inconnues).

- **Système de combinaisons** : permet d’obtenir un nouvel objet à partir de deux objets compatibles (définis via `combinableWith` et `result`).

- **Énigmes fatales** : certaines énigmes peuvent provoquer une mort immédiate (`deadly: true`) si la mauvaise réponse est donnée.

- **Inventaire limité** : l’inventaire est plafonné à 3 objets. Il faut parfois jeter ou combiner pour ramasser d’autres objets.

---

## 🧪 Scénario de victoire

Pour gagner le jeu, le joueur doit :
1. Aller au nord de la salle de départ pour accéder au Hall.
2. Résoudre l’énigme du Hall (`abracadabra`) et parler au Sage du Nord pour obtenir la `cle en argent`.
3. Aller à l’ouest vers la Salle des Ténèbres et parler au voleur pour obtenir la `cle en or`.
4. Aller à l’est pour entrer dans la Bibliothèque scellée (avec la `cle en or`) et prendre la `cle sacree`.
5. Depuis la Salle de départ, descendre vers :
   - `salle5` (Jardin Enchanté)
   - puis `salle6` (Tour Sombre)
   - puis `salle7` (Crypte Silencieuse)
   - résoudre l’énigme : "une bougie"
   - aller à l’ouest vers la salle finale `victoire`.

---

## 🚧 Difficultés rencontrées

- Assurer la cohérence des sorties (`exits`) entre les salles
- Résolution d’erreurs de compilation lors de la manipulation des fichiers JSON
- Détection et correction des erreurs d’accent ou de casse dans les noms d’objets
- Sauvegarde qui écrasait les anciennes données, nécessitant une gestion plus rigoureuse
- Compréhension et intégration du protocole `Codable` pour décode/décode les données correctement

---

## ✅ Conclusion

Ce projet m’a permis d’appliquer les connaissances en programmation orientée objet et en manipulation de fichiers JSON dans un cadre ludique. Il m’a appris à structurer un moteur de jeu textuel, gérer des entrées utilisateur, implémenter une boucle de jeu, et organiser la progression du joueur à travers un univers cohérent.

Ce travail m’a également sensibilisée à l’importance de la gestion des données, de la sauvegarde, et de l’expérience utilisateur via la diversité des commandes disponibles.

> Projet réalisé par : **NAIT ATMAN ZAHRA**  
> Licence 3 Informatique — Université Paris 8

