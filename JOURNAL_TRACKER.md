# Journal Article Tracker

A Feedly-like page to track and display articles from your favorite scientific journals. Articles are automatically fetched from RSS feeds and updated daily via GitHub Actions.

## How It Works

### 1. **Configuration** (`_data/journals.yml`)
Defines the list of journals to track, including:
- Journal name
- Journal website URL
- RSS feed URL
- Display color

Add or remove journals by editing this file.

### 2. **RSS Feed Fetcher** (`scripts/fetch_articles.rb`)
Ruby script that:
- Reads the journals configuration
- Fetches articles from each journal's RSS feed
- Extracts title, authors, publication date, and description
- Saves articles to `_data/articles.yml` (max 20 articles per journal)
- Sorts articles by date (newest first)

### 3. **GitHub Actions Workflow** (`.github/workflows/fetch-articles.yml`)
Automated CI/CD pipeline that:
- **Runs daily at 12:00 PM UTC** (customizable via cron syntax)
- Can also be triggered manually via GitHub's UI
- Runs the fetch script
- Commits updated articles back to the repository
- Automatically triggers Jekyll to rebuild your site

### 4. **Display Page** (`_pages/journal-tracker.md`)
Jekyll page that:
- Renders articles grouped by journal
- Shows title, authors, publication date
- Links to the full article
- Updates automatically when articles are fetched

## Setup Instructions

### First Time Setup
1. Push this code to your GitHub repository
2. Ensure GitHub Actions is enabled (Settings → Actions)
3. The workflow will run automatically on schedule OR you can manually trigger it:
   - Go to Actions → "Fetch Journal Articles" → Run workflow

### To Test Manually
On GitHub:
1. Go to **Actions** tab
2. Select **"Fetch Journal Articles"** workflow
3. Click **"Run workflow"** button
4. Wait for it to complete and check for commits

### To Add/Remove Journals
Edit `_data/journals.yml`:
```yaml
- name: "Journal Name"
  url: "https://journal-website.com"
  feed: "https://journal-website.com/rss.xml"
  color: "#FF6B6B"
```

Find RSS feed URLs by looking for RSS/Atom links on journal homepages.

### To Change Update Schedule
Edit `.github/workflows/fetch-articles.yml`, line with cron:
```yaml
- cron: '0 12 * * *'  # Daily at 12:00 PM UTC
```

[Cron syntax reference](https://crontab.guru/)

## File Structure
```
.github/
└── workflows/
    └── fetch-articles.yml      # GitHub Actions workflow
_data/
├── journals.yml                # Journal configuration
└── articles.yml                # Generated article data
_pages/
└── journal-tracker.md          # Display page
scripts/
└── fetch_articles.rb           # RSS fetching script
```

## Troubleshooting

### Articles not updating?
1. Check **Actions** tab for workflow errors
2. Verify RSS feed URLs are correct and accessible
3. Try running workflow manually to see error messages

### Missing articles?
- Some journals may have feeds that don't include all metadata
- The script extracts up to 3 authors per article
- Articles are limited to 20 most recent from each journal

### Page shows "Articles are loading"?
- The workflow hasn't run yet
- Manually trigger it via Actions tab
- Wait for the workflow to complete

## Dependencies
The GitHub Actions workflow automatically installs Ruby and required gems. No additional setup needed on your end.
