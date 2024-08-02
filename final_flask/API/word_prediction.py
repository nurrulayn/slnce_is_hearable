from flask import Flask, request, jsonify
import cv2
import mediapipe as mp
import numpy as np
import tensorflow as tf
from collections import Counter
import base64
import logging
import os

app = Flask(__name__)
logging.basicConfig(level=logging.DEBUG)

# Load the trained TFLite model for hand gesture prediction
model_path = 'models\FYP25Classes.tflite'
interpreter = tf.lite.Interpreter(model_path=model_path)
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# Define class names for hand gestures
class_names = ['Apple', 'Bad', 'Basketball', 'Book', 'Bye', 'Cook', 'Doctor', 'draw' ,
               'Family','Fine', 'Fish','Hat','How','ill','Love' ,'Many', 'Please', 
               'Shoes' ,'Wife' ,'Wrong' , 'You']  

# Initialize Mediapipe Hands for hand landmark detection
mp_hands = mp.solutions.hands
hands = mp_hands.Hands(max_num_hands=1)  

# Parameters
no_of_timesteps = 20
lm_list = []
predictions = []

# Preprocess frame for hand gesture prediction
def preprocess_frame(frame_data, frame_index):
    try:
        frame_bytes = base64.b64decode(frame_data)
        logging.debug(f"Decoded frame bytes length: {len(frame_bytes)}")
        
        frame_np = np.frombuffer(frame_bytes, dtype=np.uint8)
        logging.debug(f"Numpy array shape: {frame_np.shape}")
        
        frame_rgb = cv2.imdecode(frame_np, cv2.IMREAD_COLOR)
        if frame_rgb is None:
            logging.error("Frame is None after decoding")
            return None

        results = hands.process(cv2.cvtColor(frame_rgb, cv2.COLOR_BGR2RGB))

        if results.multi_hand_landmarks:
            lm = make_landmark_timestep(results)
            lm_list.append(lm)

            if len(lm_list) == no_of_timesteps:
                X_input = np.expand_dims(np.array(lm_list), axis=0).astype(np.float32)
                interpreter.set_tensor(input_details[0]['index'], X_input)
                interpreter.invoke()
                prediction = interpreter.get_tensor(output_details[0]['index'])
                predicted_class = np.argmax(prediction, axis=1)[0]
                predictions.append(predicted_class)
                logging.debug(f"Prediction made: {predicted_class}")
                lm_list.pop(0)

        return results
    except Exception as e:
        logging.error(f"Error processing frame: {e}")
        return None

def make_landmark_timestep(results):
    c_lm = []
    if results.multi_hand_landmarks:
        hand_landmarks = results.multi_hand_landmarks[0]  # Only consider the first detected hand
        for lm in hand_landmarks.landmark:
            c_lm.extend([lm.x, lm.y, lm.z])
    return c_lm


@app.route('/predict_hand_gesture', methods=['POST'])
def predict_hand_gesture():
    global predictions, lm_list
    data = request.get_json()
    frames = data.get('frames', [])

    logging.debug(f"Number of frames received for hand gesture prediction: {len(frames)}")

    # Clear previous predictions and lm_list
    predictions = []
    lm_list = []

    for index, frame_data in enumerate(frames):
        try:
            results = preprocess_frame(frame_data, index)
            if results is None:
                logging.error(f"Empty or invalid frame for hand gesture prediction at index {index}")
        except Exception as e:
            logging.error(f"Error processing frame for hand gesture prediction at index {index}: {e}")

    if predictions:
        most_common_prediction = Counter(predictions).most_common(1)[0][0]
        predicted_class_name = class_names[most_common_prediction]
        return jsonify({'prediction': predicted_class_name})
    else:
        return jsonify({'error': 'No valid hand gesture predictions'}), 400


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
