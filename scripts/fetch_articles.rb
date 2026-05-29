#!/usr/bin/env ruby
require 'rss'
require 'yaml'
require 'open-uri'
require 'time'

# Helper to extract authors from feed item
def extract_authors(item)
  authors = []
  
  # Try Dublin Core creators (RDF feeds like Nature, Cell)
  if item.respond_to?(:dc_creator) && item.dc_creator&.any?
    authors = item.dc_creator.map { |creator| creator.content.strip }
  # Try standard author field (Atom feeds)
  elsif item.respond_to?(:author) && item.author
    authors = [item.author.content&.strip || item.author.to_s].compact
  # Try creator field
  elsif item.respond_to?(:creator) && item.creator
    authors = [item.creator.content&.strip || item.creator.to_s].compact
  # Try extracting from content
  elsif item.respond_to?(:content_encoded) && item.content_encoded
    content = item.content_encoded
    if content =~ /<strong[^>]*>([^<]+)<\/strong>/
      authors = [$1.strip]
    end
  end
  
  authors.compact.uniq.first(3) # Max 3 authors
end

# Helper to extract publication date from feed item
def extract_date(item)
  # Try Dublin Core date (RDF feeds)
  if item.respond_to?(:dc_date) && item.dc_date&.any? && item.dc_date.first
    return item.dc_date.first.content.to_time.strftime('%Y-%m-%d')
  # Try pubDate (RSS 2.0)
  elsif item.respond_to?(:pubDate) && item.pubDate
    return item.pubDate.to_time.strftime('%Y-%m-%d')
  # Try published (Atom)
  elsif item.respond_to?(:published) && item.published
    return item.published.to_time.strftime('%Y-%m-%d')
  end
  
  Time.now.strftime('%Y-%m-%d')
end

# Load journals configuration
journals_file = File.join(__dir__, '..', '_data', 'journals.yml')
journals_config = YAML.load_file(journals_file)

articles = {}

journals_config['journals'].each do |journal|
  journal_name = journal['name']
  feed_url = journal['feed']
  
  begin
    puts "Fetching articles from #{journal_name}..."
    
    # Fetch and parse RSS feed with timeout
    feed_content = URI.open(feed_url, read_timeout: 30).read
    feed = RSS::Parser.parse(feed_content)
    
    articles[journal_name] = []
    
    # Extract articles from feed (limit to 20 most recent)
    feed.items.first(20).each do |item|
      article = {
        title: item.title&.strip || 'Untitled',
        link: item.link || '',
        published_date: extract_date(item),
        authors: extract_authors(item),
        description: item.description&.strip || ''
      }
      
      articles[journal_name] << article
    end
    
    # Sort by date descending
    articles[journal_name].sort_by! { |a| a[:published_date] }.reverse!
    puts "  ✓ Fetched #{articles[journal_name].length} articles"
    
  rescue => e
    puts "ERROR fetching #{journal_name}: #{e.message}"
    articles[journal_name] = []
  end
end

# Sort journals alphabetically and write to YAML
sorted_articles = articles.sort.to_h

output_file = File.join(__dir__, '..', '_data', 'articles.yml')
File.write(output_file, {
  'last_updated' => Time.now.strftime('%Y-%m-%d %H:%M:%S %Z'),
  'articles' => sorted_articles
}.to_yaml)

puts "\n✓ Successfully fetched #{sorted_articles.sum { |_, a| a.length }} articles from #{sorted_articles.length} journals"
puts "  Saved to #{output_file}"
