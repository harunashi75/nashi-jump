# Changelog

Format inspiré de [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/).
Les versions antérieures à 0.16.9 sont uniquement dans l'historique git.

## [Non publié]

### Ajouté
- `SaveManager` : sauvegarde unique et versionnée (`user://save.cfg`), écriture atomique, valeurs typées, import automatique des anciens fichiers.
- Typage statique GDScript sur toutes les fonctions et variables ; `class_name Player`.
- `export_presets.cfg` est désormais versionné (aucun secret dedans).

### Modifié
- Bouclage des 5 musiques réglé à l'import (`loop=true`) au lieu d'être forcé dans le code ; relance automatique en filet de sécurité.

### Supprimé
- 3 fichiers audio inutilisés (`ive_got_your_back.ogg`, `journey_across_the_blue.ogg`, `time_for_adventure.mp3`, environ 6,8 Mo) et le `sfx_player` inutilisé du `SoundManager`.

## [0.17.0] - 2026-11-26

### Ajouté
- README, CHANGELOG et ce suivi de versions (tags git).
- Meilleur temps enregistré à la victoire et affiché sur l'écran de fin.
- `patrol_hazard.gd` : un seul script pour la scie (horizontale) et le brickhead (vertical).
- `skin_pickup.gd` : un seul script pour les skins secrets (`skin_id` défini dans la scène).
- `LevelManager.LEVEL_DEFS` : source unique des niveaux (ordre, monde, glace).
- Nouvelles musiques par monde et pour le boss.

### Modifié
- Boss en machine d'états (`RUN`, `SLAM`, `SPIN`, `DEAD`) avec constantes nommées.
- Total de pièces calculé à partir des scènes ; le skin gold exige toutes les pièces posées (335), les pièces lâchées par les ennemis ne comptent plus.
- Musique changée au changement de scène (plus de test à chaque frame) ; les sons du menu pause fonctionnent.
- Scripts renommés : `level_portal.gd` (portail de fin de niveau), `in_level_teleport.gd` (téléportation interne), `level_setup.gd`.
- `LevelManager` simplifié (`load_level_by_path` seul point d'entrée).

### Corrigé
- Le skin choisi est sauvegardé.
- Morts, état « sans dégât » et temps remis à zéro à chaque nouvelle run, sauvegardés pour « Continuer ».
- Tomber dans le vide compte comme une mort.
- Sauvegarde des skins robuste face à un fichier corrompu.
- Détection du joueur par groupe (`tp_victory`, portails) au lieu du nom du nœud.
- Godmode (touche G) limité aux builds de debug.
- Erreur de typage dans `patrol_hazard.gd`.

### Supprimé
- Logs de debug, fonctions mortes de `LevelManager`, doublons de scripts de skin.

## [0.16.9] - 2026-11
- Nouvelles musiques, sprites ennemis renommés, refonte du `SoundManager`.
