#!/usr/bin/env python3
"""
Enhanced Android-specific Face Recognition Server for NAFacial App
This lightweight server is designed to run on Android devices using Termux.
"""

import asyncio
import json
import base64
import io
import os
import sys
import time
import logging
import traceback
import signal
import platform
from typing import Dict, List, Any, Optional, Tuple
from datetime import datetime
import numpy as np
import cv2

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[logging.StreamHandler()]
)
logger = logging.getLogger("EnhancedAndroidFaceRecognitionServer")

# Server version
SERVER_VERSION = "2.0.0"

class EnhancedAndroidFaceDetector:
    """Enhanced lightweight face detector for Android"""

    def __init__(self):
        """Initialize the detector with OpenCV's Haar cascade"""
        # Use Haar cascade for face detection (lightweight)
        self.face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')

        # Also load the eye cascade for better verification
        self.eye_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_eye.xml')

        # Create directories for temporary files and face database
        os.makedirs("temp", exist_ok=True)
        os.makedirs("face_db", exist_ok=True)

        # Initialize face database
        self.face_database = {}
        self._load_face_database()

        # Performance metrics
        self.total_requests = 0
        self.successful_requests = 0
        self.total_processing_time = 0
        self.start_time = datetime.now()

        logger.info("Enhanced Android Face Detector initialized")
        logger.info(f"OpenCV version: {cv2.__version__}")
        logger.info(f"Running on: {platform.system()} {platform.release()}")

    def _load_face_database(self):
        """Load face database from disk"""
        try:
            face_files = os.listdir("face_db")
            for face_file in face_files:
                if face_file.endswith(".npy"):
                    person_id = face_file.split(".")[0]
                    face_data = np.load(os.path.join("face_db", face_file))
                    self.face_database[person_id] = face_data

            logger.info(f"Loaded {len(self.face_database)} faces from database")
        except Exception as e:
            logger.error(f"Error loading face database: {e}")

    def detect_faces(self, image: np.ndarray, min_confidence: float = 0.3) -> List[Dict[str, Any]]:
        """
        Detect faces in an image

        Args:
            image: The image as a numpy array
            min_confidence: Minimum confidence threshold

        Returns:
            List of detected faces with their bounding boxes and landmarks
        """
        # Update metrics
        self.total_requests += 1
        start_time = time.time()

        try:
            # Convert to grayscale for face detection
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

            # Detect faces
            faces = self.face_cascade.detectMultiScale(
                gray,
                scaleFactor=1.1,
                minNeighbors=5,
                minSize=(30, 30),
                flags=cv2.CASCADE_SCALE_IMAGE
            )

            # Process detected faces
            result = []
            for i, (x, y, w, h) in enumerate(faces):
                # Calculate confidence (just a placeholder in Haar cascade)
                confidence = 0.9  # Fixed confidence for Haar cascade

                # Skip faces with low confidence
                if confidence < min_confidence:
                    continue

                # Extract face ROI
                face_roi = gray[y:y+h, x:x+w]

                # Detect eyes to verify this is a real face
                eyes = self.eye_cascade.detectMultiScale(face_roi)

                # Create face object
                face = {
                    "id": i,
                    "boundingBox": {
                        "x": int(x),
                        "y": int(y),
                        "width": int(w),
                        "height": int(h)
                    },
                    "confidence": float(confidence),
                    "landmarks": {},
                    "eyesDetected": len(eyes)
                }

                # Add landmarks (eye positions) if detected
                if len(eyes) > 0:
                    landmarks = {}
                    for j, (ex, ey, ew, eh) in enumerate(eyes):
                        landmarks[f"eye_{j}"] = {
                            "x": int(x + ex + ew/2),
                            "y": int(y + ey + eh/2)
                        }
                    face["landmarks"] = landmarks

                result.append(face)

            # Update metrics
            processing_time = time.time() - start_time
            self.total_processing_time += processing_time
            if len(result) > 0:
                self.successful_requests += 1

            return result
        except Exception as e:
            logger.error(f"Error detecting faces: {e}")
            logger.error(traceback.format_exc())

            # Update metrics
            processing_time = time.time() - start_time
            self.total_processing_time += processing_time

            return []

    def compare_faces(self, face1: np.ndarray, face2: np.ndarray) -> Dict[str, Any]:
        """
        Compare two face images using a simple histogram comparison

        Args:
            face1: First face image
            face2: Second face image

        Returns:
            Dictionary with similarity metrics
        """
        try:
            # Resize images to the same size
            face1 = cv2.resize(face1, (128, 128))
            face2 = cv2.resize(face2, (128, 128))

            # Convert to grayscale
            gray1 = cv2.cvtColor(face1, cv2.COLOR_BGR2GRAY)
            gray2 = cv2.cvtColor(face2, cv2.COLOR_BGR2GRAY)

            # Calculate histograms
            hist1 = cv2.calcHist([gray1], [0], None, [256], [0, 256])
            hist2 = cv2.calcHist([gray2], [0], None, [256], [0, 256])

            # Normalize histograms
            cv2.normalize(hist1, hist1, 0, 1, cv2.NORM_MINMAX)
            cv2.normalize(hist2, hist2, 0, 1, cv2.NORM_MINMAX)

            # Compare histograms
            similarity = cv2.compareHist(hist1, hist2, cv2.HISTCMP_CORREL)
            distance = 1.0 - similarity

            # Determine if it's a match
            match = similarity >= 0.7

            return {
                "similarity": float(similarity),
                "distance": float(distance),
                "match": match,
                "metrics": {
                    "histogram": {
                        "similarity": float(similarity),
                        "distance": float(distance)
                    }
                }
            }
        except Exception as e:
            logger.error(f"Error comparing faces: {e}")
            logger.error(traceback.format_exc())
            return {
                "similarity": 0.0,
                "distance": 1.0,
                "match": False,
                "error": str(e)
            }

    def identify_face(self, image: np.ndarray, min_similarity: float = 0.4) -> Dict[str, Any]:
        """
        Identify a face in the database

        Args:
            image: The image as a numpy array
            min_similarity: Minimum similarity threshold

        Returns:
            Dictionary with identification results
        """
        # Update metrics
        self.total_requests += 1
        start_time = time.time()

        try:
            # Convert to grayscale
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

            # Detect faces
            faces = self.face_cascade.detectMultiScale(
                gray,
                scaleFactor=1.1,
                minNeighbors=5,
                minSize=(30, 30),
                flags=cv2.CASCADE_SCALE_IMAGE
            )

            # No faces detected
            if len(faces) == 0:
                return {
                    "success": False,
                    "message": "No faces detected",
                    "processing_time": time.time() - start_time
                }

            # Use the largest face
            largest_face = max(faces, key=lambda rect: rect[2] * rect[3])
            x, y, w, h = largest_face

            # Extract face ROI and normalize
            face_roi = gray[y:y+h, x:x+w]
            face_roi = cv2.resize(face_roi, (100, 100))
            face_roi = cv2.equalizeHist(face_roi)

            # Flatten the face for comparison
            face_vector = face_roi.flatten().astype(np.float32)
            face_vector = face_vector / np.linalg.norm(face_vector)

            # Compare with database
            best_match = None
            best_similarity = 0

            for person_id, stored_face in self.face_database.items():
                # Calculate similarity (cosine similarity)
                similarity = np.dot(face_vector, stored_face)

                if similarity > best_similarity:
                    best_similarity = similarity
                    best_match = person_id

            # Update metrics
            processing_time = time.time() - start_time
            self.total_processing_time += processing_time

            # Check if we have a good match - using reduced threshold
            if best_match and best_similarity >= min_similarity:
                self.successful_requests += 1
                return {
                    "success": True,
                    "person_id": best_match,
                    "similarity": float(best_similarity),
                    "processing_time": processing_time
                }
            else:
                return {
                    "success": False,
                    "message": "No match found",
                    "best_similarity": float(best_similarity) if best_match else 0,
                    "processing_time": processing_time
                }
        except Exception as e:
            logger.error(f"Error identifying face: {e}")
            logger.error(traceback.format_exc())

            # Update metrics
            processing_time = time.time() - start_time
            self.total_processing_time += processing_time

            return {
                "success": False,
                "message": f"Error: {str(e)}",
                "processing_time": processing_time
            }

    def register_face(self, image: np.ndarray, person_id: str) -> Dict[str, Any]:
        """
        Register a face in the database

        Args:
            image: The image as a numpy array
            person_id: Unique identifier for the person

        Returns:
            Dictionary with registration results
        """
        # Update metrics
        self.total_requests += 1
        start_time = time.time()

        try:
            # Convert to grayscale
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

            # Detect faces
            faces = self.face_cascade.detectMultiScale(
                gray,
                scaleFactor=1.1,
                minNeighbors=5,
                minSize=(30, 30),
                flags=cv2.CASCADE_SCALE_IMAGE
            )

            # No faces detected
            if len(faces) == 0:
                return {
                    "success": False,
                    "message": "No faces detected",
                    "processing_time": time.time() - start_time
                }

            # Use the largest face
            largest_face = max(faces, key=lambda rect: rect[2] * rect[3])
            x, y, w, h = largest_face

            # Extract face ROI and normalize
            face_roi = gray[y:y+h, x:x+w]
            face_roi = cv2.resize(face_roi, (100, 100))
            face_roi = cv2.equalizeHist(face_roi)

            # Flatten the face for storage
            face_vector = face_roi.flatten().astype(np.float32)
            face_vector = face_vector / np.linalg.norm(face_vector)

            # Save to database
            self.face_database[person_id] = face_vector
            np.save(os.path.join("face_db", f"{person_id}.npy"), face_vector)

            # Update metrics
            processing_time = time.time() - start_time
            self.total_processing_time += processing_time
            self.successful_requests += 1

            return {
                "success": True,
                "person_id": person_id,
                "processing_time": processing_time
            }
        except Exception as e:
            logger.error(f"Error registering face: {e}")
            logger.error(traceback.format_exc())

            # Update metrics
            processing_time = time.time() - start_time
            self.total_processing_time += processing_time

            return {
                "success": False,
                "message": f"Error: {str(e)}",
                "processing_time": processing_time
            }

    def get_metrics(self) -> Dict[str, Any]:
        """
        Get performance metrics

        Returns:
            Dictionary with performance metrics
        """
        uptime = (datetime.now() - self.start_time).total_seconds()

        return {
            "total_requests": self.total_requests,
            "successful_requests": self.successful_requests,
            "success_rate": self.successful_requests / max(1, self.total_requests),
            "average_processing_time": self.total_processing_time / max(1, self.total_requests),
            "uptime": uptime,
            "uptime_formatted": self._format_uptime(uptime),
            "face_database_size": len(self.face_database)
        }

    def _format_uptime(self, seconds: float) -> str:
        """Format uptime in a human-readable format"""
        days, remainder = divmod(int(seconds), 86400)
        hours, remainder = divmod(remainder, 3600)
        minutes, seconds = divmod(remainder, 60)

        if days > 0:
            return f"{days}d {hours}h {minutes}m {seconds}s"
        elif hours > 0:
            return f"{hours}h {minutes}m {seconds}s"
        elif minutes > 0:
            return f"{minutes}m {seconds}s"
        else:
            return f"{seconds}s"

    def decode_base64_image(self, base64_string: str) -> np.ndarray:
        """Decode a base64 string to an image"""
        try:
            # Remove data URL prefix if present
            if ',' in base64_string:
                base64_string = base64_string.split(',')[1]

            # Decode base64 string
            image_data = base64.b64decode(base64_string)

            # Convert to numpy array
            nparr = np.frombuffer(image_data, np.uint8)

            # Decode image
            image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

            return image
        except Exception as e:
            logger.error(f"Error decoding base64 image: {e}")
            raise

