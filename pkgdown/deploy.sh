
# failure is a natural part of life
set -e

[ -z "${GITHUB_PAT}" ] && exit 0

echo "configuring git"
git config --global user.email "jaylamb20@gmail.com"
git config --global user.name "jameslamb"

echo "creating temporary directory to build repo"
export OUTPUT_DIR=$(pwd)/output
mkdir -p ${OUTPUT_DIR}

echo "cloning gh-pages branch of the repo"
git clone \
    -b gh-pages \
    https://${GITHUB_PAT}@github.com/jameslamb/rsixygen.git \
    ${OUTPUT_DIR}
echo "cloned repo to '${OUTPUT_DIR}'"

cd ${OUTPUT_DIR}

cp -r ../docs/* ./
git add --all *
git commit -m "Update the site from appveyor"

echo "Pushing to gh-pages branch"
git push -q origin gh-pages
echo "Successfully updated gh-pages branch"
