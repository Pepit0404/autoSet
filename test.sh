#!/usr/bin/env bash

installCommand="curl -s toto | bash -s --"
typeBash="bash"

error() {
    printf "\e[31m$1\e[0m\n"
    exit 1
}

info() {
    printf "$1\n"
}

warn() {
    printf "⚠️  \e[33m$1\e[0m\n"
}

help() {
    # Display Help
    echo "Install Pepito config"
    echo
    echo "Syntax: install.sh [-h] [-b <bash>]"
    echo "options:"
    echo "-h     Print this help."
    echo "-b     Type of your bash, defaults to $typeBash"
    echo
}

while getopts ":h:b:" option; do
   case $option in
      h) # display Help
         help
         exit;;
      b) # bash
	 typeBash=${OPTARG};;
     \?) # Invalid option
         echo "Invalid option command line option. Use -h for help."
         exit 1
   esac
done

# $1 -> name of commande
validateDependency(){
    if ! command -v $1 >/dev/null; then
        error "$1 is required to install. Please install $1 and try again.\n"
    fi
}

validateDependencies() {
    validate_dependency curl
    validate_dependency unzip
    validate_dependency realpath
    validate_dependency dirname
}

# check if the directory is in the PATH
good=$(
    IFS=:
    for path in $PATH; do
    if [ "${path%/}" = "~/bin" ]; then
        printf 1
        break
    fi
    done
)

if [ "${good}" != "1" ]; then
    echo 'PATH="$PATH:~/bin"' >> .${typeBash}rc
fi

# $1 -> pass
validateFile() {
    if [ -e $1 ]; then
	if [ ! -w $1 ]; then
	    error "Cannot write to ${1}. Please check write permissions and try again : \n${installCommand}"
	fi
        return 0
    fi
    touch $1
    return 0
}


# $1 pass of directory
validateDirectory() {
    if [ -d $1 ]; then
	if [ ! -w $1 ]; then
            error "Cannot write to ${1}. Please check write permissions and try again : \n${installCommand}"
	fi
        return 0
    fi
    mkdir $1
    return 0
}

validateDirectory ~/bin

setAlias() {
    validateFile "$HOME/.bash_aliases"
    echo 'alias iut="ssh sapinto@ssh.iut-clermont.uca.fr"
alias lla="ls -la"
    ' > $HOME/.bash_aliases
}

setOMP() {
    curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/bin

    validateDirectory ~/.config
    validateDirectory ~/.config/oh-my-posh
    validateFile ~/.config/oh-my-posh/theme.omp.json

    validateFile $HOME/.${typeBash}rc

    curl -s "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/kali.omp.json" > ~/.config/oh-my-posh/theme.omp.json

    echo 'eval "$(oh-my-posh init ' $typeBash' --config ~/.config/oh-my-posh/theme.omp.json)"' >> ~/.${typeBash}rc    
}

setAlias
setOMP
source ~/.${typeBash}rc
