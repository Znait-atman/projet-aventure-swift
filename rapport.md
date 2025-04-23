# 🧾 Rapport - Projet Jeu d'Aventure Textuel en Swift

## 🎯 Objectif du projet
Développer un jeu d’aventure textuel en Swift, sur console, dans lequel le joueur explore différentes salles, collecte des objets, résout des énigmes et atteint une salle finale pour gagner.

---

## 🧱 Conception et Modélisation

### 📦 Modèle de données (JSON)
- `world.json` : contient les salles du jeu (id, description, sorties).
- `objets.json` : objets présents dans les salles.
- `personnages.json` : PNJ pouvant donner des objets ou des informations.
- `enigmes.json` : énigmes à résoudre dans certaines salles.
- `save.json` : sauvegarde du nom du joueur, score et salles visitées.

### 🔧 Classes et Structs
Chaque élément du jeu est représenté par une `struct` Swift (codable) :
- `Room`, `ObjectItem`, `Puzzle`, `CharacterNPC`, `World`
- La classe `Game` gère la boucle de jeu, les actions du joueur, les interactions, la sauvegarde, etc.

---

## ⚙️ Fonctionnalités principales
- Navigation entre les salles (nord, sud, est, ouest)
- Résolution d’énigmes (avec possibilité d’échec fatal)
- Collecte d’objets avec gestion d’inventaire limité
- Interaction avec des personnages
- Sauvegarde automatique dans `save.json`
- Résumé final avec score, objets, énigmes et progression

---

## ✨ Fonctionnalités avancées
- **Commande `carte`** : affiche les salles visitées dans une carte textuelle.
- **Commande `attendre`** : permet de simuler le passage du temps.

---

## 🚧 Difficultés rencontrées
- Connexions cohérentes entre les salles (exits croisés)
- Gestion d’objets dans les salles et inventaire limité
- Mise en place d’un système de sauvegarde lisible en JSON
- Traitement des entrées utilisateurs avec validation propre

---

## ✅ Conclusion
Ce projet m’a permis de mieux comprendre la gestion des fichiers JSON, la modélisation orientée objet, et la logique d’un moteur de jeu textuel. Il m’a aussi permis d’approfondir Swift dans un cadre concret et ludique.

> Projet réalisé par [Ton Nom] - Licence 3 Informatique, Université Paris 8