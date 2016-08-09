First time
```
# build site to _book/
gitbook build

git checkout --orphan gh-pages
git rm -rf .

cp -r _book/* .
git add *.html
git add gitbook
git add search_index.json
git commit -m "Generate pages"
git push origin gh-pages
```

Other time
```
gitbook build

git checkout gh-pages

cp -r _book/* .
git add *.html
git add gitbook
git add search_index.json
git commit -m "Update pages"
git push origin gh-pages
```
