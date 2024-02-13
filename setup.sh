# clone a repo at the same location of this script

# get the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# give executable permission to all the scripts in scripts folder
chmod +x $DIR/scripts/*

# clone the repo at the same location of this script and if the repo is already cloned, then update it
if [ -d "$DIR/llama.cpp" ]; then
    cd $DIR/llama.cpp
    make clean
    git pull
else
    git clone https://github.com/ggerganov/llama.cpp.git $DIR/llama.cpp
    cd $DIR/llama.cpp
# git clone https://github.com/ggerganov/llama.cpp.git $DIR/llama.cpp 
fi

# run make and report errors
make || exit 1