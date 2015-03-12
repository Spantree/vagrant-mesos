PROJECT_ROOT=$(echo "$1")
PUPPET_VERSION=$(echo "$2")

TMP_DIR=/tmp/spantree-puppet-bootstrap
GLOB_PATTERN="Spantree-spantree-puppet-bootstrap-*"

mkdir -p /var/cache/wget
mkdir -p $TMP_DIR

cd $TMP_DIR
rm -Rf *
curl -Ls https://github.com/Spantree/spantree-puppet-bootstrap/tarball/1.2.0 | tar zx
cd Spantree-spantree-puppet-bootstrap-*/shell/

mkdir -p /var/cache/wget

./initialize-all.sh `pwd` $PROJECT_ROOT $PUPPET_VERSION