#!/usr/bin/env python3
"""
Complete Discord bot integration example for Prometheus Obfuscator API

This is a full Discord bot that uses the Prometheus Obfuscator API to obfuscate Lua files.
Replace 'YOUR_BOT_TOKEN' with your actual Discord bot token.

Requirements:
pip install discord.py requests aiohttp
"""

import discord
from discord.ext import commands
import requests
import aiohttp
import asyncio
import io
import os
from typing import Optional

# Configuration
API_BASE_URL = "http://localhost:3000"  # Change this if your API is hosted elsewhere
BOT_TOKEN = "YOUR_BOT_TOKEN"  # Replace with your Discord bot token

class PrometheusObfuscatorBot(commands.Bot):
    def __init__(self):
        intents = discord.Intents.default()
        intents.message_content = True
        super().__init__(command_prefix='!', intents=intents)
        
    async def setup_hook(self):
        """Called when the bot is starting up"""
        print(f"ðŸ¤– {self.user} is starting up...")
        
        # Check if API is available
        try:
            async with aiohttp.ClientSession() as session:
                async with session.get(f"{API_BASE_URL}/health") as response:
                    if response.status == 200:
                        data = await response.json()
                        print(f"âœ… API is available: {data['message']}")
                    else:
                        print(f"âš ï¸ API returned status {response.status}")
        except Exception as e:
            print(f"âŒ Cannot connect to API: {e}")
            print("ðŸ’¡ Make sure the Prometheus API is running on http://localhost:3000")

bot = PrometheusObfuscatorBot()

@bot.event
async def on_ready():
    print(f"ðŸš€ {bot.user} is now online!")
    print(f"ðŸ“Š Connected to {len(bot.guilds)} servers")

@bot.command(name='obfuscate', aliases=['obf'])
async def obfuscate_command(ctx, preset: str = "Medium"):
    """
    Obfuscate a Lua file
    
    Usage: !obfuscate [preset]
    Presets: Weak, Medium, Strong, Minify
    
    Attach a .lua file to your message.
    """
    
    # Check if file is attached
    if not ctx.message.attachments:
        embed = discord.Embed(
            title="âŒ No File Attached",
            description="Please attach a `.lua` file to obfuscate!",
            color=discord.Color.red()
        )
        await ctx.send(embed=embed)
        return
    
    attachment = ctx.message.attachments[0]
    
    # Check file extension
    if not attachment.filename.lower().endswith('.lua'):
        embed = discord.Embed(
            title="âŒ Invalid File Type",
            description="Please attach a `.lua` file!",
            color=discord.Color.red()
        )
        await ctx.send(embed=embed)
        return
    
    # Check file size (40KB limit)
    if attachment.size > 40000:
        embed = discord.Embed(
            title="âŒ File Too Large",
            description="File size must be under 40KB!",
            color=discord.Color.red()
        )
        await ctx.send(embed=embed)
        return
    
    # Validate preset
    valid_presets = ["Weak", "Medium", "Strong", "Minify"]
    if preset not in valid_presets:
        embed = discord.Embed(
            title="âŒ Invalid Preset",
            description=f"Valid presets: {', '.join(valid_presets)}",
            color=discord.Color.red()
        )
        await ctx.send(embed=embed)
        return
    
    # Send processing message
    processing_embed = discord.Embed(
        title="ðŸ”„ Processing...",
        description=f"Obfuscating `{attachment.filename}` with **{preset}** preset...",
        color=discord.Color.orange()
    )
    processing_msg = await ctx.send(embed=processing_embed)
    
    try:
        # Download file content
        file_content = await attachment.read()
        lua_code = file_content.decode('utf-8')
        
        # Send to API
        async with aiohttp.ClientSession() as session:
            data = {
                'code': lua_code,
                'preset': preset
            }
            
            async with session.post(f"{API_BASE_URL}/obfuscate-text", json=data) as response:
                if response.status == 200:
                    result = await response.json()
                    
                    # Create obfuscated file
                    obfuscated_content = result['obfuscatedCode']
                    obfuscated_file = io.BytesIO(obfuscated_content.encode('utf-8'))
                    
                    # Success embed
                    success_embed = discord.Embed(
                        title="âœ… Obfuscation Complete!",
                        description=f"Successfully obfuscated with **{preset}** preset",
                        color=discord.Color.green()
                    )
                    success_embed.add_field(
                        name="Original File", 
                        value=attachment.filename, 
                        inline=True
                    )
                    success_embed.add_field(
                        name="Preset Used", 
                        value=preset, 
                        inline=True
                    )
                    
                    # Send result
                    await processing_msg.edit(embed=success_embed)
                    await ctx.send(
                        file=discord.File(
                            obfuscated_file, 
                            filename=f"obfuscated_{attachment.filename}"
                        )
                    )
                    
                else:
                    error_data = await response.json()
                    error_embed = discord.Embed(
                        title="âŒ Obfuscation Failed",
                        description=f"Error: {error_data.get('error', 'Unknown error')}",
                        color=discord.Color.red()
                    )
                    await processing_msg.edit(embed=error_embed)
                    
    except UnicodeDecodeError:
        error_embed = discord.Embed(
            title="âŒ File Encoding Error",
            description="Could not read the file. Make sure it's a valid text file.",
            color=discord.Color.red()
        )
        await processing_msg.edit(embed=error_embed)
        
    except Exception as e:
        error_embed = discord.Embed(
            title="âŒ Error",
            description=f"An error occurred: {str(e)}",
            color=discord.Color.red()
        )
        await processing_msg.edit(embed=error_embed)

