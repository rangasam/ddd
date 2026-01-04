# Quick Start Guide

Get your Docker Deep Dive WordPress environment running in 3 minutes!

## Step 1: Set Up Environment (30 seconds)

```bash
cp .env.example .env
```

That's it! The defaults work out of the box.

## Step 2: Start Docker Containers (1-2 minutes)

```bash
docker compose up -d
```

Wait for the images to download and containers to start. You'll see:
```
✔ Network ddd_wordpress_network  Created
✔ Volume "ddd_db_data"           Created
✔ Container ddd_mysql            Started
✔ Container ddd_wordpress        Started
✔ Container ddd_phpmyadmin       Started
```

## Step 3: Access WordPress (30 seconds)

Open your browser and go to:
- **WordPress**: http://localhost:8080

Follow the 5-minute WordPress installation wizard:
1. Choose your language
2. Enter site title (e.g., "My Docker Site")
3. Create admin username and password
4. Enter your email
5. Click "Install WordPress"

## You're Done! 🎉

Your WordPress site is now running in Docker!

### What's Next?

- **Develop Your Site**: Start creating pages, posts, and customizing themes
- **Manage Database**: Access phpMyAdmin at http://localhost:8081
- **Add Plugins**: They'll be saved in `./wp-content/plugins/`
- **Customize Themes**: Find them in `./wp-content/themes/`

### Useful Commands

Stop the environment:
```bash
docker compose down
```

Start it again:
```bash
docker compose up -d
```

View logs:
```bash
docker compose logs -f wordpress
```

### Need Help?

Check the [full README](README.md) for detailed documentation, troubleshooting, and advanced usage.
