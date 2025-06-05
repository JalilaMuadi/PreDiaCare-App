from flask import Flask, request, jsonify
import joblib
import pandas as pd

app = Flask(__name__)

# Load your trained model and metadata
model, encoded_columns, df, recommendation_columns = joblib.load("recommendation_system.joblib")

@app.route('/recommend', methods=['POST'])
def recommend():
    try:
        # Parse incoming JSON
        user_input = request.get_json()
        print("📥 Received input:", user_input)

        # Convert to DataFrame
        user_df = pd.DataFrame([user_input])

        # Encode input using same encoding as training
        user_encoded = pd.get_dummies(user_df)
        user_encoded = user_encoded.reindex(columns=encoded_columns, fill_value=0)

        # Find the nearest neighbor
        distances, indices = model.kneighbors(user_encoded)
        nearest_index = indices[0][0]

        # Get the recommendation
        recs = df.iloc[nearest_index][recommendation_columns]
        rec_dict = recs.fillna("No recommendation").to_dict()
        return jsonify(rec_dict), 200


    except Exception as e:
        print("❌ Error during recommendation:", str(e))
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)
