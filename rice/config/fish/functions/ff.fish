function ff
    set DIR $HOME/.config/fastfetch/ascii
    set BASE_CONFIG $HOME/.config/fastfetch/config.jsonc
    set TMP_CONFIG /tmp/fastfetch_random.jsonc

    set RANDOM_FILE (find $DIR -type f -name "*.txt" | shuf | head -n 1)

    # build temp config cleanly
    jq --arg file "$RANDOM_FILE" '
        .logo = {
            type: "file",
            source: $file
        }
    ' $BASE_CONFIG > $TMP_CONFIG

    command fastfetch --config $TMP_CONFIG
end
