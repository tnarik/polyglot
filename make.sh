# /bin/sh
VERSION="1.4.0"
gem build jekyll-polyglotter.gemspec
sudo gem install jekyll-polyglotter-$VERSION.gem
cd site
rm -rf _site/
jekyll build --no-watch
