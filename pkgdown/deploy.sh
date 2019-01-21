set -e

[ -z "${GITHUB_PAT}" ] && exit 0
git config --global user.email "brucezhaor2016@gmail.com"
git config --global user.name "BruceZhaoR"

git clone -q -b gh-pages https://${GITHUB_PAT}@github.com/brucezhaor/lightgbm_r.git output
cd output
git rm -rf *
  cp -r ../docs/* ./
  git add --all *
  git commit -m"Update the site from appveyor"
# echo add files to gh-pages
git push -q origin gh-pages
