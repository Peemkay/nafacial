%USERPROFILE%\.vscode-augment-cacheimport asyncio
import websockets
import json
import base64
import numpy as np
import cv2
from facial_auth_service import FacialAuthService

class FacialAuthServer:
    def __init__(self, host="localhost", port=8765):
        self.host = host
        self.port = port
        self.service = FacialAuthService()
        
    async def handle_client(self, websocket, path):
        """Handle WebSocket client connection"""
        try:
            async for message in websocket:
                try:
                    data = json.loads(message)
                    command = data.get('command')
                    
                    if command == 'verify_face':
                        # Decode base64 image
                        image_data = data['image'].split(',')[1] if ',' in data['image'] else data['image']
                        image_bytes = base64.b64decode(image_data)
                        nparr = np.frombuffer(image_bytes, np.uint8)
                        image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
                        
                        # Verify face
                        result = await self.service.verify_face(
                            image,
                            data.get('user_id')
                        )
                        
                        await websocket.send(json.dumps(result))
                        
                    elif command == 'register_face':
                        # Decode base64 image
                        image_data = data['image'].split(',')[1] if ',' in data['image'] else data['image']
                        image_bytes = base64.b64decode(image_data)
                        nparr = np.frombuffer(image_bytes, np.uint8)
                        image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
                        
                        # Register face
                        result = await self.service.register_face(
                            image,
                            data.get('user_id')
                        )
                        
                        await websocket.send(json.dumps(result))
                    
                    else:
                        await websocket.send(json.dumps({
                            'success': False,
                            'message': f'Unknown command: {command}'
                        }))
                        
                except json.JSONDecodeError:
                    await websocket.send(json.dumps({
                        'success': False,
                        'message': 'Invalid JSON'
                    }))
                    
        except websockets.exceptions.ConnectionClosed:
            pass
            
    async def start(self):
        """Start the WebSocket server"""
        server = await websockets.serve(
            self.handle_client,
            self.host,
            self.port
        )
        
        print(f"Server running at ws://{self.host}:{self.port}")
        await server.wait_closed()

if __name__ == "__main__":
    server = FacialAuthServer()
    asyncio.run(server.start())