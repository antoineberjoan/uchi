# Fiabilité du flux, de la sélection et du focus — 8 novembre 2026

## Décision

Trois corrections. Les contrats de la fondation ne changent pas.

1. **Flux SSE.** `ProviderClient` lit les octets et `LineDecoder` les découpe
   en lignes. Les lignes vides restent. `URLSession.AsyncBytes.lines` les saute
   ([forum Apple](https://developer.apple.com/forums/thread/725162)) ; or une
   ligne vide ferme chaque événement SSE. Sans elle, `StreamDecoder` joint tous
   les événements en un JSON illisible et chaque requête échoue.
2. **Blancs de la sélection.** `SourceWhitespace` retire les blancs de début et
   de fin avant l'envoi, puis les remet autour du résultat. Un triple-clic
   sélectionne un paragraphe avec son retour à la ligne. Le modèle le retire
   souvent : une phrase correcte échouait à la validation, et le remplacement
   collait le paragraphe au suivant.
3. **Focus.** À la fermeture du panneau, `PanelController` réactive
   l'application qui était au premier plan à son ouverture. Sinon, Graker Local
   reste active sans fenêtre et le collage après « Copier » ne va nulle part.

Le texte progressif part vers l'affichage au plus toutes les 80 ms. Avant,
chaque morceau relisait tout le Markdown sur le fil principal.

## Options écartées

- Garder `lines` et fermer un événement à chaque nouvelle ligne `data:` :
  la norme SSE permet plusieurs lignes `data:` dans un même événement.
- Ajouter une bibliothèque SSE : le projet n'a aucune dépendance Swift externe.
- Demander au modèle de garder les blancs : une consigne ne garantit rien.
- Cacher toute l'application (`NSApp.hide`) : la fenêtre Réglages disparaîtrait aussi.

## Preuves et limites

Sous Linux, Swift 6.0.3 : les tests du noyau passent. Un test montre que la
perte des lignes vides rend le flux illisible. Sur macOS 15, le workflow
compile l'application et passe les tests du noyau. Le comportement réel reste à
vérifier sur un Mac : flux d'un vrai fournisseur, retour du focus, remplacement.

Le décodeur exige toujours `data: [DONE]` après `finish_reason: stop`. La
présence de ce marqueur chez Gemini n'est pas vérifiée. S'il manque, l'erreur
« La connexion s'est arrêtée avant la fin » reste visible.
