#### Requirements
---
We'd like you to write a simple web crawler in Ruby. 

It should be limited to one domain.
When crawling foobar.com it would crawl all pages within the foobar.com domain, but not follow the links to external domains. 
Given a URL, it should output a site map, showing which static assets each page depends on. 
The crawler needs to stop after a certain amount of pages have been crawled. 
Bonus points for tests and/or for making it as fast as possible! 

---

#### Usage
Use **redis** as to store urls at runtime.
Parsing by **oga**

```
  crawly <fqdn website url> <max no of pages>
  #ex. 
  #crawly http://microspino.com 5
```

To display a pretty formatted sitemap on OS X pipe the sitemap txt to **xmlint**:

```
  pbpaste | xmllint --format -
```
#### Test
Use **rake** or **rake test**

#### As a Gem
Not released yet on github but packaged as a gem.

Build it with **gem build crawly.gemspec**<br/>
Install withh **gem install crawly-0.0.1.gem**

_Please ignore the warnings alpha software here ;)_