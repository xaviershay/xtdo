autoload -U compinit
compinit

_xtdo() {
  if [[ $words[2] == b ]]; then
    if (( CURRENT == 4 )); then
      compadd `bin/xtdo l c`
    fi
  fi

  if [[ $words[2] == d ]]; then
    if (( CURRENT == 3 )); then
      compadd `bin/xtdo l c`
    fi
  fi

  if [[ $words[2] == r && $words[3] == d ]]; then
    if (( CURRENT == 4 )); then
      compadd `bin/xtdo r c`
    fi
  fi
}

compdef _xtdo xtdo 
