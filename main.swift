 // MARK: 
// Importation du module pour la gestion de fichiers, JSON, etc.
import Foundation

// MARK: - Définition des structures de données 

// Représente une salle dans le jeu
struct Room: Codable {
    let id: String                  // Identifiant unique de la salle
    let name: String               // Nom affiché
    let description: String        // Description textuelle
    let exits: [String: String]    // Directions disponibles (ex: "nord": "id_salle_2")
    var locked: Bool?              // Si la salle est verrouillée
    var requiredItem: String?      // Objet nécessaire pour y accéder
}

// Représente un objet dans le jeu
struct ObjectItem: Codable {
    let name: String
    let description: String
    var location: String            // Salle actuelle ou "inventaire"
    var combinableWith: String?     // Nom de l’objet compatible pour combinaison
    var result: String?             // Nom du résultat si combiné
}

// Énigme à résoudre dans une salle
struct Puzzle: Codable {
    let question: String
    let answer: String
    let roomId: String
    var deadly: Bool?               // Si l’énigme peut tuer le joueur
}

// PNJ (personnage non joueur) dans le jeu
struct CharacterNPC: Codable {
    let name: String
    let message: String
    let roomId: String
    var isFriendly: Bool?          // Peut être utile pour des futures améliorations
    var givesItem: String?         // Objet donné si interaction réussie
    var requirePuzzle: String?     // Nécessite de résoudre une énigme
}

// MARK: - Classe principale du jeu, contient toute la logique
class Game {
    // État du jeu : données chargées, joueur, score, etc.
    var rooms: [Room]
    var objects: [ObjectItem]
    var puzzles: [Puzzle]
    var characters: [CharacterNPC]

    var currentRoom: Room                  // Salle actuelle du joueur
    var inventory: [ObjectItem] = []       // Objets du joueur
    var playerName: String = "Aventurier"  // Nom du joueur
    var score: Int = 0
    var vie: Int = 100
    var maxInventory: Int = 3              // Capacité max du sac
    var isGameOver = false
    var visitedRooms: Set<String> = []     // Pour la carte
    var solvedPuzzles: Set<String> = []    // Pour éviter de refaire les énigmes
    var timeCounter: Int = 0               // Pour "attendre"
    var quests: [String] = ["Trouver la clé en argent", "Parler à l’ancien mage"] // Objectifs

    // Initialisation avec les données JSON
    init(rooms: [Room], objects: [ObjectItem], puzzles: [Puzzle], characters: [CharacterNPC]) {
        self.rooms = rooms
        self.objects = objects
        self.puzzles = puzzles
        self.characters = characters
        self.currentRoom = rooms.first { $0.id == "start" } ?? rooms[0] // Fallback au premier si pas de "start"
    }

    // MARK: - Lancement du jeu
    func start() {
        print("Bienvenue dans le donjon mystique ! \n Quel est votre nom ?" )
        if let name = readLine(), !name.isEmpty {
            playerName = name
        }

        print("Bonjour \(playerName) ! L'aventure commence...\n")
        loop() // Lancement de la boucle de jeu
    }

    // MARK: - Boucle principale
    func loop() {
        while !isGameOver {
            describeCurrentRoom() // Affiche les infos de la salle
            
            // Si la salle est visitée pour la première fois
            if !visitedRooms.contains(currentRoom.id) {
                visitedRooms.insert(currentRoom.id)
                // Une chance sur 5 de tomber sur un piège
                if Int.random(in: 1...5) == 1 {
                    print("\n BOUM ! Un piège vous fait perdre 5 points.")
                    score -= 5
                }
            }

            print("\nQue voulez-vous faire ? \n(nord/sud/est/ouest/prendre/jeter/inventaire/enigme/parler/aide/carte/attendre/combiner/quetes/quitter)")
            print("======================================================================================================")
            guard let input = readLine()?.lowercased(), !input.isEmpty else {
                print("Commande vide. Réessayez.")
                continue
            }
            // Dispatch vers la bonne fonction selon la commande saisie
            switch input {
            case "nord": move(direction: "nord")
            case "sud": move(direction: "sud")
            case "est": move(direction: "est")
            case "ouest": move(direction: "ouest")
            case "prendre": takeObject()
            case "jeter": dropObject()
            case "inventaire": showInventory()
            case "enigme": solvePuzzle()
            case "parler": talkToCharacter()
            case "aide": showHelp()
            case "carte": showMap()
            case "attendre": waitTurn()
            case "combiner": combineObjects()
            case "quetes": showQuests()
            case "quitter": saveGame(); showSummary(); isGameOver = true
            default:
                print("Commande inconnue. Tapez 'aide' pour voir les options.")
            }

            checkVictory() // Vérifie si on a gagné
        }
    }

