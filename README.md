# PFE_diabetes_prediction
# PFE – Système de Prédiction du Diabète

Ce projet de fin d'études vise à développer une solution de suivi de santé intelligente capable de prédire le risque de diabète à partir de données médicales et de mesures en temps réel.

Il s’appuie sur :
- Une application mobile Flutter
- Un capteur MAX30105 connecté à un ESP32
- Une base de données Firebase
- Un modèle de machine learning (Random Forest) exposé via une API Flask
- Des notebooks Jupyter pour le traitement et l'entraînement du modèle

## Structure du projet

- `appo1/` : Application Flutter  
- `arduina/` : Code Arduino (ESP32 + MAX30105)  
- `model_api/` : API Flask pour la prédiction  
- `model_training/` : Entraînement du modèle (Jupyter Notebook)  
- `diabetes_dataset.csv` : Jeu de données utilisé pour l'entraînement

## Fonctionnement

1. L’utilisateur mesure sa fréquence cardiaque à l’aide de l’ESP32.
2. L’application Flutter envoie les données à l’API Flask.
3. L’API renvoie une prédiction du risque de diabète.
4. Le résultat est affiché dans l’application.

Le fichier du modèle (`.joblib`) est exclu du dépôt car il dépasse la limite GitHub. Il doit être ajouté manuellement dans `model_api/` pour faire fonctionner l’API.

## Réalisé par

- Merina Zennouche
- Lyna Houfel 