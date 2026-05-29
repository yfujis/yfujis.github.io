#!/usr/bin/env ruby
require 'rss'
require 'yaml'
require 'open-uri'
require 'time'

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
        published_date: item.pubDate ? item.pubDate.to_time.strftime('%Y-%m-%d') : Time.now.strftime('%Y-%m-%d'),
        authors: extract_authors(item),
        description: item.description&.strip || ''
      }
      
      articles[journal_name] << article
    end
    
    # Sort by date descending
    articles[journal_name].sort_by! { |a| a[:published_date] }.reverse!
    
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

# Helper to extract authors from feed item
def extract_authors(item)
  authors = []
  
  # Try various author fields in order of preference
  if item.respond_to?(:author) && item.author
    authors << item.author
  elsif item.respond_to?(:creator) && item.creator
    authors << item.creator
  elsif item.respond_to?(:authors) && item.authors
    authors = item.authors.map { |a| a.respond_to?(:name) ? a.name : a.to_s }
  elsif item.respond_to?(:content_encoded) && item.content_encoded
    # Try to extract from HTML content
    content = item.content_encoded
    if content =~ /<strong[^>]*>([^<]+)<\/strong>/
      authors = [$1.strip]
    end
  end
  
  authors.compact.uniq.first(3) # Max 3 authors
end
