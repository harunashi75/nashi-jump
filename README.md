# Nashi Jump

Platformer 2D réalisé avec **Godot 4.7** (Forward Plus). Traversez 13 niveaux répartis en 4 mondes, affrontez le boss final, ramassez les pièces et débloquez des skins.

## Lancer le projet

1. Installer [Godot 4.7](https://godotengine.org/).
2. Ouvrir `project.godot` avec l'éditeur.
3. Lancer avec F5 (scène principale : `start_menu.tscn`).

Des presets d'export (Windows, Linux) existent localement dans `export_presets.cfg`. Ce fichier est ignoré par git : pensez à le sauvegarder.

## Contrôles

| Action | Touches |
|---|---|
| Aller à gauche / droite | Flèches ou A / D |
| Sauter (double saut possible) | Espace / bouton manette |
| Pause | Échap |
| Godmode (debug uniquement) | G |

## Structure

```
Assets/
  Scenes/    niveaux (level_*.tscn), ennemis, UI, objets
  Scripts/   code GDScript
  Sprites/   Sons/ Fonts/
```

### Autoloads

| Nom | Rôle |
|---|---|
| `LevelManager` | **Source unique des niveaux** (`LEVEL_DEFS` : ordre, monde, glace), changement de scène |
| `GameManager` | Pause, sauvegarde de progression, pièces, checkpoint, godmode (debug) |
| `TimerManager` | Chrono de la partie et meilleur temps |
| `SoundManager` | Effets sonores et musique par monde (changée au changement de scène) |
| `SkinManager` | Skins, déblocages et sauvegarde |

## Ajouter du contenu

- **Un niveau** : créer la scène `level_xxx.tscn`, puis ajouter une ligne dans `LevelManager.LEVEL_DEFS` (fichier, monde, `"ice": true` si glissant). La musique et la physique suivent automatiquement.
- **Une pièce** : instancier `coin.tscn` dans le niveau. Le total pour le skin *gold* est recalculé depuis les scènes.
- **Un skin secret** : instancier un `Area2D` avec `skin_pickup.gd` et renseigner `skin_id` ; déclarer le skin dans `SkinManager.unlocked_skins`.
- **Un portail** : `level_portal.gd` mène au niveau suivant (`next_level_path`), `in_level_teleport.gd` téléporte dans le même niveau.

## Sauvegardes

Fichiers dans `user://` : `savegame.cfg` (niveau, pièces), `skin_data.save` (skins), `score.save` (meilleur temps).
