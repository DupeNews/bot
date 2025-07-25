"""
ðŸš€ Simple Discord Bot Integration for Prometheus Obfuscator

Copy this code into your existing Discord bot to add Lua obfuscation features.
Make sure the Prometheus API is running on http://localhost:3000

Required: pip install requests discord.py
"""

import requests
import io
import discord
from discord.ext import commands

class PrometheusObfuscatorClient:
    """Simple client for the Prometheus Obfuscator API"""
    
    def __init__(self, base_url="http://localhost:3000"):
        self.base_url = base_url.rstrip('/')
    
    def health_check(self):
        """Check if API is running"""
        try:
            response = requests.get(f"{self.base_url}/health", timeout=5)
            return response.status_code == 200
        except:
            return False
    
    def get_presets(self):
        """Get available presets"""
        try:
            response = requests.get(f"{self.base_url}/presets", timeout=5)
            if response.status_code == 200:
                return response.json().get('presets', [])
        except:
            pass
        return ["Weak", "Medium", "Strong", "Minify"]  # fallback
    
    def obfuscate_code(self, lua_code, preset="Medium"):
        """Obfuscate Lua code"""
        try:
            data = {'code': lua_code, 'preset': preset}
            response = requests.post(
                f"{self.base_url}/obfuscate-text",
                json=data,
                headers={'Content-Type': 'application/json'},
                timeout=30
            )
            response.raise_for_status()
            return response.json()
        except requests.RequestException as e:
            return {"error": str(e)}

# Initialize the obfuscator client
obfuscator = PrometheusObfuscatorClient("http://localhost:3000")

# Add these commands to your existing bot

@commands.command(name='obfuscate', aliases=['obf'])
async def obfuscate_lua(ctx, preset="Medium"):
    """
    Obfuscate a Lua file
    Usage: !obfuscate [preset]
    Attach a .lua file to your message
    """
    
    # Check if API is running
    if not obfuscator.health_check():
        embed = discord.Embed(
            title="âŒ API Offline",
            description="The obfuscation API is not running. Please contact an administrator.",
            color=discord.Color.red()
        )
        await ctx.send(embed=embed)
        return
    
    # Check for file attachment
    if not ctx.message.attachments:
        embed = discord.Embed(
            title="âŒ No File Attached",
            description="Please attach a `.lua` file to obfuscate!",
            color=discord.Color.red()
        )
        embed.add_field(
            name="Usage", 
            value="`!obfuscate [preset]`\nPresets: Weak, Medium, Strong, Minify", 
            inline=False
        )
        await ctx.send(embed=embed)
        return
    
    attachment = ctx.message.attachments[0]
    
    # Validate file
    if not attachment.filename.lower().endswith('.lua'):
        embed = discord.Embed(
            title="âŒ Invalid File Type",
            description="Please attach a `.lua` file!",
            color=discord.Color.red()
        )
        await ctx.send(embed=embed)
        return
    
    if attachment.size > 40000:  # 40KB limit
        embed = discord.Embed(
            title="âŒ File Too Large",
            description="File size must be under 40KB!",
            color=discord.Color.red()
        )
        await ctx.send(embed=embed)
        return
    
    # Validate preset
    valid_presets = obfuscator.get_presets()
    if preset not in valid_presets:
        embed = discord.Embed(
            title="âŒ Invalid Preset",
            description=f"Valid presets: {', '.join(valid_presets)}",
            color=discord.Color.red()
        )
        await ctx.send(embed=embed)
        return
    
    # Processing message
    processing_embed = discord.Embed(
        title="ðŸ”„ Processing...",
        description=f"Obfuscating `{attachment.filename}` with **{preset}** preset...",
        color=discord.Color.orange()
    )
    processing_msg = await ctx.send(embed=processing_embed)
    
    try:
        # Download and decode file
        file_content = await attachment.read()
        lua_code = file_content.decode('utf-8')
        
        # Obfuscate
        result = obfuscator.obfuscate_code(lua_code, preset)
        
        if "error" in result:
            # Error occurred
            error_embed = discord.Embed(
                title="âŒ Obfuscation Failed",
                description=f"Error: {result['error']}",
                color=discord.Color.red()
            )
            await processing_msg.edit(embed=error_embed)
        else:
            # Success!
            obfuscated_content = result['obfuscatedCode']
            obfuscated_file = io.BytesIO(obfuscated_content.encode('utf-8'))
            
            success_embed = discord.Embed(
                title="âœ… Obfuscation Complete!",
                description=f"Successfully obfuscated with **{preset}** preset",
                color=discord.Color.green()
            )
            success_embed.add_field(name="Original File", value=attachment.filename, inline=True)
            success_embed.add_field(name="Preset Used", value=preset, inline=True)
            success_embed.add_field(
                name="Size Change", 
                value=f"{len(lua_code)} â†’ {len(obfuscated_content)} chars", 
                inline=True
            )
            
            await processing_msg.edit(embed=success_embed)
            await ctx.send(
                file=discord.File(
                    obfuscated_file, 
                    filename=f"obfuscated_{attachment.filename}"
                )
            )
            
    except UnicodeDecodeError:
        error_embed = discord.Embed(
            title="âŒ File Encoding Error",
            description="Could not read the file. Make sure it's a valid UTF-8 text file.",
            color=discord.Color.red()
        )
        await processing_msg.edit(embed=error_embed)
        
    except Exception as e:
        error_embed = discord.Embed(
            title="âŒ Unexpected Error",
            description=f"An error occurred: {str(e)}",
            color=discord.Color.red()
        )
        await processing_msg.edit(embed=error_embed)