class EnhancedAndroidWebSocketServer:
    """Enhanced WebSocket server for Android face recognition"""

    def __init__(self, host: str = "0.0.0.0", port: int = 5001):
        """Initialize the server"""
        self.host = host
        self.port = port
        self.detector = EnhancedAndroidFaceDetector()
        self.clients = set()
        self.start_time = datetime.now()

        # Import websockets here to avoid import errors if not available
        try:
            import websockets
            self.websockets = websockets
            logger.info("WebSockets module available")
        except ImportError:
            logger.error("WebSockets module not available. Please install with: pip install websockets")
            sys.exit(1)

        # Set up signal handlers for graceful shutdown
        signal.signal(signal.SIGINT, self._signal_handler)
        signal.signal(signal.SIGTERM, self._signal_handler)

    def _signal_handler(self, sig, frame):
        """Handle signals for graceful shutdown"""
        logger.info(f"Received signal {sig}, shutting down...")
        sys.exit(0)

    async def handle_client(self, websocket):
        """Handle a client connection"""
        client_info = f"{websocket.remote_address[0]}:{websocket.remote_address[1]}"
        logger.info(f"New client connected: {client_info}")

        # Add client to set
        self.clients.add(websocket)
        try:
            async for message in websocket:
                try:
                    # Parse message
                    data = json.loads(message)
                    message_type = data.get("type", "")

                    # Handle different message types
                    if message_type == "ping":
                        # Ping message
                        await websocket.send(json.dumps({
                            "type": "pong",
                            "time": datetime.now().isoformat(),
                            "metrics": self.detector.get_metrics()
                        }))

                    elif message_type == "detect_faces":
                        # Decode image
                        image = self.detector.decode_base64_image(data.get("image", ""))

                        # Get parameters
                        min_confidence = float(data.get("min_confidence", 0.5))

                        # Detect faces
                        start_time = time.time()
                        faces = self.detector.detect_faces(image, min_confidence)
                        processing_time = time.time() - start_time

                        # Send response
                        await websocket.send(json.dumps({
                            "type": "faces_detected",
                            "faces": faces,
                            "processing_time": processing_time,
                            "model": "enhanced_haar",
                            "metrics": self.detector.get_metrics()
                        }))

                    elif message_type == "identify_face":
                        # Decode image
                        image = self.detector.decode_base64_image(data.get("image", ""))

                        # Get parameters
                        min_similarity = float(data.get("min_similarity", 0.4))

                        # Identify face
                        result = self.detector.identify_face(image, min_similarity)

                        # Send response
                        await websocket.send(json.dumps({
                            "type": "face_identified",
                            "result": result,
                            "metrics": self.detector.get_metrics()
                        }))

                    elif message_type == "register_face":
                        # Decode image
                        image = self.detector.decode_base64_image(data.get("image", ""))

                        # Get parameters
                        person_id = data.get("person_id", "")

                        if not person_id:
                            await websocket.send(json.dumps({
                                "type": "error",
                                "message": "Missing person_id parameter"
                            }))
                            continue

                        # Register face
                        result = self.detector.register_face(image, person_id)

                        # Send response
                        await websocket.send(json.dumps({
                            "type": "face_registered",
                            "result": result,
                            "metrics": self.detector.get_metrics()
                        }))

                    elif message_type == "compare_faces":
                        # Decode images
                        face1 = self.detector.decode_base64_image(data.get("face1", ""))
                        face2 = self.detector.decode_base64_image(data.get("face2", ""))

                        # Compare faces
                        start_time = time.time()
                        result = self.detector.compare_faces(face1, face2)
                        processing_time = time.time() - start_time

                        # Send response
                        await websocket.send(json.dumps({
                            "type": "faces_compared",
                            "result": result,
                            "processing_time": processing_time,
                            "metrics": self.detector.get_metrics()
                        }))

                    elif message_type == "get_metrics":
                        # Get metrics
                        metrics = self.detector.get_metrics()

                        # Add server metrics
                        server_uptime = (datetime.now() - self.start_time).total_seconds()
                        metrics["server_uptime"] = server_uptime
                        metrics["server_uptime_formatted"] = self.detector._format_uptime(server_uptime)
                        metrics["connected_clients"] = len(self.clients)

                        # Send response
                        await websocket.send(json.dumps({
                            "type": "metrics",
                            "metrics": metrics
                        }))

                    else:
                        # Unknown message type
                        await websocket.send(json.dumps({
                            "type": "error",
                            "message": f"Unknown message type: {message_type}"
                        }))

                except json.JSONDecodeError:
                    # Invalid JSON
                    await websocket.send(json.dumps({
                        "type": "error",
                        "message": "Invalid JSON"
                    }))

                except Exception as e:
                    # Other errors
                    logger.error(f"Error handling message: {e}")
                    logger.error(traceback.format_exc())
                    await websocket.send(json.dumps({
                        "type": "error",
                        "message": str(e)
                    }))

        except Exception as e:
            # Connection closed or other error
            logger.info(f"Connection closed or error: {e}")

        finally:
            # Remove client from set
            self.clients.remove(websocket)
            logger.info(f"Client disconnected: {client_info}")

    async def start(self):
        """Start the WebSocket server"""
        server = await self.websockets.serve(
            self.handle_client,
            self.host,
            self.port
        )

        logger.info(f"Server running at ws://{self.host}:{self.port}")
        logger.info(f"Server version: {SERVER_VERSION}")
        logger.info("Available models: enhanced_haar")

        # Print server info
        print(f"Server is running at ws://{self.host}:{self.port}")
        print(f"Press Ctrl+C to stop the server")

        await server.wait_closed()

def main():
    """Main function"""
    # Print banner
    print(f"""
    ╔═══════════════════════════════════════════════════╗
    ║ Enhanced Android Face Recognition Server v{SERVER_VERSION}    ║
    ║ For NAFacial App                                  ║
    ╚═══════════════════════════════════════════════════╝
    """)

    # Get port from command line arguments
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 5001

    # Create and start server
    server = EnhancedAndroidWebSocketServer(port=port)

    # Run server
    asyncio.run(server.start())

if __name__ == "__main__":
    main()
