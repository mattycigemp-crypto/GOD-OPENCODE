# {{PROJECT_NAME}} - Discord Bot

## Purpose

A production-ready Discord bot built with discord.py, featuring slash commands, event handlers, persistent storage, and modular cog architecture.

## Prerequisites

- Python 3.11+
- A Discord application with bot token (create at https://discord.com/developers/applications)
- uv

## Setup

1. **Install dependencies**
   ```bash
   uv venv && source .venv/bin/activate
   uv pip install -r requirements.txt
   ```

2. **Configure environment variables**
   ```bash
   cp .env.example .env
   # Set DISCORD_TOKEN and DISCORD_GUILD_ID
   ```

3. **Invite the bot to your server**
   - Enable the `bot` and `applications.commands` scopes in the OAuth2 URL generator.
   - Add the required permissions (read messages, send messages, use slash commands).

4. **Run the bot**
   ```bash
   python bot.py
   ```

## Project Structure

```
bot.py              # Bot entry point
cogs/               # Command group modules
  general.py        # General commands
  moderation.py     # Moderation commands
utils/              # Helper utilities
data/               # Persistent data storage
tests/              # Test suite
.env.example        # Environment variables template
```

## Adding a Command

Create a new cog in `cogs/`:

```python
from discord.ext import commands
from discord import app_commands

class MyCog(commands.Cog):
    @app_commands.command(name="hello", description="Says hello")
    async def hello(self, interaction: discord.Interaction):
        await interaction.response.send_message("Hello!")

async def setup(bot):
    await bot.add_cog(MyCog(bot))
```

## Running Tests

```bash
pytest tests/ -v
```

## Dependencies

- discord.py - Discord API wrapper
- python-dotenv - environment configuration
- aiosqlite - async SQLite for persistence
- pytest, pytest-asyncio - testing

