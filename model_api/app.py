from flask import Flask, request, jsonify
import joblib
import numpy as np
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Allow cross-origin requests 
#(important for Flutter to talk to Flask)
# Load the trained Random Forest model
model = joblib.load("diabetes_model.joblib")


@app.route("/predict", methods=["POST"])
def predict():
    try:
        data = request.get_json()

        # Expected input: [age, height, weight, gender, stress, history, heart_rate, bmi]
        features = np.array(data["features"]).reshape(1, -1)
        prediction = model.predict(features)[0]

        return jsonify({"prediction": int(prediction)})
    
    except Exception as e:
        return jsonify({"error": str(e)}), 400

if __name__ == "__main__":
    app.run(debug=True)
