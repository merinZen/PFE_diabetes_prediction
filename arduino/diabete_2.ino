#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <Wire.h>
#include "MAX30105.h"
#include "heartRate.h"

// 👉 1. Remplace ces infos par les tiennes :
#define WIFI_SSID "POCO X3 NFC"
#define WIFI_PASSWORD "lyna123456"

#define FIREBASE_URL "https://my-prj-21113-default-rtdb.europe-west1.firebasedatabase.app"
#define FIREBASE_AUTH "nvolfwk5ADGXgxlM1ZldCXKfKJl5eQ3s3uevgKC5"  // 
// 👉 2. Initialisation Firebase
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

// 👉 3. Capteur MAX30102
MAX30105 particleSensor;
const byte RATE_SIZE = 4;
byte rates[RATE_SIZE];
byte rateSpot = 0;
long lastBeat = 0;
float beatsPerMinute;
int beatAvg = 0;
bool fingerDetected = false;

void setup() {
  Serial.begin(115200);

  // 🔹 Connexion WiFi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connexion WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\n✅ WiFi connecté");

  // 🔹 Configuration Firebase
  config.database_url = FIREBASE_URL;
  config.signer.tokens.legacy_token = FIREBASE_AUTH;
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
  Serial.println("✅ Firebase connecté");

  // 🔹 Initialisation MAX30102
  if (!particleSensor.begin(Wire, I2C_SPEED_STANDARD)) {
    Serial.println("❌ Capteur MAX30102 non détecté !");
    while (1);
  }

  particleSensor.setup(0x1F, 4, 2, 400, 411, 4096);
  particleSensor.enableDIETEMPRDY();

  Serial.println("✅ Capteur MAX30102 prêt. Placez votre doigt...");
}

void loop() {
  long irValue = particleSensor.getIR();

  if (irValue > 50000) {
    if (!fingerDetected) {
      Serial.println("👆 Doigt détecté !");
      fingerDetected = true;
    }

    if (checkForBeat(irValue)) {
      long delta = millis() - lastBeat;
      lastBeat = millis();

      beatsPerMinute = 60 / (delta / 1000.0);

      if (beatsPerMinute < 255 && beatsPerMinute > 20) {
        rates[rateSpot++] = (byte)beatsPerMinute;
        rateSpot %= RATE_SIZE;

        beatAvg = 0;
        for (byte x = 0; x < RATE_SIZE; x++)
          beatAvg += rates[x];
        beatAvg /= RATE_SIZE;
      }
    }

    static unsigned long lastSend = 0;
    if (millis() - lastSend > 5000) {
      lastSend = millis();
      
      // 🔹 Paramètres simulés (tu peux les remplacer plus tard)
      int hrv = map(beatAvg, 60, 100, 70, 30);
      int pa_systolic = constrain(110 + (beatAvg - 60), 90, 140);
      int age = 30;
      float bmi = 24.5;

      FirebaseJson json;
      json.set("timestamp/.sv", "timestamp");
      json.set("hr", beatAvg);
      json.set("hrv", hrv);
      json.set("pa", String(pa_systolic) + "/" + String(pa_systolic - 30));
      json.set("age", age);
      json.set("bmi", bmi);

      if (Firebase.RTDB.pushJSON(&fbdo, "/patients/data", &json)) {
        Serial.println("\n📡 Données envoyées :");
        Serial.print("HR : "); Serial.println(beatAvg);
        Serial.print("HRV : "); Serial.println(hrv);
        Serial.print("PA : "); Serial.print(pa_systolic); Serial.print("/"); Serial.println(pa_systolic - 30);
      } else {
        Serial.println("❌ Erreur Firebase : " + fbdo.errorReason());
      }
    }
  } 
  else {
    if (fingerDetected) {
      Serial.println("❌ Doigt retiré !");
      fingerDetected = false;
      beatAvg = 0;
    }
    delay(200);
  }
}
