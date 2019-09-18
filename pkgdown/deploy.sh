
# failure is a natural part of life
set -e

[ -z "${GITHUB_PAT}" ] && exit 0

echo "[INFO] configuring git"
git config --global user.email "jaylamb20@gmail.com"
git config --global user.name "jameslamb"

echo "[INFO] creating temporary directory to build repo"
export OUTPUT_DIR=$(pwd)/output
mkdir -p ${OUTPUT_DIR}

echo "[INFO] cloning gh-pages branch of the repo"
git clone \
    -b gh-pages \
    https://${GITHUB_PAT}@github.com/jameslamb/rsixygen.git \
    ${OUTPUT_DIR}
echo "[INFO] cloned repo to '${OUTPUT_DIR}'"

cd ${OUTPUT_DIR}

echo "[INFO] copying docs to output dir"
cp -r ../docs/* ./

echo "[INFO] checking files into the repo"
git add --all *
git commit -m "Update the site from appveyor"

echo "[INFO] pushing to gh-pages branch"
git push -q origin gh-pages
echo "[INFO] successfully updated gh-pages branch"
