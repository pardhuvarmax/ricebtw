{ config, pkgs, ... }:

{
  # Consolidated from ~/.zshrc (inline aliases) + ~/.aliases (sourced twice, redundantly).
  # Where the two disagreed, ~/.aliases won (it was sourced last, so its definitions
  # were the ones actually active): mirrors, update, ls, ll.
  # `fd` alias removed on purpose -- it shadowed the real `fd` tool migrated in Phase 1.
  # Its old meaning survives as `fdir`.
  programs.zsh.shellAliases = {
    # system & package
    update = "paru -Syu --noconfirm";
    upgrade = "paru -Syu";
    install = "paru -S";
    remove = "paru -Rns";
    search = "paru -Ss";
    orphan = "paru -Qtdq";
    cleanorphans = "paru -Rns $(paru -Qtdq)";
    pkglist = "paru -Q";
    pkginfo = "paru -Qi";
    fixkeys = "sudo pacman-key --refresh-keys";
    mirrors = "sudo reflector --latest 10 --sort rate --save /etc/pacman.d/mirrorlist";
    cleanpkg = "paru -Sc";
    deepclean = "paru -Scc";
    reinstall = "paru -S $(paru -Qnq)";
    pacdiff = "sudo pacdiff";
    unlock = "sudo rm /var/lib/pacman/db.lck";
    downgrade = "sudo downgrade";
    cache = "du -sh ~/.cache";
    diskuse = "du -sh *";
    grub-update = "sudo grub-mkconfig -o /boot/grub/grub.cfg";

    # file management
    ls = "eza --icons --group-directories-first";
    ll = "eza -la --icons --group-directories-first";
    lt = "eza --tree --icons";
    l = "eza -l";
    la = "eza -a";
    l1 = "eza -1";
    lgit = "eza --git";
    ltime = "eza -l --sort=modified";
    lsize = "eza -l --sort=size";

    cp = "cp -iv";
    mv = "mv -iv";
    rm = "rm -iv";
    mkdir = "mkdir -pv";

    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    "....." = "cd ../../../..";

    home = "cd ~";
    desk = "cd ~/Desktop";
    docs = "cd ~/Documents";
    down = "cd ~/Downloads";
    vids = "cd ~/Videos";
    pics = "cd ~/Pictures";
    dev = "cd ~/Desktop/Dev/";

    tree = "tree -C";
    grep = "grep --color=auto";
    df = "df -h";
    free = "free -h";

    # navigation
    c = "clear";
    q = "exit";
    h = "history";
    j = "jobs -l";
    path = "echo -e \${PATH//:/\\n}";
    reload = "source ~/.zshrc";

    back = "cd -";
    root = "cd /";
    etc = "cd /etc";
    var = "cd /var";
    usr = "cd /usr";
    opt = "cd /opt";

    f = "find . -name";
    fdir = "find . -type d -name"; # was aliased as `fd`; renamed so the real fd tool works

    # search & network
    ports = "netstat -tulanp";
    listen = "ss -tulnp";
    myip = "curl ifconfig.me";
    localip = "ip a";
    pingg = "ping google.com";
    pathsize = "du -sh .";
    biggest = "du -ah . | sort -rh | head -20";
    openports = "lsof -i";
    proc = "ps aux | less";
    psg = "ps aux | grep -i";

    # performance
    top = "htop";
    cpu = "htop";
    mem = "free -m";
    disk = "iotop";
    killall = "killall -v";
    k9 = "kill -9";
    pstree = "pstree -p";
    usage = "top -o %MEM";
    cpuload = "uptime";
    temps = "sensors";

    # docker
    dps = "docker ps";
    dpa = "docker ps -a";
    di = "docker images";
    drm = "docker rm";
    drmi = "docker rmi";
    dstart = "docker start";
    dstop = "docker stop";
    dexec = "docker exec -it";
    dlogs = "docker logs";
    dprune = "docker system prune -a";
    dclean = "docker container prune";
    dnet = "docker network ls";
    dvol = "docker volume ls";
    dup = "docker compose up -d";
    ddown = "docker compose down";

    # kubernetes
    k = "kubectl";
    kg = "kubectl get";
    kgp = "kubectl get pods";
    kgs = "kubectl get svc";
    kgn = "kubectl get nodes";
    kd = "kubectl describe";
    kdel = "kubectl delete";
    klog = "kubectl logs";
    kexec = "kubectl exec -it";
    kctx = "kubectl config use-context";
    kns = "kubectl config set-context --current --namespace";
    kapply = "kubectl apply -f";
    ktop = "kubectl top pods";

    # cybersec
    sniff = "tcpdump -i any";
    scan = "nmap -sC -sV";
    fastscan = "nmap -T4 -F";
    vuln = "nmap --script vuln";
    whois = "whois";
    dns = "dig";
    http = "curl -I";
    headers = "curl -I";
    trace = "traceroute";
    netwatch = "watch -n1 ss -tulnp";

    # dev
    vim = "nvim";
    code = "code .";
    py = "python3";
    pip = "pip3";
    serve = "python3 -m http.server";
    json = "python -m json.tool";
    build = "npm run build";
    start = "npm start";
    ndev = "npm run dev";
    test = "npm test";

    # git
    g = "git";
    gs = "git status";
    ga = "git add";
    gaa = "git add .";
    gc = "git commit -m";
    gca = "git commit --amend";
    gp = "git push";
    gpl = "git pull";
    gcl = "git clone";
    gb = "git branch";
    gco = "git checkout";
    gcb = "git checkout -b";
    gl = "git log --oneline --graph --all";
    gd = "git diff";
    gds = "git diff --staged";
    stash = "git stash";
    stashp = "git stash pop";
    undo = "git reset --soft HEAD~1";
    hardundo = "git reset --hard HEAD~1";

    # system control
    reboot = "sudo reboot";
    shutdown = "sudo shutdown now";
    suspend = "systemctl suspend";
    lock = "loginctl lock-session";
    logout = "loginctl terminate-session $XDG_SESSION_ID";
    services = "systemctl list-units --type=service";
    startsvc = "sudo systemctl start";
    stopsvc = "sudo systemctl stop";
    enablesvc = "sudo systemctl enable";
    disablesvc = "sudo systemctl disable";
    statsvc = "systemctl status";

    # utilities
    cat = "bat --theme=base16";
    weather = "curl wttr.in";
    clock = "watch -n1 date";
    cls = "clear";
    random = "shuf -n1 /usr/share/dict/words";
    calc = ''python -i -c "from math import *"'';
    speed = "speedtest-cli";
    matrix = "cmatrix";
    pipes = "~/pipes.sh/pipes.sh";

    # archive
    extract = "tar -xvf";
    compress = "tar -czvf";
    untar = "tar -xvf";
    wgetc = "wget -c";
    curlh = "curl -I";

    # history / debug
    hist10 = "history | tail -10";
    histgrep = "history | grep";
    "sudo!!" = "sudo !!";
    fixperm = "chmod -R 755";

    # extra power
    now = ''date +"%T"'';
    today = ''date +"%Y-%m-%d"'';
    epoch = "date +%s";
    uuid = "cat /proc/sys/kernel/random/uuid";
    pathadd = "export PATH=$PATH:";
    reloadbash = "source ~/.bashrc";
    reloadzsh = "source ~/.zshrc";

    # zshrc-only extras (not present in ~/.aliases, kept as-is)
    music = "rmpc";
    mysql = "mysql -u root -p";
    linutil = "curl -fsSL https://christitus.com/linux | sh";
  };
}
