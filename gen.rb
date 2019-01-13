#!/usr/bin/env ruby
require 'yaml'
podcasts_h = YAML.load_file('podcasts.yml')

def config
  @config ||= YAML.load_file('config.yml')
end

def duration_badge(podcast)
 duration = podcast['episode_duration'] || '未知'
 status, color = if podcast['primium']
   ['有会员', 'yellow']
  elsif podcast['primium_only']
    ['付费', 'red']
  else
    ['免费', 'brightgreen']
  end
 %Q|<img title="时长分钟"
         src="https://img.shields.io/badge/#{duration}m-#{status}-#{color}.svg">
    |
end

def validate!(podcast)
  raise 'Podcast in empty' if podcast.nil? || !podcast.is_a?(Hash) || podcast.keys.size == 0
  if %w(name website description).any?{|attr| podcast[attr]&.strip.nil? }
    raise "name, website, description can't be empty: #{podcast.inspect}"
  end
end

def rss_icon(rss_url)
  %Q|<a href='#{rss_url}' title='订阅'> #{gen_icon(config['icons']['rss'])} </a>|
end

def gen_icon(icon_src, width=20, height=20, link=nil, title=nil)
  if link
    %Q|<a href="#{link}" title="#{title}"> <img src="#{icon_src}" width="#{width}" height="#{width}"> </a>|
  else
    %Q|<img src="#{icon_src}" width="#{width}" height="#{width}">|
  end
end

def space(n=1)
  '&nbsp;' * n
end

def link_to(title, href)
  %Q|<a href="#{href}" title="#{href}">#{title}</a>|
end

def category_head(category)
  return "\n ## #{category} \n" unless category == 'IPN'
  "\n## [#{category}](https://ipn.li) &nbsp;&nbsp; #{gen_icon(config['icons']['twitter'], 20,20, 'https://twitter.com/ipnpodcast', 'IPN on Twitter')}\n"
end

content = "<!-- Generated at #{Time.now} --> \n"
collapsed = config['head'] + "\n  - [查看展开版本](https://github.com/fffx/awesome-chinese-podcasts/blob/master/README_OPENED.md)"
opened = config['head'] + "\n  - [查看收拢版本](https://github.com/fffx/awesome-chinese-podcasts/blob/master/README.md)"

# =begin
# https://gist.github.com/joyrexus/16041f2426450e73f5df9391f7f7ae5f
podcast_proc = Proc.new do |podcast, name, open=false|
  <<~CONTENT
  <details #{"open='true'" if open}>
  <summary title='展开'>
    #{link_to(name, podcast['website'])} #{duration_badge(podcast)}
  </summary>
  <p>

    #{podcast['highlight']}
  </p>

  <p>

  > #{podcast['description']} #{space} #{rss_icon(podcast['rss'])}
  </p>
  </details>
  CONTENT
end
podcasts_h.each do |category, podcasts|
  puts category
  opened << category_head(category)
  collapsed << category_head(category)
  podcasts.sort_by!{|p| p['name'] }.each do |podcast|
    validate! podcast
    name = podcast['featured'] ? "<b>#{podcast['name']} 👍</b>" : podcast['name']
    collapsed << podcast_proc.call(podcast, name, false)
    opened << podcast_proc.call(podcast, name, true)
  end
end
# =end

File.write('README.md', content + collapsed + "\n" + config['foot'])
File.write('README_OPENED.md', content + opened + "\n" + config['foot'])

puts 'Done'