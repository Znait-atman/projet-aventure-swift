 // MARK: 

import Foundation

// Structures
struct Room: Codable {
    let id: String
    let name: String
    let description: String
    let exits: [String: String]
    var locked: Bool?
    var requiredItem: String?
}
struct ObjectItem: Codable {
    let name: String
    let description: String
    var location: String
    var combinableWith: String?
    var result: String?
}

struct Puzzle: Codable {
    let question: String
    let answer: String
    let roomId: String
    var deadly: Bool?
}

struct CharacterNPC: Codable {
    let name: String
    let message: String
    let roomId: String
    var isFriendly: Bool?
    var givesItem: String?
    var requirePuzzle: String?
}

// MARK: - Classe principale du jeu
class Game {
    var rooms: [Room]
    var objects: [ObjectItem]
    var puzzles: [Puzzle]
    var characters: [CharacterNPC]
    var currentRoom: Room
    var inventory: [ObjectItem] = []
    var playerName: String = "Aventurier"
    var score: Int = 0
    var vie: Int = 100
    var maxInventory: Int = 3
    var isGameOver = false
    var visitedRooms: Set<String> = []
    var solvedPuzzles: Set<String> = []
    var timeCounter: Int = 0
    var quests: [String] = ["Trouver la clé en argent", "Parler à l’ancien mage"]

    init(rooms: [Room], objects: [ObjectItem], puzzles: [Puzzle], characters: [CharacterNPC]) {
        self.rooms = rooms
        self.objects = objects
        self.puzzles = puzzles
        self.characters = characters
        self.currentRoom = rooms.first { $0.id == "start" } ?? rooms[0]
    }

    // MARK: - Lancement du jeu
    func start() {
        print("Bienvenue dans le donjon mystique ! \n Quel est votre nom ?" )
        if let name = readLine(), !name.isEmpty {
            playerName = name
        }

        print("Bonjour \(playerName) ! L'aventure commence...\n")
        loop()
    }

