# Retirer DeepSeek des fournisseurs — 8 novembre 2026

## Décision de l'utilisateur

Antoine demande de supprimer tout le chinois de l'application. Il rappelle
l'objectif : copier [Graker](https://graker.fehey.com/) pour un usage
personnel, puis l'adapter à ses propres cas d'usage.

## Application

L'application ne contient aucun texte chinois : son interface est en français.
L'interface en chinois simplifié et traditionnel de Graker 1.3.0 n'a pas été
reprise. Le seul élément chinois est le fournisseur DeepSeek, retiré du code
et du contrat réseau. Les fournisseurs proposés sont Google Gemini et
« Compatible OpenAI ».

La décision de fondation cite encore DeepSeek. Elle n'est pas réécrite :
la présente décision la remplace sur ce point.

## Conséquences

Des préférences enregistrées avec DeepSeek ne se décodent plus. L'application
affiche alors l'erreur des préférences illisibles et repart des réglages par
défaut. Aucune clé DeepSeek n'a pu être enregistrée avant ce retrait :
la validation échouait toujours à cause du flux SSE (voir la décision de
fiabilité), et la clé n'est enregistrée qu'après une validation réussie.

Le champ « Compatible OpenAI » accepte toujours toute adresse. Un fournisseur
chinois reste donc joignable si l'utilisateur saisit lui-même son adresse.