@bot.command(name='presets')
async def presets_command(ctx):
    """Show available obfuscation presets"""
    
    try:
        async with aiohttp.ClientSession() as session:
            async with session.get(f"{API_BASE_URL}/presets") as response:
                if response.status == 200:
                    data = await response.json()
                    presets = data['presets']
                    
                    embed = discord.Embed(
                        title="ðŸ”§ Available Presets",
                        color=discord.Color.blue()
                    )
                    
                    preset_descriptions = {
                        "Minify": "Basic minification without obfuscation",
                        "Weak": "Light obfuscation with VM and constant arrays",
                        "Medium": "Moderate obfuscation with string encryption",
                        "Strong": "Heavy obfuscation with multiple VM layers"
                    }
                    
                    for preset in presets:
                        description = preset_descriptions.get(preset, "No description available")
                        embed.add_field(
                            name=preset,
                            value=description,
                            inline=False
                        )
                    
                    await ctx.send(embed=embed)
                else:
                    await ctx.send("âŒ Could not fetch presets from API")
                    
    except Exception as e:
        await ctx.send(f"âŒ Error fetching presets: {str(e)}")

@bot.command(name='api_status', aliases=['status'])
async def api_status_command(ctx):
    """Check API server status"""
    
    try:
        async with aiohttp.ClientSession() as session:
            async with session.get(f"{API_BASE_URL}/health") as response:
                if response.status == 200:
                    data = await response.json()
                    embed = discord.Embed(
                        title="âœ… API Status",
                        description=data['message'],
                        color=discord.Color.green()
                    )
                    embed.add_field(name="URL", value=API_BASE_URL, inline=False)
                    await ctx.send(embed=embed)
                else:
                    embed = discord.Embed(
                        title="âš ï¸ API Status",
                        description=f"API returned status {response.status}",
                        color=discord.Color.orange()
                    )
                    await ctx.send(embed=embed)
                    
    except Exception as e:
        embed = discord.Embed(
            title="âŒ API Offline",
            description=f"Cannot connect to API: {str(e)}",
            color=discord.Color.red()
        )
        embed.add_field(
            name="ðŸ’¡ Solution",
            value="Make sure the Prometheus API is running on http://localhost:3000",
            inline=False
        )
        await ctx.send(embed=embed)

@bot.command(name='help_obfuscator', aliases=['obf_help'])
async def help_command(ctx):
    """Show help for obfuscator commands"""
    
    embed = discord.Embed(
        title="ðŸ¤– Prometheus Obfuscator Bot",
        description="Obfuscate your Lua files with ease!",
        color=discord.Color.blue()
    )
    
    embed.add_field(
        name="!obfuscate [preset]",
        value="Obfuscate a .lua file (attach file to message)\nExample: `!obfuscate Strong`",
        inline=False
    )
    
    embed.add_field(
        name="!presets",
        value="Show available obfuscation presets",
        inline=False
    )
    
    embed.add_field(
        name="!status",
        value="Check API server status",
        inline=False
    )
    
    embed.add_field(
        name="ðŸ“‹ Usage",
        value="1. Upload a .lua file\n2. Use `!obfuscate [preset]`\n3. Download the obfuscated result",
        inline=False
    )
    
    await ctx.send(embed=embed)

if __name__ == "__main__":
    if BOT_TOKEN == "YOUR_BOT_TOKEN":
        print("âŒ Please set your Discord bot token in the BOT_TOKEN variable!")
        print("ðŸ’¡ Get a token from: https://discord.com/developers/applications")
    else:
        print("ðŸ¤– Starting Discord bot...")
        bot.run(BOT_TOKEN)
