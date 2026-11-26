function shrink
    if not command -q ffmpeg
        echo "ffmpeg is not installed" >&2
        return 1
    end

    ffmpeg -i "$argv[1]" -c:v libx264 -c:a copy -crf 20 \
        -vf "scale=iw/2:ih/2,setpts=0.5*PTS" "$argv[2]"
end
