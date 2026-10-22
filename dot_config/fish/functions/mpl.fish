function mpl
    set -l _env_file "data/local.env"
    set -l _settings_file "localdev.settings"
    set -l _client ""

    # Parse first --client flag from argv (subsequent ones pass through to the command)
    set -l _remaining_args
    set -l _i 1
    set -l _client_parsed false
    while test $_i -le (count $argv)
        if test "$argv[$_i]" = "--client" && test "$_client_parsed" = false
            set _i (math $_i + 1)
            if test $_i -le (count $argv)
                set _client (string lower $argv[$_i])
                set _client_parsed true
            else
                echo "Error: --client requires a value"
                return 1
            end
        else
            set -a _remaining_args $argv[$_i]
        end
        set _i (math $_i + 1)
    end

    if not test -f $_env_file
        echo ".env file not found"
        return 1
    end

    # Map client code to DJANGO_CONFIGURATION
    if test -n "$_client"
        switch $_client
            case oesgb
                set DJANGO_CONFIGURATION OESGBSupportSiteTest
            case oesde
                set DJANGO_CONFIGURATION OESDESupportSiteTest
            case oemde
                set DJANGO_CONFIGURATION OEMDESupportSiteTest
            case totalenergieses
                set DJANGO_CONFIGURATION TotalEnergiesESSupportSiteTest
            case goodenergygb
                set DJANGO_CONFIGURATION GoodEnergyGBSupportSite
            case norlysdk
                set DJANGO_CONFIGURATION NorlysDKSupportSiteTest
            case '*'
                echo "Unknown client: $_client"
                echo "Available clients: oesgb, oesde, oemde, totalenergieses, goodenergygb, norlysdk"
                return 1
        end
    else if test -z "$DJANGO_CONFIGURATION"
        echo "Defaulting to OESGBSupportSiteTest"
        echo
        set DJANGO_CONFIGURATION OESGBSupportSiteTest
    end

    set_color cyan
    echo "  Configuration: $DJANGO_CONFIGURATION"
    echo "Settings Module: $_settings_file"
    echo "       Env File: $_env_file"
    set_color normal

    set -l uv_options
    if test -z "$VIRTUAL_ENV"
        set uv_options --frozen
    end
    env DJANGO_CONFIGURATION="$DJANGO_CONFIGURATION" DJANGO_SETTINGS_MODULE="$_settings_file" \
        uv run $uv_options --env-file "$_env_file" python src/manage.py $_remaining_args
end