@commands.command(name='presets')
async def show_presets(ctx):
    """Show available obfuscation presets"""
    
    presets = obfuscator.get_presets()
    
    embed = discord.Embed(
        title="ðŸ”§ Available Obfuscation Presets",
        color=discord.Color.blue()
    )
    
    preset_descriptions = {
        "Minify": "Basic minification without obfuscation",
        "Weak": "Light obfuscation with VM and constant arrays",
        "Medium": "Moderate obfuscation with string encryption",
        "Strong": "Heavy obfuscation with multiple VM layers"
    }
    
    for preset in presets:
        description = preset_descriptions.get(preset, "Advanced obfuscation preset")
        embed.add_field(name=preset, value=description, inline=False)
    
    embed.add_field(
        name="Usage", 
        value="`!obfuscate [preset]` - Attach a .lua file", 
        inline=False
    )
    
    await ctx.send(embed=embed)

@commands.command(name='obf_status')
async def obfuscator_status(ctx):
    """Check obfuscation API status"""
    
    if obfuscator.health_check():
        embed = discord.Embed(
            title="âœ… Obfuscator Online",
            description="The Prometheus Obfuscator API is running and ready!",
            color=discord.Color.green()
        )
        embed.add_field(name="API URL", value=obfuscator.base_url, inline=False)
    else:
        embed = discord.Embed(
            title="âŒ Obfuscator Offline",
            description="The obfuscation API is not responding.",
            color=discord.Color.red()
        )
        embed.add_field(
            name="ðŸ’¡ Solution",
            value="Contact an administrator to start the API server.",
            inline=False
        )
    
    await ctx.send(embed=embed)

# If you want to add these commands to an existing bot, use:
# bot.add_command(obfuscate_lua)
# bot.add_command(show_presets)
# bot.add_command(obfuscator_status)

"""
ðŸ”§ SETUP INSTRUCTIONS:

1. Start the Prometheus API server:
   - Run: npm install && npm run build && npm run start:api
   - Or use Docker: docker-compose up prometheus-api

2. Install Python dependencies:
   - pip install requests discord.py

3. Copy the commands above into your Discord bot

4. Test with:
   - !obf_status (check if API is running)
   - !presets (see available options)
   - !obfuscate Medium (attach a .lua file)

ðŸŽ‰ Your bot now has Lua obfuscation capabilities!
"""
