<!-- carte:en-tete:debut — fabriqué depuis projet.yml par sophos/outils/carte.mjs ; ne pas modifier à la main -->
# imi

<picture>
  <source media="(prefers-color-scheme: dark)" srcset=".github/carte/banniere-sombre.svg">
  <img alt="imi : Corriger et traduire un texte sans quitter son application." src=".github/carte/banniere-claire.svg" width="100%">
</picture>

**Raison d'être** Reproduire Graker pour un usage personnel sur Mac et iPhone, avec ses clés API et sans service intermédiaire.

**État** actif · **Sorte** application Apple personnelle
<!-- carte:en-tete:fin -->

## Ce que c'est

Graker Local reproduit [Graker](https://graker.fehey.com/) pour un usage personnel sur Mac et iPhone, avec les méthodes [Sophos](https://antoineberjoan.github.io/sophos/) : correction, reformulation, traduction et affinage depuis l'application où l'on écrit, avec explication et copie ou remplacement (macOS). Interface en français ; fournisseurs Gemini, DeepSeek et compatible OpenAI ; clés dans le trousseau, pas de service intermédiaire. Le [guide propriétaire](docs/fondation.md) pose le périmètre, les principes et les [décisions](docs/decisions/) datées (marque, jetons, plateformes).

Application native SwiftUI et adaptateurs système (macOS : panneau, raccourcis, sélection ; iOS : éditeur intégré). `Resources/Brand/tokens.json` alimente l'interface ; `Design/` tient la marque validée. Dix résultats en mémoire à la fermeture. Réimplémentation sans affiliation ; comportements à valider sur un Mac. Voir le [journal public](https://graker.fehey.com/changelog) et la [décision de fondation](docs/decisions/2026-11-07-foundation.md) pour le détail des choix.

## Démarrer

Mac sous macOS 15 ou plus, Xcode 16 ou plus, Python 3 et Node.js pour les
vérifications et les fichiers générés. Aucune dépendance Swift externe.

Le workflow GitHub produit aussi `Graker-Local-macOS.zip`, contenant une `.app`
signée localement (ad hoc). Le runner actuel utilise Apple Silicon ; cette
archive vise donc les Mac Apple Silicon. Sur Intel, le script ci-dessous
construit l'application pour le Mac qui l'exécute.

```sh
python3 Scripts/check-foundation.py
swift test
bash Scripts/build-app.sh
open "dist/Graker Local.app"
```

Pour essayer l'application sans Xcode, `bash Scripts/download-app.sh` télécharge la
dernière construction réussie de la branche principale. Il demande GitHub CLI
(`brew install gh`, puis `gh auth login`) et ouvre le dossier de l'application.
Le parcours de test sur un Mac est dans [Documentation/ManualTests.md](Documentation/ManualTests.md).

Ouvrir aussi `Package.swift` dans Xcode pour développer. Pour l'usage quotidien,
lancer le paquet `.app` construit, qui garde un identifiant stable pour le
trousseau et les permissions. Une signature ad hoc locale ne vaut ni signature
Developer ID ni notarisation ; une reconstruction peut demander de réautoriser
l'application dans les réglages macOS.

Choisir le fournisseur et le modèle dans Réglages → Fournisseur IA. Le bouton
« Valider et enregistrer » envoie une requête de test au fournisseur affiché.
Le menu du fournisseur, dans la barre d'outils du panneau, passe ensuite d'un
fournisseur à l'autre. Chaque fournisseur garde son adresse et son modèle.
Les frais éventuels sont ceux de son API. L'application ne demande pas de clé
dans le chat et ne dispose d'aucune clé partagée.

La correction de la sélection utilise ⇧⌘G ; la reformulation utilise ⇧⌘R ;
la traduction utilise ⇧⌘T. Les raccourcis sont modifiables et suivent la
disposition du clavier. Un raccourci global prend la place du même raccourci
dans les autres apps : ⇧⌘R recharge aussi une page dans Chrome, par exemple.
Dans le panneau, Retour lance le traitement, comme dans Graker ; ⇧Retour va à
la ligne. Un collage dans la saisie lance aussi le traitement, car un texte collé
est souvent une phrase complète. Taper à la main ne lance jamais rien. Le bouton
« Coller et corriger » (ou reformuler, ou traduire) colle et lance. Les actions sur une sélection demandent
l'autorisation Accessibilité de macOS. La saisie manuelle fonctionne sans elle.
Le remplacement refuse une sélection qui a changé ; Copier reste disponible.

Jetons : `node <sophos>/outils/jetons.mjs Resources/Brand/tokens.json` (voir `controler.sh`). Carte : `node <sophos>/outils/carte.mjs --verifier`.

Pour exporter le dépôt et le reprendre dans une autre session : [guide de reprise](docs/guide-reprise.md).

## Organisation du dépôt

```text
Resources/Brand/tokens.json          source unique des jetons (DTCG) ; sorties fabriquées
Design/                              jetons CSS, icônes vectorielles
Sources/GrakerCore/                    noyau pur : contrats, requêtes, SSE, révisions
Sources/GrakerDesign/                  rôles SwiftUI fabriqués et pont Tokens
Sources/GrakerUI/                      vues SwiftUI et EditorModel partagé
Sources/GrakerPlatform/                trousseau, préférences, client réseau
Sources/GrakerMac/                     coquille macOS (AppKit) et exécutable menu bar
Sources/GrakerIOS/                     éditeur SwiftPM (hors bundle)
Sources/GrakerKeyboard/                logique clavier iOS
ios/                                   Graker.xcodeproj (app + extension clavier)
Tests/                                 GrakerCoreTests et GrakerPlatformTests
scripts/ et controler.sh               cliquets Sophos et lanceur unique
docs/                                  fondation, lexique, décisions datées
.github/carte/                         bannières fabriquées par carte.mjs
.github/workflows/                     contrôles Sophos et preuve macOS (écart public)
```

Cette carte fixe les emplacements ; un dossier ne naît qu'avec son premier fichier.
Le noyau ne dépend pas de l'application. Les adaptateurs importent le noyau.
L'état observable orchestre les adaptateurs ; les vues lisent cet état et des rôles
de tokens. Le fichier Swift de tokens est généré, jamais maintenu à la main.
Les règles de noms vivent dans AGENTS.md ; les contrats et critères dans la décision.
Le [contrat réseau](Documentation/Network.md) cite les exemples officiels des API.

## Liens avec les autres projets

<!-- carte:liens:debut — fabriqué depuis projet.yml par sophos/outils/carte.mjs ; ne pas modifier à la main -->
- **Applique** : [sophos](https://github.com/antoineberjoan/sophos)
<!-- carte:liens:fin -->

Le dépôt choisi est [antoineberjoan/uchi](https://github.com/antoineberjoan/uchi).
Son nom GitHub est conservé ; le produit intégré s'appelle Graker Local.
Les sources, images et workflows du précédent Scratch (Tauri/React) sont
remplacés par le projet Swift. Sa branche de sauvegarde est supprimée à la
demande de l'utilisateur. L'historique Git existant n'est pas réécrit.
Les cinq commits du projet Graker préparé localement sont également conservés
comme ascendance de l'import. La suppression des fichiers n'efface donc pas
l'ancien projet de l'historique Git.

La PR de `feat/graker-local` porte le remplacement. Après sa fusion, une autre
session peut repartir de `main` et lire ces documents. L'utilisateur autorise
la publication dans le dépôt public fourni ; sa visibilité ne change pas.
Référence fonctionnelle : [Graker](https://graker.fehey.com/)
et son [journal](https://graker.fehey.com/changelog), consultés le 7 novembre 2026.

## Règles et décisions

[AGENTS.md](AGENTS.md) active les méthodes Sophos sans les recopier.
[Décision de fondation](docs/decisions/2026-11-07-foundation.md), [marque et jetons](docs/decisions/2026-11-13-marque-jetons.md), [plateformes Apple](docs/decisions/2026-11-13-plateformes-apple.md), [fondation du dépôt](docs/fondation.md) : options,
critères de qualité, couches, tokens et contrats.
[Décision d'import dans uchi](Documentation/Decisions/2026-11-07-repository.md) :
raison du remplacement et conservation des deux historiques.
[Décision de publication](Documentation/Decisions/2026-11-07-publication.md) :
publication dans uchi et suppression de la branche de sauvegarde.
[Décision de fiabilité](Documentation/Decisions/2026-11-08-reliability.md) :
lecture du flux SSE, blancs de la sélection et retour du focus.
[Décision des langues](Documentation/Decisions/2026-11-08-languages.md) :
interface en français, sans langue chinoise, avec DeepSeek conservé.
[Décision de reformulation](Documentation/Decisions/2026-11-08-rephrasing.md) :
mode Reformuler et explications écrites selon `expliquer`.
[Décision d'alignement](Documentation/Decisions/2026-11-08-alignment.md) :
surlignage des changements, menu du fournisseur et écarts restants avec Graker.

Le noyau compile sous Linux avec Swift 6.0.3 ; ses 46 tests XCTest passent. Six tests de plus lisent un faux fournisseur et ne
s'exécutent que sur macOS.
L'application complète compile aussi sur macOS 15 Apple Silicon : les 52 tests,
la construction release et la vérification de signature passent dans
[GitHub Actions](https://github.com/antoineberjoan/uchi/actions/runs/42600201337).
La vérification Python contrôle la fondation, la génération et les frontières.
Les essais interactifs de permissions, raccourcis, placement multi-écrans et
remplacement restent à effectuer sur un Mac. La compilation ne prouve pas ces
comportements. Aucun appel à un fournisseur réel n'a été validé avec une clé API : le faux fournisseur
des tests ne le remplace pas.

En correction et en reformulation, chaque passage modifié est surligné à sa
place. Un clic sur un passage montre le changement et sa raison sous le texte.
Ce texte ne se sélectionne pas : le bouton Copier le remplace.

La traduction conserve les sauts de ligne et les styles Markdown en ligne.
Les titres, tableaux et blocs complexes restent lisibles sous forme de texte
Markdown ; leur rendu complet de Graker n'est pas encore reproduit.

Le parcours manuel minimal est : régler un fournisseur → saisir une phrase →
corriger → cliquer un passage surligné → reformuler une phrase en anglais →
affiner → changer de fournisseur depuis le panneau → traduire → copier ;
appeler réellement le fournisseur avec sa clé ; puis sélectionner dans TextEdit et dans
un navigateur → lancer le raccourci → remplacer ; enfin changer la sélection
avant de remplacer, révoquer la permission, annuler une requête et simuler un
fournisseur inaccessible. Chaque échec doit rester visible, sans perdre la saisie.

## Licence

Usage personnel demandé. Aucune licence de redistribution n'est accordée ici.
Les éléments de marque et captures de Graker ne sont pas inclus. Les méthodes
Sophos sont seulement référencées ; leur licence et leurs restrictions restent
dans leur dépôt d'origine.