    // MARK: - Description de la salle
    func describeCurrentRoom() {
    print("\n==== \(currentRoom.name) ====")  // Titre de la salle
    print("Sorties : \(currentRoom.exits.keys.joined(separator: ", "))")  // Liste des directions disponibles

    // Filtre les objets qui sont dans la salle actuelle
    let items = objects.filter { $0.location == currentRoom.id }
    if !items.isEmpty {
        // Affiche les noms des objets présents
        print("Objets ici : " + items.map { $0.name }.joined(separator: ", "))
    }

    // Filtre les personnages (PNJ) qui se trouvent dans la salle actuelle
    let people = characters.filter { $0.roomId == currentRoom.id }
    if !people.isEmpty {
        // Affiche les noms des personnages présents
        print("Personnes ici : " + people.map { $0.name }.joined(separator: ", "))
    }
    }

    // MARK: - Déplacement
/// Permet au joueur de se déplacer dans une direction (nord, sud, est, ouest)
/// Vérifie si la salle est accessible et déverrouillée si nécessaire.
func move(direction: String) {
    // Cherche l'ID de la salle vers laquelle aller selon la direction
    guard let nextId = currentRoom.exits[direction],
          let nextRoom = rooms.first(where: { $0.id == nextId }) else {
        print("Vous ne pouvez pas aller par là.")
        return
    }

    // Vérifie si la salle est verrouillée et si un objet est nécessaire
    if nextRoom.locked == true {
        if let key = nextRoom.requiredItem, !inventory.contains(where: { $0.name == key }) {
            print("Cette salle est verrouillée. Il vous faut un objet spécifique.")
            return
        }
    }

    // Déplacement effectif dans la salle suivante
    currentRoom = nextRoom
}

// MARK: - Inventaire
/// Affiche les objets actuellement dans l'inventaire du joueur.
func showInventory() {
    if inventory.isEmpty {
        print("Votre inventaire est vide.")
    } else {
        print("Inventaire : " + inventory.map { $0.name }.joined(separator: ", "))
    }
}

// MARK: - Prendre objet
/// Permet de ramasser un objet présent dans la salle actuelle, s’il reste de la place dans l'inventaire.
func takeObject() {
    print("Quel objet voulez-vous prendre ?")
    if let input = readLine() {
        for i in 0..<objects.count {
            if objects[i].location == currentRoom.id && objects[i].name == input {
                if inventory.count >= maxInventory {
                    print("Inventaire plein. Vous ne pouvez pas prendre plus d'objets.")
                    return
                }
                // Met à jour l'objet comme étant dans l'inventaire
                objects[i].location = "inventaire"
                inventory.append(objects[i])
                print("Vous avez pris \(objects[i].name).")
                score += 5
                return
            }
        }
        print("Objet introuvable ici.")
    }
}

// MARK: - Combinaison
/// Permet de combiner deux objets compatibles pour en créer un nouveau.
func combineObjects() {
    print("Quels objets voulez-vous combiner ? (séparés par une virgule)")
    if let input = readLine()?.lowercased() {
        let parts = input.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        if parts.count == 2,
           let obj1 = inventory.first(where: { $0.name.lowercased() == parts[0] }),
           let obj2 = inventory.first(where: { $0.name.lowercased() == parts[1] }),
           obj1.combinableWith == obj2.name {
            // Crée un nouvel objet combiné
            let newObj = ObjectItem(name: obj1.result ?? "Objet combiné", description: "Objet obtenu par combinaison", location: "inventaire")
            // Supprime les deux objets originaux
            inventory.removeAll { $0.name == obj1.name || $0.name == obj2.name }
            // Ajoute le nouvel objet
            inventory.append(newObj)
            print("Vous avez créé : \(newObj.name) !")
        } else {
            print("Ces objets ne peuvent pas être combinés.")
        }
    }
}

// MARK: - Parler
/// Permet d’interagir avec les personnages non-joueurs (PNJ) présents dans la salle.
func talkToCharacter() {
    let people = characters.filter { $0.roomId == currentRoom.id }
    if people.isEmpty {
        print("Il n'y a personne ici.")
        return
    }

    for person in people {
        // Vérifie si une énigme doit être résolue avant de parler
        if let required = person.requirePuzzle, !solvedPuzzles.contains(required) {
            print("\(person.name): Je ne peux rien te dire tant que tu n'as pas résolu une énigme.")
            continue
        }

        print("\(person.name): \(person.message)")

        // Vérifie si le personnage donne un objet
        if let item = person.givesItem, !inventory.contains(where: { $0.name == item }) {
            print("Vous recevez : \(item)")
            let obj = ObjectItem(name: item, description: "Objet offert par \(person.name)", location: "inventaire")
            inventory.append(obj)
            score += 5
        }
    }
}

// MARK: - Énigmes
/// Permet de tenter de résoudre une ou plusieurs énigmes présentes dans la salle.
func solvePuzzle() {
    let found = puzzles.filter { $0.roomId == currentRoom.id }
    if found.isEmpty {
        print("Il n'y a pas d'énigme ici.")
        return
    }

    for puzzle in found {
        print("Énigme : \(puzzle.question)")
        if let answer = readLine()?.lowercased(), answer == puzzle.answer.lowercased() {
            print("Bonne réponse !")
            score += 10
            solvedPuzzles.insert(puzzle.question)
        } else {
            // Mauvaise réponse
            print("Mauvaise réponse.")
            vie -= 10
            print("Vous perdez 10 points de vie. Vie restante : \(vie)")

            // Vérifie si le joueur meurt ou si l’énigme est fatale
            if vie <= 0 {
                print("Vous avez succombé à vos blessures...")
                isGameOver = true
            }
            if puzzle.deadly == true {
                print("L'énigme était piégée. Vous avez perdu.")
                isGameOver = true
            }
        }
    }
}

// MARK: - Carte
/// Affiche une représentation des salles visitées et la salle actuelle.
func showMap() {
    print("\nCarte explorée :")
    for room in rooms {
        let marker = (room.id == currentRoom.id) ? "[X]" : (visitedRooms.contains(room.id) ? "[ ]" : " ? ")
        print("\(marker) \(room.name)")
    }
}

// MARK: - Attendre
/// Passe un tour de jeu, simule le temps qui passe.
func waitTurn() {
    timeCounter += 1
    print("Une heure passe... Vous avez attendu \(timeCounter) heure(s).")
}

// MARK: - Jeter
/// Permet au joueur de retirer un objet de son inventaire.
func dropObject() {
    if inventory.isEmpty {
        print("Vous n'avez rien à jeter.")
        return
    }

    print("Quel objet voulez-vous jeter ?")
    if let input = readLine()?.lowercased(),
       let index = inventory.firstIndex(where: { $0.name.lowercased() == input }) {
        let dropped = inventory.remove(at: index)
        print("Vous avez jeté : \(dropped.name)")
    } else {
        print("Objet non trouvé dans votre inventaire.")
    }
    }