    // MARK: - Boucle principale
    func loop() {
        while !isGameOver {
            describeCurrentRoom()

            if !visitedRooms.contains(currentRoom.id) {
                visitedRooms.insert(currentRoom.id)
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

            checkVictory()
        }
    }

    // MARK: - Description de la salle
    func describeCurrentRoom() {
        print("\n========================================\(currentRoom.name) ==============================================")
        print("Sorties : \(currentRoom.exits.keys.joined(separator: ", "))")

        let items = objects.filter { $0.location == currentRoom.id }
        if !items.isEmpty {
            print("Objets ici : " + items.map { $0.name }.joined(separator: ", "))
        }

        let people = characters.filter { $0.roomId == currentRoom.id }
        if !people.isEmpty {
            print("Personnes ici : " + people.map { $0.name }.joined(separator: ", "))
        }
    }

    // MARK: - Déplacement
    func move(direction: String) {
        guard let nextId = currentRoom.exits[direction],
              let nextRoom = rooms.first(where: { $0.id == nextId }) else {
            print("Vous ne pouvez pas aller par là.")
            return
        }

        if nextRoom.locked == true {
            if let key = nextRoom.requiredItem, !inventory.contains(where: { $0.name == key }) {
                print("Cette salle est verrouillée. Il vous faut un objet spécifique.")
                return
            }
        }

        currentRoom = nextRoom
    }

    // MARK: - Inventaire
    func showInventory() {
        if inventory.isEmpty {
            print("Votre inventaire est vide.")
        } else {
            print("Inventaire : " + inventory.map { $0.name }.joined(separator: ", "))
        }
    }

    // MARK: - Prendre objet 
    func takeObject() {
    print("Quel objet voulez-vous prendre ?")
    if let input = readLine() {
        for i in 0..<objects.count {
            if objects[i].location == currentRoom.id && objects[i].name == input {
                if inventory.count >= maxInventory {
                    print("Inventaire plein. Vous ne pouvez pas prendre plus d'objets.")
                    return
                }
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
    func combineObjects() {
        print("Quels objets voulez-vous combiner ? (séparés par une virgule)")
        if let input = readLine()?.lowercased() {
            let parts = input.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            if parts.count == 2,
               let obj1 = inventory.first(where: { $0.name.lowercased() == parts[0] }),
               let obj2 = inventory.first(where: { $0.name.lowercased() == parts[1] }),
               obj1.combinableWith == obj2.name {
                let newObj = ObjectItem(name: obj1.result ?? "Objet combiné", description: "Objet obtenu par combinaison", location: "inventaire")
                inventory.removeAll { $0.name == obj1.name || $0.name == obj2.name }
                inventory.append(newObj)
                print("Vous avez créé : \(newObj.name) !")
            } else {
                print("Ces objets ne peuvent pas être combinés.")
            }
        }
    }

    // MARK: - Parler
    func talkToCharacter() {
        let people = characters.filter { $0.roomId == currentRoom.id }
        if people.isEmpty {
            print("Il n'y a personne ici.")
            return
        }

        for person in people {
            if let required = person.requirePuzzle, !solvedPuzzles.contains(required) {
                print("\(person.name): Je ne peux rien te dire tant que tu n'as pas résolu une énigme.")
                continue
            }

            print("\(person.name): \(person.message)")
            if let item = person.givesItem, !inventory.contains(where: { $0.name == item }) {
                print("Vous recevez : \(item)")
                let obj = ObjectItem(name: item, description: "Objet offert par \(person.name)", location: "inventaire")
                inventory.append(obj)
                score += 5
            }
        }
    }

    // MARK: - Énigmes
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
                print("Mauvaise réponse.")
                vie -= 10
                print("Vous perdez 10 points de vie. Vie restante : \(vie)")
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
    func showMap() {
        print("\nCarte explorée :")
        for room in rooms {
            let marker = (room.id == currentRoom.id) ? "[X]" : (visitedRooms.contains(room.id) ? "[ ]" : " ? ")
            print("\(marker) \(room.name)")
        }
    }

    // MARK: - Attendre
    func waitTurn() {
        timeCounter += 1
        print("Une heure passe... Vous avez attendu \(timeCounter) heure(s).")
    }
    
    //MARK: -Jeter
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
    func showQuests() {
        print("Quêtes en cours :")
        for quest in quests {
            print("- \(quest)")
        }
    }

    // MARK: - Sauvegarde
    func saveGame() {
        let saveData: [String: Any] = [
            "player": playerName,
            "score": score,
            "visited": Array(visitedRooms),
            "vie": vie,
            "inventory": inventory.map { $0.name }
        ]
        let url = URL(fileURLWithPath: "save.json")
        if let data = try? JSONSerialization.data(withJSONObject: saveData, options: .prettyPrinted) {
            try? data.write(to: url)
        }
    }

    // MARK: - Chargement
    func loadGame() {
        let url = URL(fileURLWithPath: "save.json")
        guard let data = try? Data(contentsOf: url),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            print("Échec du chargement de la sauvegarde.")
            return
        }

        playerName = dict["player"] as? String ?? playerName
        score = dict["score"] as? Int ?? 0
        vie = dict["vie"] as? Int ?? 100
        visitedRooms = Set((dict["visited"] as? [String]) ?? [])
    }

    // MARK: - Fin de jeu
    func showSummary() {
        print("\n=== Fin de l'aventure ===")
        print("Merci d'avoir joué, \(playerName) !")
        print("Salles visitées : \(visitedRooms.count)")
        print("Énigmes résolues : \(solvedPuzzles.count)")
        print("Objets ramassés : \(inventory.count)")
        print("Score final : \(score)")
    }

    func checkVictory() {
        if currentRoom.id == "victoire" {
            print("\nFélicitations, \(playerName) ! Vous avez atteint la salle finale.")
            showSummary()
            saveGame()
            isGameOver = true
        }
    }
}

// MARK: - Chargement des données
func loadRooms() -> [Room] {
    let url = URL(fileURLWithPath: "world.json")
    if let data = try? Data(contentsOf: url),
       let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
       let jsonData = try? JSONSerialization.data(withJSONObject: dict["rooms"] ?? []) {
        return (try? JSONDecoder().decode([Room].self, from: jsonData)) ?? []
    }
    return []
}

func loadObjects() -> [ObjectItem] {
    let url = URL(fileURLWithPath: "objets.json")
    if let data = try? Data(contentsOf: url) {
        return (try? JSONDecoder().decode([ObjectItem].self, from: data)) ?? []
    }
    return []
}

func loadPuzzles() -> [Puzzle] {
    let url = URL(fileURLWithPath: "enigmes.json")
    if let data = try? Data(contentsOf: url) {
        return (try? JSONDecoder().decode([Puzzle].self, from: data)) ?? []
    }
    return []
}

func loadCharacters() -> [CharacterNPC] {
    let url = URL(fileURLWithPath: "personnages.json")
    if let data = try? Data(contentsOf: url) {
        return (try? JSONDecoder().decode([CharacterNPC].self, from: data)) ?? []
    }
    return []
}

// MARK: - Lancement du jeu
let rooms = loadRooms()
let objects = loadObjects()
let puzzles = loadPuzzles()
let characters = loadCharacters()

if !rooms.isEmpty {
    let game = Game(rooms: rooms, objects: objects, puzzles: puzzles, characters: characters)
    game.start()
} else {
    print("Erreur lors du chargement des données.")
}
