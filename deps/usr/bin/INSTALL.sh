#!/bin/bash

echo "INFO: Setting up user playground directory..."

mkdir -p ~/.playground/bin

if [ ! -f ~/.playground/config.yml ]; then
    cp ./config.yml ~/.playground/config.yml
else
    echo "WARN: ~/.playground/config.yml already exists. Skipping."
    echo "WARN: Please see $PWD/config.yml if you have any problems "
	echo "      with your existing config.yml file."
fi

echo "INFO: Run \`playground\` with"
echo "\`\`\`"
echo "LD_LIBRARY_PATH=$PWD $PWD/playground"
echo "\`\`\`"
echo "INFO: Create a \`playground\` alias in the RC file for you default shell"
echo "\`\`\`"
echo "echo \"alias playground=\\\"LD_LIBRARY_PATH=$PWD $PWD/playground\\\"\" >> ~/.bashrc"
echo "\`\`\`"
echo "INFO: Add ~/.playground/bin to your search path (\$PATH) so julia versions installed "
echo "      via playground are available globally."
