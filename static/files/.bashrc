### Git 
alias gst='git status'
alias ga='git add '
alias gc='git commit -m'
alias gp='git pull && git push'
alias gull='git pull'
alias gush='git push'
alias gb='git branch'
alias gco='git checkout'
alias gd='git diff HEAD'
###  Directory navigation
function md ()
{
  mkdir -p "$@" 
  #eval cd "\"\$$#\""
  cd "$@"
  #ls -lah 
}
export MARKPATH=$HOME/.marks
function jump 
{
  if [ -L "$MARKPATH/$1" ]; then
    cd -P $MARKPATH/$1 2> /dev/null
    if [ ! -z "$2" ]; then
      if [ -d "$2" ]; then
        cd -P $2 2> /dev/null
      else
        echo "No such subdir: $2"
      fi
    fi
  else
    echo "No such mark: $1"
    echo "Type jump-list to view all possible jump links."
  fi
}
function jump-list
{
  find $MARKPATH -type l -printf " %-20.20f [%Y] -> %-70.70l\n"
}
function mark 
{
  mkdir -p $MARKPATH; ln -s $(pwd) $MARKPATH/$1
}
function unmark 
{
  rm -i $MARKPATH/$1
}
function marks {
ls -l $MARKPATH | sed 's/  / /g' | cut -d' ' -f9- && echo
}
function _jump 
{
  local cur=${COMP_WORDS[COMP_CWORD]}
  local marks=$(find $MARKPATH -type l | awk -F '/' '{print $NF}')
  COMPREPLY=($(compgen -W '${marks[@]}' -- "$cur"))
  return 0
}
function remark 
{
  echo "Remark dir $(pwd) to \"$1\" ?[yn] "
  read a
  if [ ! -z "$1" ]&&[ "$a" == "y" ]; then
    rm $MARKPATH/$1
    mkdir -p $MARKPATH;
    ln -s $(pwd) $MARKPATH/$1
  fi
}
# Copy using cp_p with progress-bar 
cp_p()
{
   strace -q -ewrite cp -- "${1}" "${2}" 2>&1 \
      | awk '{
        count += $NF
            if (count % 10 == 0) {
               percent = count / total_size * 100
               printf "%3d%% [", percent
               for (i=0;i<=percent;i++)
                  printf "="
               printf ">"
               for (i=percent;i<100;i++)
                  printf " "
               printf "]\r"
            }
         }
         END { print "" }' total_size=$(stat -c '%s' "${1}") count=0
}
complete -o default -o nospace -F _jump jump
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
alias lsblk-full="sudo lsblk -o NAME,MAJ:MIN,RM,SIZE,TYPE,FSTYPE,MOUNTPOINT,UUID"
export EDITOR=vim
alias record_scren_10s="byzanz-record -v -x 2 -y 1138 -w 1276 -h 760 -d 10 vid/private/$(date +"%Y%m%d_%H%M%S").gif"
