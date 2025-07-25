#!/usr/bin/env python3
"""
Python client example for the Prometheus Obfuscator API

This script demonstrates how to connect to the obfuscation API from Python.
You can integrate this into your Discord bot or any other Python application.
"""

import requests
import json
import os
from typing import Optional, Dict, Any

class PrometheusObfuscatorClient:
    """Client for the Prometheus Obfuscator API"""
    
    def __init__(self, base_url: str = "http://localhost:3000"):
        """
        Initialize the client
        
        Args:
            base_url: The base URL of the API server
        """
        self.base_url = base_url.rstrip('/')
        
    def health_check(self) -> Dict[str, Any]:
        """
        Check if the API server is running
        
        Returns:
            Dict containing health status
        """
        try:
            response = requests.get(f"{self.base_url}/health")
            response.raise_for_status()
            return response.json()
        except requests.RequestException as e:
            return {"error": str(e)}
    
    def get_presets(self) -> Dict[str, Any]:
        """
        Get available obfuscation presets
        
        Returns:
            Dict containing available presets
        """
        try:
            response = requests.get(f"{self.base_url}/presets")
            response.raise_for_status()
            return response.json()
        except requests.RequestException as e:
            return {"error": str(e)}
    
    def obfuscate_file(self, file_path: str, preset: str = "Medium") -> Dict[str, Any]:
        """
        Obfuscate a Lua file
        
        Args:
            file_path: Path to the .lua file to obfuscate
            preset: Obfuscation preset ("Weak", "Medium", "Strong", "Minify")
            
        Returns:
            Dict containing obfuscated code or error
        """
        if not os.path.exists(file_path):
            return {"error": f"File not found: {file_path}"}
        
        if not file_path.lower().endswith('.lua'):
            return {"error": "File must have .lua extension"}
        
        try:
            with open(file_path, 'rb') as f:
                files = {'file': (os.path.basename(file_path), f, 'text/plain')}
                data = {'preset': preset}
                
                response = requests.post(
                    f"{self.base_url}/obfuscate",
                    files=files,
                    data=data
                )
                response.raise_for_status()
                return response.json()
        except requests.RequestException as e:
            return {"error": str(e)}
    
    def obfuscate_code(self, lua_code: str, preset: str = "Medium") -> Dict[str, Any]:
        """
        Obfuscate Lua code directly
        
        Args:
            lua_code: The Lua code to obfuscate
            preset: Obfuscation preset ("Weak", "Medium", "Strong", "Minify")
            
        Returns:
            Dict containing obfuscated code or error
        """
        try:
            data = {
                'code': lua_code,
                'preset': preset
            }
            
            response = requests.post(
                f"{self.base_url}/obfuscate-text",
                json=data,
                headers={'Content-Type': 'application/json'}
            )
            response.raise_for_status()
            return response.json()
        except requests.RequestException as e:
            return {"error": str(e)}


def main():
    """Example usage of the PrometheusObfuscatorClient"""
    
    # Initialize the client
    client = PrometheusObfuscatorClient("http://localhost:3000")
    
    # Check if the API is running
    print("ðŸ” Checking API health...")
    health = client.health_check()
    if "error" in health:
        print(f"âŒ API is not running: {health['error']}")
        print("ðŸ’¡ Make sure to start the API server with: npm run dev:api")
        return
    else:
        print(f"âœ… {health['message']}")
    
    # Get available presets
    print("\nðŸ“‹ Getting available presets...")
    presets = client.get_presets()
    if "error" in presets:
        print(f"âŒ Error getting presets: {presets['error']}")
        return
    else:
        print(f"âœ… Available presets: {', '.join(presets['presets'])}")
    
    # Example 1: Obfuscate code directly
    print("\nðŸ”§ Example 1: Obfuscating code directly...")
    lua_code = """
-- Simple Lua script
local function greet(name)
    print("Hello, " .. name .. "!")
end

greet("World")
"""
    
    result = client.obfuscate_code(lua_code, "Medium")
    if "error" in result:
        print(f"âŒ Obfuscation failed: {result['error']}")
    else:
        print(f"âœ… Obfuscation successful with {result['preset']} preset")
        print("ðŸ“„ Obfuscated code:")
        print("-" * 50)
        print(result['obfuscatedCode'])
        print("-" * 50)
    
    # Example 2: Obfuscate a file (if it exists)
    print("\nðŸ”§ Example 2: Obfuscating a file...")
    test_file = "test_script.lua"
    
    # Create a test file
    with open(test_file, 'w') as f:
        f.write(lua_code)
    
    result = client.obfuscate_file(test_file, "Strong")
    if "error" in result:
        print(f"âŒ File obfuscation failed: {result['error']}")
    else:
        print(f"âœ… File obfuscation successful with {result['preset']} preset")
        print(f"ðŸ“ Original file: {result['originalFilename']}")
        
        # Save obfuscated code to a new file
        obfuscated_file = "obfuscated_" + test_file
        with open(obfuscated_file, 'w') as f:
            f.write(result['obfuscatedCode'])
        print(f"ðŸ’¾ Obfuscated code saved to: {obfuscated_file}")
    
    # Clean up
    if os.path.exists(test_file):
        os.remove(test_file)


# Discord bot integration example
def discord_bot_example():
    """
    Example of how to integrate this into a Discord bot
    """
    # This is pseudo-code showing how you might use it in a Discord bot
    
    client = PrometheusObfuscatorClient("http://localhost:3000")
    
    # In your Discord bot command handler:
    async def obfuscate_command(ctx, preset="Medium"):
        # Get the attached file from Discord message
        if not ctx.message.attachments:
            await ctx.send("Please attach a .lua file!")
            return
        
        attachment = ctx.message.attachments[0]
        if not attachment.filename.endswith('.lua'):
            await ctx.send("Please attach a .lua file!")
            return
        
        # Download the file content
        file_content = await attachment.read()
        lua_code = file_content.decode('utf-8')
        
        # Obfuscate the code
        result = client.obfuscate_code(lua_code, preset)
        
        if "error" in result:
            await ctx.send(f"âŒ Obfuscation failed: {result['error']}")
        else:
            # Send back the obfuscated code as a file
            import io
            obfuscated_file = io.BytesIO(result['obfuscatedCode'].encode('utf-8'))
            await ctx.send(
                f"âœ… Obfuscated with {result['preset']} preset!",
                file=discord.File(obfuscated_file, filename=f"obfuscated_{attachment.filename}")
            )


if __name__ == "__main__":
    main()
