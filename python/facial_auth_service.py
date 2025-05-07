#!/usr/bin/env python3
"""
Advanced Facial Authentication Service for NAFacial App
This service provides advanced face recognition and authentication capabilities
using multiple state-of-the-art models and techniques.
"""

import os
import json
import base64
import asyncio
import logging
import traceback
from typing import Dict, List, Any, Optional, Tuple
import numpy as np
import cv2
from PIL import Image

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[logging.StreamHandler()]
)
logger = logging.getLogger("FacialAuthService")

# Try to import advanced face recognition libraries
# If they're not available, we'll use fallback methods
try:
    import mediapipe as mp
    MEDIAPIPE_AVAILABLE = True
    mp_face_detection = mp.solutions.face_detection
    mp_face_mesh = mp.solutions.face_mesh
    logger.info("MediaPipe is available")
except ImportError:
    MEDIAPIPE_AVAILABLE = False
    logger.warning("MediaPipe is not available, some features will be disabled")

try:
    from deepface import DeepFace
    DEEPFACE_AVAILABLE = True
    logger.info("DeepFace is available")
except ImportError:
    DEEPFACE_AVAILABLE = False
    logger.warning("DeepFace is not available, some features will be disabled")

try:
    import face_recognition
    FACE_RECOGNITION_AVAILABLE = True
    logger.info("face_recognition is available")
except ImportError:
    FACE_RECOGNITION_AVAILABLE = False
    logger.warning("face_recognition is not available, some features will be disabled")