    //MARK: - aide
    /// Affiche les commandes disponibles pour aider le joueur.
    func showHelp() {
    print("""
Commandes disponibles :
n/s/e/o - se déplacer
p - prendre un objet
i - voir votre inventaire
enigme - tenter une énigme
parler - discuter avec un personnage
carte - voir la carte
attendre - passer du temps
combiner - combiner deux objets
jeter - jeter un objet de votre inventaire
quetes - consulter vos quêtes
quitter - sauvegarder et quitter
""")
}

    // MARK: - Quêtes
/// Affiche la liste des quêtes actuelles du joueur.
func showQuests() {
    print("Quêtes en cours :")
    for quest in quests {
        print("- \(quest)") // Affiche chaque quête sur une nouvelle ligne
    }
}

// MARK: - Sauvegarde
/// Sauvegarde l'état du jeu dans un fichier JSON local.
func saveGame() {
    let saveData: [String: Any] = [
        "player": playerName, // Sauvegarde le nom du joueur
        "score": score, // Sauvegarde le score
        "visited": Array(visitedRooms), // Convertit le set en tableau pour la sérialisation
        "vie": vie, // Sauvegarde les points de vie
        "inventory": inventory.map { $0.name } // Sauvegarde uniquement les noms des objets de l’inventaire
    ]
    let url = URL(fileURLWithPath: "save.json") // Chemin vers le fichier de sauvegarde

    // Convertit les données en JSON et les écrit dans le fichier
    if let data = try? JSONSerialization.data(withJSONObject: saveData, options: .prettyPrinted) {
        try? data.write(to: url)
    }
}

// MARK: - Chargement
/// Charge les données sauvegardées du fichier JSON.
func loadGame() {
    let url = URL(fileURLWithPath: "save.json") // Fichier source

    // Tente de lire et parser le fichier JSON
    guard let data = try? Data(contentsOf: url),
          let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
        print("Échec du chargement de la sauvegarde.")
        return
    }

