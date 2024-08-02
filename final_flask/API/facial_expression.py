from flask import Flask, request, jsonify
import tensorflow as tf
import cv2
import numpy as np
import base64
from collections import Counter

app = Flask(__name__)

# Load the face classifier
face_classifier = cv2.CascadeClassifier(r'E:\final_flask\API\classifier\haarcascade_frontalface_default.xml')
# Load the TFLite model
interpreter = tf.lite.Interpreter(model_path=r'E:\final_flask\API\models\facial_expression.tflite')
interpreter.allocate_tensors()

# Get input and output details
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

emotion_labels = ['Angry', 'Disgust', 'Fear', 'Happy', 'Neutral', 'Sad', 'Surprise']

def decode_base64_image(base64_string):
    decoded_data = base64.b64decode(base64_string)
    np_data = np.frombuffer(decoded_data, np.uint8)
    img = cv2.imdecode(np_data, cv2.IMREAD_COLOR)
    return img

@app.route('/predict_facial_expression', methods=['POST'])
def predict_facial_expression():
    try:
        data = request.get_json()
        frames = data['frames']
        predictions = []

        for frame in frames:
            image = decode_base64_image(frame)
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
            faces = face_classifier.detectMultiScale(gray)

            for (x, y, w, h) in faces:
                roi_gray = gray[y:y+h, x:x+w]
                roi_gray = cv2.resize(roi_gray, (48, 48), interpolation=cv2.INTER_AREA)

                if np.sum([roi_gray]) != 0:
                    roi = roi_gray.astype('float32') / 255.0
                    roi = np.expand_dims(roi, axis=(0, -1))

                    # Set the tensor
                    interpreter.set_tensor(input_details[0]['index'], roi)
                    interpreter.invoke()
                    
                    # Get the output
                    prediction = interpreter.get_tensor(output_details[0]['index'])[0]
                    label = emotion_labels[np.argmax(prediction)]
                    predictions.append(label)
                else:
                    predictions.append('No Face Detected')

        if predictions:
            most_common_emotion = Counter(predictions).most_common(1)[0][0]
        else:
            most_common_emotion = 'No Face Detected'

        # Print the most common emotion to the terminal
        print(f'Facial Expression Detected = {most_common_emotion}')

        return jsonify({'prediction': most_common_emotion})

    except Exception as e:
        return jsonify({'error': str(e)})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
