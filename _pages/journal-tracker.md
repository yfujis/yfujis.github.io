---
layout: single
title: "Journal Article Tracker"
permalink: /journal-tracker/
author_profile: true
read_time: false
comments: false
share: true
---

<style>
  .journal-section {
    margin-bottom: 3rem;
    background: #f8f9fa;
    padding: 2rem;
    border-radius: 8px;
    border-left: 4px solid #333;
  }

  .journal-section h2 {
    margin-top: 0;
    margin-bottom: 1.5rem;
    color: #333;
    font-size: 1.5rem;
  }

  .articles-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: 1.5rem;
  }

  .article-card {
    background: white;
    border-radius: 6px;
    padding: 1.5rem;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    transition: box-shadow 0.3s, transform 0.3s;
    display: flex;
    flex-direction: column;
  }

  .article-card:hover {
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
    transform: translateY(-2px);
  }

  .article-title {
    font-size: 1.1rem;
    font-weight: 600;
    margin: 0 0 0.75rem 0;
    line-height: 1.4;
  }

  .article-title a {
    color: #0066cc;
    text-decoration: none;
  }

  .article-title a:hover {
    text-decoration: underline;
  }

  .article-authors {
    font-size: 0.9rem;
    color: #666;
    margin-bottom: 0.5rem;
    font-style: italic;
  }

  .article-date {
    font-size: 0.85rem;
    color: #999;
    margin-bottom: 1rem;
  }

  .article-description {
    font-size: 0.9rem;
    color: #555;
    line-height: 1.5;
    margin-bottom: 1rem;
    flex-grow: 1;
  }

  .article-link {
    align-self: flex-start;
    padding: 0.5rem 1rem;
    background: #0066cc;
    color: white;
    text-decoration: none;
    border-radius: 4px;
    font-size: 0.9rem;
    transition: background 0.3s;
  }

  .article-link:hover {
    background: #0052a3;
  }

  .last-updated {
    text-align: center;
    color: #999;
    font-size: 0.9rem;
    margin-top: 3rem;
    padding-top: 2rem;
    border-top: 1px solid #ddd;
  }

  .no-articles {
    color: #999;
    text-align: center;
    padding: 2rem;
    background: white;
    border-radius: 6px;
  }
</style>

## Latest Articles from Your Favorite Journals

Track the latest research across your favorite scientific journals. Articles are fetched automatically and updated daily.

{% if site.data.articles.articles %}
  {% for journal_name in site.data.articles.articles %}
    {% assign journal_articles = site.data.articles.articles[journal_name] %}
    {% if journal_articles and journal_articles.size > 0 %}
    <div class="journal-section">
      <h2>{{ journal_name }} ({{ journal_articles.size }})</h2>
      <div class="articles-grid">
        {% for article in journal_articles %}
        <div class="article-card">
          <h3 class="article-title">
            <a href="{{ article.link }}" target="_blank" rel="noopener noreferrer">
              {{ article.title }}
            </a>
          </h3>
          {% if article.authors and article.authors.size > 0 %}
          <div class="article-authors">
            {{ article.authors | join: ", " }}
          </div>
          {% endif %}
          <div class="article-date">{{ article.published_date }}</div>
          {% if article.description and article.description.size > 0 %}
          <div class="article-description">{{ article.description | truncatewords: 30 }}</div>
          {% endif %}
          <a href="{{ article.link }}" target="_blank" rel="noopener noreferrer" class="article-link">
            Read Article →
          </a>
        </div>
        {% endfor %}
      </div>
    </div>
    {% endif %}
  {% endfor %}

  <div class="last-updated">
    <small>Last updated: {{ site.data.articles.last_updated }}</small>
  </div>
{% else %}
  <div class="no-articles">
    <p>Articles are loading... The GitHub Action will automatically fetch articles from all journals.</p>
  </div>
{% endif %}
