from flask import Flask, request, jsonify
import numpy as np
import base64
import cv2
import mediapipe as mp
from collections import Counter
import logging
import tensorflow as tf

app = Flask(__name__)

# Set up logging
logging.basicConfig(level=logging.INFO)

# Load the TFLite model
model_path = 'E:/final_flask/API/models/FYP13Classes.tflite'

try:
    interpreter = tf.lite.Interpreter(model_path=model_path)
    interpreter.allocate_tensors()
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    logging.info(f"Model loaded successfully from {model_path}")
except Exception as e:
    logging.error(f"Error loading the model from {model_path}: {str(e)}")
    interpreter = None

# Define class names
class_names = ['Apple', 'Bad', 'Basketball', 'Book', 'Bye', 'Cook', 'Doctor', 'draw', 'Family', 'Fine', 'Fish', 'Hat', 'How', 'ill', 'Love', 'Many', 'Please', 'Shoes', 'Wife', 'Wrong', 'You']

# Initialize Mediapipe Hands
mp_hands = mp.solutions.hands
hands = mp_hands.Hands(max_num_hands=1)
mp_draw = mp.solutions.drawing_utils

def make_landmark_timestep(results):
    if results.multi_hand_landmarks:
        hand_landmarks = results.multi_hand_landmarks[0]
        c_lm = []
        for lm in hand_landmarks.landmark:
            c_lm.extend([lm.x, lm.y, lm.z])
        return c_lm
    return [0.0] * 63

@app.route('/predict_sentence', methods=['POST'])
def predict_sentence():
    data = request.get_json()
    frames = data['frames']
    lm_list = []
    predictions = []

    for frame_data in frames:
        frame = base64.b64decode(frame_data)
        np_frame = np.frombuffer(frame, dtype=np.uint8)
        image = cv2.imdecode(np_frame, cv2.IMREAD_COLOR)
        frame_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        results = hands.process(frame_rgb)
        lm = make_landmark_timestep(results)
        lm_list.append(lm)

        if len(lm_list) == 20:  # Assuming you want 20 timesteps
            X_input = np.expand_dims(np.array(lm_list), axis=0).astype(np.float32)
            interpreter.set_tensor(input_details[0]['index'], X_input)
            interpreter.invoke()
            prediction = interpreter.get_tensor(output_details[0]['index'])
            predicted_class = np.argmax(prediction, axis=1)[0]
            predictions.append(predicted_class)
            lm_list.pop(0)  # Remove the oldest timestep to make space for the next one

    if len(predictions) > 0:
        # Determine the two most frequently predicted classes
        most_common_classes = Counter(predictions).most_common(2)
        most_common_class_name_1 = class_names[most_common_classes[0][0]]
        most_common_class_name_2 = class_names[most_common_classes[1][0]] if len(most_common_classes) > 1 else 'N/A'

        # Log predictions
        logging.info(f"Most common prediction 1: {most_common_class_name_1}")
        logging.info(f"Most common prediction 2: {most_common_class_name_2}")

        return jsonify({
            'prediction_1': most_common_class_name_1,
            'prediction_2': most_common_class_name_2
        })
    else:
        logging.info("No valid predictions made")
        return jsonify({'prediction': 'No valid predictions made'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002)
