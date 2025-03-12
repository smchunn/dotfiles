function fish_title
    set -q argv[1]; or set argv (basename $PWD);
    echo $argv;
end