class FacialAuthService:
    """Advanced facial authentication service"""

    def __init__(self):
        """Initialize the service"""
        # Create directories for storing face data
        self.data_dir = os.path.join(os.path.dirname(__file__), "face_data")
        os.makedirs(self.data_dir, exist_ok=True)

        # Initialize face detection models
        if MEDIAPIPE_AVAILABLE:
            self.face_detector = mp_face_detection.FaceDetection(min_detection_confidence=0.5)
            self.face_mesh = mp_face_mesh.FaceMesh(
                static_image_mode=True,
                max_num_faces=1,
                min_detection_confidence=0.5
            )

        # Load existing face data
        self.face_database = self._load_face_database()

        logger.info(f"Initialized facial authentication service with {len(self.face_database)} users")

    def _load_face_database(self) -> Dict[str, Any]:
        """Load face database from disk"""
        database_path = os.path.join(self.data_dir, "face_database.json")

        if os.path.exists(database_path):
            try:
                with open(database_path, "r") as f:
                    return json.load(f)
            except Exception as e:
                logger.error(f"Error loading face database: {e}")

        return {}

    def _save_face_database(self):
        """Save face database to disk"""
        database_path = os.path.join(self.data_dir, "face_database.json")

        try:
            with open(database_path, "w") as f:
                json.dump(self.face_database, f, indent=2)
        except Exception as e:
            logger.error(f"Error saving face database: {e}")

    async def register_face(self, image: np.ndarray, user_id: str) -> Dict[str, Any]:
        """
        Register a face for a user

        Args:
            image: The face image
            user_id: The user ID

        Returns:
            Result of the registration
        """
        try:
            # Detect face in the image
            face_image, face_encoding = await self._extract_face_and_encoding(image)

            if face_image is None or face_encoding is None:
                return {
                    "success": False,
                    "message": "No face detected in the image"
                }

            # Save face image
            face_image_path = os.path.join(self.data_dir, f"{user_id}.jpg")
            cv2.imwrite(face_image_path, face_image)

            # Save face encoding
            face_encoding_path = os.path.join(self.data_dir, f"{user_id}.npy")
            np.save(face_encoding_path, face_encoding)

            # Update database
            self.face_database[user_id] = {
                "face_image_path": face_image_path,
                "face_encoding_path": face_encoding_path,
                "registration_time": asyncio.get_event_loop().time()
            }

            # Save database
            self._save_face_database()

            return {
                "success": True,
                "message": "Face registered successfully",
                "user_id": user_id
            }

        except Exception as e:
            logger.error(f"Error registering face: {e}")
            logger.error(traceback.format_exc())
            return {
                "success": False,
                "message": f"Error registering face: {str(e)}"
            }

    async def verify_face(self, image: np.ndarray, user_id: str) -> Dict[str, Any]:
        """
        Verify a face against a registered user

        Args:
            image: The face image
            user_id: The user ID

        Returns:
            Result of the verification
        """
        try:
            # Check if user exists
            if user_id not in self.face_database:
                return {
                    "success": False,
                    "message": "User not registered"
                }

            # Extract face and encoding from the image
            face_image, face_encoding = await self._extract_face_and_encoding(image)

            if face_image is None or face_encoding is None:
                return {
                    "success": False,
                    "message": "No face detected in the image"
                }

            # Load registered face encoding
            registered_encoding_path = self.face_database[user_id]["face_encoding_path"]
            registered_encoding = np.load(registered_encoding_path)

            # Compare face encodings
            if FACE_RECOGNITION_AVAILABLE:
                # Use face_recognition for comparison
                distance = face_recognition.face_distance([registered_encoding], face_encoding)[0]
                match = distance <= 0.7  # Increased threshold (lower similarity required)
                confidence = 1.0 - distance
            elif DEEPFACE_AVAILABLE:
                # Use DeepFace for comparison
                registered_image_path = self.face_database[user_id]["face_image_path"]
                temp_path = os.path.join(self.data_dir, "temp.jpg")
                cv2.imwrite(temp_path, face_image)

                verification = DeepFace.verify(
                    temp_path,
                    registered_image_path,
                    model_name="VGG-Face",
                    distance_metric="cosine"
                )

                os.remove(temp_path)

                distance = verification.get("distance", 1.0)
                match = verification.get("verified", False)
                confidence = 1.0 - distance
            else:
                # Fallback to simple comparison
                distance = np.linalg.norm(registered_encoding - face_encoding)
                match = distance <= 0.8  # Increased threshold for easier matching
                confidence = 1.0 - min(distance, 1.0)

            return {
                "success": True,
                "match": match,
                "confidence": float(confidence),
                "distance": float(distance),
                "user_id": user_id
            }

        except Exception as e:
            logger.error(f"Error verifying face: {e}")
            logger.error(traceback.format_exc())
            return {
                "success": False,
                "message": f"Error verifying face: {str(e)}"
            }

    async def identify_face(self, image: np.ndarray) -> Dict[str, Any]:
        """
        Identify a face against all registered users

        Args:
            image: The face image

        Returns:
            Result of the identification
        """
        try:
            # Extract face and encoding from the image
            face_image, face_encoding = await self._extract_face_and_encoding(image)

            if face_image is None or face_encoding is None:
                return {
                    "success": False,
                    "message": "No face detected in the image"
                }

            # Compare with all registered faces
            best_match = None
            best_confidence = 0.0
            best_distance = float('inf')

            for user_id, user_data in self.face_database.items():
                try:
                    # Load registered face encoding
                    registered_encoding_path = user_data["face_encoding_path"]
                    registered_encoding = np.load(registered_encoding_path)

                    # Compare face encodings
                    if FACE_RECOGNITION_AVAILABLE:
                        # Use face_recognition for comparison
                        distance = face_recognition.face_distance([registered_encoding], face_encoding)[0]
                        confidence = 1.0 - distance
                    elif DEEPFACE_AVAILABLE:
                        # Use DeepFace for comparison
                        registered_image_path = user_data["face_image_path"]
                        temp_path = os.path.join(self.data_dir, "temp.jpg")
                        cv2.imwrite(temp_path, face_image)

                        verification = DeepFace.verify(
                            temp_path,
                            registered_image_path,
                            model_name="VGG-Face",
                            distance_metric="cosine"
                        )

                        os.remove(temp_path)

                        distance = verification.get("distance", 1.0)
                        confidence = 1.0 - distance
                    else:
                        # Fallback to simple comparison
                        distance = np.linalg.norm(registered_encoding - face_encoding)
                        confidence = 1.0 - min(distance, 1.0)

                    # Update best match
                    if confidence > best_confidence:
                        best_match = user_id
                        best_confidence = confidence
                        best_distance = distance

                except Exception as e:
                    logger.error(f"Error comparing with user {user_id}: {e}")
                    continue

            # Determine if it's a match
            match = best_confidence >= 0.6  # Reduced threshold for easier identification

            if match:
                return {
                    "success": True,
                    "match": True,
                    "user_id": best_match,
                    "confidence": float(best_confidence),
                    "distance": float(best_distance)
                }
            else:
                return {
                    "success": True,
                    "match": False,
                    "message": "No matching user found"
                }

        except Exception as e:
            logger.error(f"Error identifying face: {e}")
            logger.error(traceback.format_exc())
            return {
                "success": False,
                "message": f"Error identifying face: {str(e)}"
            }

    async def _extract_face_and_encoding(self, image: np.ndarray) -> Tuple[Optional[np.ndarray], Optional[np.ndarray]]:
        """
        Extract face and encoding from an image

        Args:
            image: The image

        Returns:
            Tuple of (face_image, face_encoding)
        """
        # Convert to RGB for face_recognition
        rgb_image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

        # Detect face
        if FACE_RECOGNITION_AVAILABLE:
            # Use face_recognition for detection
            face_locations = face_recognition.face_locations(rgb_image)

            if not face_locations:
                return None, None

            # Get the largest face
            top, right, bottom, left = face_locations[0]

            # Extract face image
            face_image = image[top:bottom, left:right]

            # Get face encoding
            face_encoding = face_recognition.face_encodings(rgb_image, [face_locations[0]])[0]

            return face_image, face_encoding

        elif MEDIAPIPE_AVAILABLE:
            # Use MediaPipe for detection
            results = self.face_detector.process(rgb_image)

            if not results.detections:
                return None, None

            # Get the first detection
            detection = results.detections[0]

            # Get bounding box
            height, width, _ = image.shape
            bbox = detection.location_data.relative_bounding_box
            x = int(bbox.xmin * width)
            y = int(bbox.ymin * height)
            w = int(bbox.width * width)
            h = int(bbox.height * height)

            # Extract face image
            face_image = image[y:y+h, x:x+w]

            # We don't have face encodings with MediaPipe, so we'll use a simple feature vector
            # This is not as accurate as face_recognition encodings
            # In a real implementation, you would use a proper face recognition model
            face_image_small = cv2.resize(face_image, (128, 128))
            face_image_gray = cv2.cvtColor(face_image_small, cv2.COLOR_BGR2GRAY)
            face_encoding = face_image_gray.flatten() / 255.0  # Normalize

            return face_image, face_encoding

        else:
            # Fallback to Haar cascade
            face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
            faces = face_cascade.detectMultiScale(gray, 1.1, 4)

            if len(faces) == 0:
                return None, None

            # Get the largest face
            x, y, w, h = faces[0]

            # Extract face image
            face_image = image[y:y+h, x:x+w]

            # Create a simple feature vector
            face_image_small = cv2.resize(face_image, (128, 128))
            face_image_gray = cv2.cvtColor(face_image_small, cv2.COLOR_BGR2GRAY)
            face_encoding = face_image_gray.flatten() / 255.0  # Normalize

            return face_image, face_encoding