    // Recharge les valeurs sauvegardées
    playerName = dict["player"] as? String ?? playerName
    score = dict["score"] as? Int ?? 0
    vie = dict["vie"] as? Int ?? 100
    visitedRooms = Set((dict["visited"] as? [String]) ?? [])
}

// MARK: - Fin de jeu
/// Affiche un résumé complet de la partie à la fin du jeu.
func showSummary() {
    print("\n=== Fin de l'aventure ===")
    print("Merci d'avoir joué, \(playerName) !")
    print("Salles visitées : \(visitedRooms.count)") // Combien de salles visitées
    print("Énigmes résolues : \(solvedPuzzles.count)") // Combien d’énigmes réussies
    print("Objets ramassés : \(inventory.count)") // Combien d’objets dans l’inventaire
    print("Score final : \(score)") // Score global du joueur
}

/// Vérifie si le joueur a atteint la salle finale et termine la partie si oui.
func checkVictory() {
    if currentRoom.id == "victoire" {
        print("\nFélicitations, \(playerName) ! Vous avez atteint la salle finale.")
        showSummary() // Affiche le résumé de la partie
        saveGame() // Sauvegarde avant de quitter
        isGameOver = true // Marque la fin du jeu
    }
}

// MARK: - Chargement des données
/// Charge les salles depuis le fichier `world.json`.
func loadRooms() -> [Room] {
    let url = URL(fileURLWithPath: "world.json")
    if let data = try? Data(contentsOf: url),
       let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
       let jsonData = try? JSONSerialization.data(withJSONObject: dict["rooms"] ?? []) {
        return (try? JSONDecoder().decode([Room].self, from: jsonData)) ?? []
    }
    return []
}

/// Charge les objets du jeu depuis `objets.json`.
func loadObjects() -> [ObjectItem] {
    let url = URL(fileURLWithPath: "objets.json")
    if let data = try? Data(contentsOf: url) {
        return (try? JSONDecoder().decode([ObjectItem].self, from: data)) ?? []
    }
    return []
}

/// Charge les énigmes du jeu depuis `enigmes.json`.
func loadPuzzles() -> [Puzzle] {
    let url = URL(fileURLWithPath: "enigmes.json")
    if let data = try? Data(contentsOf: url) {
        return (try? JSONDecoder().decode([Puzzle].self, from: data)) ?? []
    }
    return []
}

/// Charge les personnages (PNJ) depuis `personnages.json`.
func loadCharacters() -> [CharacterNPC] {
    let url = URL(fileURLWithPath: "personnages.json")
    if let data = try? Data(contentsOf: url) {
        return (try? JSONDecoder().decode([CharacterNPC].self, from: data)) ?? []
    }
    return []
}

// MARK: - Lancement du jeu
/// Point d'entrée principal : charge les données et démarre le jeu.
let rooms = loadRooms() // Charge les salles
let objects = loadObjects() // Charge les objets
let puzzles = loadPuzzles() // Charge les énigmes
let characters = loadCharacters() // Charge les PNJ

// Vérifie que les données sont chargées avant de démarrer le jeu
if !rooms.isEmpty {
    let game = Game(rooms: rooms, objects: objects, puzzles: puzzles, characters: characters)
    game.start() // Lance le jeu
} else {
    print("Erreur lors du chargement des données.")
}

