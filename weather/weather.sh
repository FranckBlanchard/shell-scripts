#!/usr/bin/env bash

set -uo pipefail

# Nom		: weather.sh
# Description	: Ce script retourne des infos météorologique d'une ville dans le monde.
# 		        Nous utilisons l'api de open-meteo.com, la documentation peux être trouvé a  https://open-meteo.com/en/docs
#
# Auteur	: Franck Blanchard info@aztequemedia.com
#
# Dépendances:
#   - jq pour traiter les données au format json
#   - curl pour les requêtes réseaux

# Version du script
VERSION="0.2.0"

# Fonction d'affichage de l'aide
show_help() {
    echo "Usage: weather <nom_de_ville> [pays_ou_region] [--json]"
    echo ""
    echo "Affiche la météo actuelle pour la ville spécifiée."
    echo ""
    echo "Exemples :"
    echo "  weather Laval"
    echo "  weather \"Laval France\""
    echo "  weather \"Trois-rivières Québec Canada\""
    echo "  weather Paris --json"
    echo ""
    echo "Options :"
    echo "  --json       Affiche le résultat brut au format JSON"
    echo "  -h, --help   Affiche ce message d'aide"
    echo "  -v, --version Affiche la version du script"
}

# Fonction de vérification des dépendances
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "Erreur : La commande '$1' est requise mais n'est pas installée." >&2
        echo "Installe-la avec : sudo apt install $1" >&2
        exit 1
    fi
}

# Fonction de géocodage intelligente et tolérante
get_coordinates() {
    local QUERY="$1"
    
    local FIRST_WORD=$(echo "$QUERY" | awk '{print $1}')
    local ENCODED_FIRST=$(jq -rn --arg x "$FIRST_WORD" '$x | @uri')
    
    local GEO_URL="https://geocoding-api.open-meteo.com/v1/search?name=${ENCODED_FIRST}&count=20&language=fr&format=json"
    local GEO_RESPONSE=$(curl -s "$GEO_URL")
    
    local RESULTS_COUNT=$(echo "$GEO_RESPONSE" | jq -r '.results | length // 0' 2>/dev/null)
    
    if ! [[ "$RESULTS_COUNT" =~ ^[0-9]+$ ]] || [ "$RESULTS_COUNT" -eq 0 ]; then
        echo "Erreur : Impossible de trouver la localité '$QUERY'." >&2
        return 1
    fi

    local INDEX=-1
    local QUERY_LOWER=$(echo "$QUERY" | tr '[:upper:]' '[:lower:]')
    local NUM_WORDS=$(echo "$QUERY" | wc -w)

    if [ "$NUM_WORDS" -eq 1 ]; then
        INDEX=0
    else
        for ((i=0; i<RESULTS_COUNT; i++)); do
            local C_NAME=$(echo "$GEO_RESPONSE" | jq -r ".results[$i].name // \"\"" | tr '[:upper:]' '[:lower:]')
            local A_NAME=$(echo "$GEO_RESPONSE" | jq -r ".results[$i].admin1 // \"\"" | tr '[:upper:]' '[:lower:]')
            local COUNTRY_NAME=$(echo "$GEO_RESPONSE" | jq -r ".results[$i].country // \"\"" | tr '[:upper:]' '[:lower:]')
            
            if [[ "$QUERY_LOWER" == *"$C_NAME"* ]] && { [[ "$QUERY_LOWER" == *"$COUNTRY_NAME"* ]] || [[ "$QUERY_LOWER" == *"$A_NAME"* ]] || [ -z "$COUNTRY_NAME" ]; }; then
                INDEX=$i
                break
            fi
        done
        
        if [ "$INDEX" -eq -1 ]; then
            INDEX=0
        fi
    fi

    LAT=$(echo "$GEO_RESPONSE" | jq -r ".results[$INDEX].latitude")
    LON=$(echo "$GEO_RESPONSE" | jq -r ".results[$INDEX].longitude")
    MATCHED_NAME=$(echo "$GEO_RESPONSE" | jq -r ".results[$INDEX].name")
    REGION=$(echo "$GEO_RESPONSE" | jq -r ".results[$INDEX].admin1 // \"\"")
    COUNTRY=$(echo "$GEO_RESPONSE" | jq -r ".results[$INDEX].country // \"\"")
}

# Fonction pour traduire le weather_code WMO
get_weather_description() {
    case "$1" in
        0) echo "☀️ Ciel dégagé" ;;
        1) echo "🌤️ Principalement dégagé" ;;
        2) echo "⛅ Partiellement nuageux" ;;
        3) echo "☁️ Couvert" ;;
        45|48) echo "🌫️ Brouillard" ;;
        51|53|55) echo "🌦️ Bruine" ;;
        56|57) echo "🧊 Bruine verglaçante" ;;
        61) echo "🌧️ Pluie légère" ;;
        63) echo "🌧️ Pluie modérée" ;;
        65) echo "🌧️☔ Pluie forte" ;;
        66|67) echo "🧊🌧️ Pluie verglaçante" ;;
        71) echo "🌨️ Neige légère" ;;
        73) echo "❄️ Neige modérée" ;;
        75) echo "❄️❄️ Neige forte" ;;
        77) echo "🌨️ Grains de neige" ;;
        80|81|82) echo "🌦️ Averses de pluie" ;;
        85|86) echo "🌨️ Averses de neige" ;;
        95) echo "⛈️ Orage" ;;
        96|99) echo "⛈️🧊 Orage avec grêle" ;;
        *) echo "❓ Inconnu (code $1)" ;;
    esac
}
json_get() {
    jq -r "$1" <<< "$RESPONSE"
}
# Extraction des données pour l'affichage classique
get_weather_data() {
    TEMP=$(json_get '.current.temperature_2m')
    TEMP_MAX=$(json_get '.daily.temperature_2m_max[0]')
    TEMP_MIN=$(json_get '.daily.temperature_2m_min[0]')
    APPARENT=$(json_get '.current.apparent_temperature')
    TEMP_UNIT=$(json_get '.current_units.temperature_2m')    
    
    HUMIDITY=$(json_get '.current.relative_humidity_2m')
    HUM_UNIT=$(json_get '.current_units.relative_humidity_2m')
    
    WIND=$(json_get '.current.wind_speed_10m')
    WIND_UNIT=$(json_get '.current_units.wind_speed_10m')
    
    PRESSURE=$(json_get '.current.pressure_msl')
    PRESS_UNIT=$(json_get '.current_units.pressure_msl')
    
    CODE=$(json_get '.current.weather_code')
    CONDITION=$(get_weather_description "$CODE")

    LOCATION_STR="$MATCHED_NAME"
    [ -n "$REGION" ] && LOCATION_STR="$LOCATION_STR, $REGION"
    [ -n "$COUNTRY" ] && LOCATION_STR="$LOCATION_STR, $COUNTRY"
    # Extraction du fuseau horaire renvoyé par l'API (ex: America/Toronto)
    API_TZ=$(json_get '.timezone // "UTC"')
    # Extraction et mise en forme des dates/heures
    LOCAL_TIME=$(date +"%Y-%m-%d %H:%M")
    # Heure exacte du lieu calculée via son fuseau horaire
    DEST_TIME=$(TZ="$API_TZ" date +"%Y-%m-%d %H:%M")
}

# Fonction pour construire la requête API
build_api_url() {
    local current_metrics="$1"
    local daily_metrics="$2"
    local API_URL="https://api.open-meteo.com/v1/forecast?latitude=${LAT}&longitude=${LON}&current=${current_metrics}&daily=${daily_metrics}&timezone=auto&forecast_days=1"
    echo "$API_URL"
}

# Fonction de requête api open-meteo.com
fetch_weather() {
    local current_metrics="temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,pressure_msl"
    local daily_metrics="temperature_2m_max,temperature_2m_min"

    local API_URL=$(build_api_url "$current_metrics" "$daily_metrics")
    RESPONSE=$(curl -s "$API_URL")

    if [ -z "$RESPONSE" ]; then
        echo "Erreur : Impossible de contacter l'API Open-Meteo." >&2
        exit 1
    fi
    # Vérification que la réponse reçue est bien un JSON valide
    if ! echo "$RESPONSE" | jq empty 2>/dev/null; then
        echo "Erreur : La réponse de l'API n'est pas un JSON valide." >&2
        exit 1
    fi
}

# Fonction d'affichage de la météo
display_weather() {
    echo "=================================================="
    echo " Météo actuelle à $LOCATION_STR"
    echo " Latitude : ${LAT}  |  Longitude : ${LON}"
    echo "=================================================="
    echo " Heure locale (ici)  : ${LOCAL_TIME}"
    echo " Heure du lieu       : ${DEST_TIME}"
    echo "--------------------------------------------------"
    echo " Température 		    : ${TEMP} ${TEMP_UNIT} (Ressenti : ${APPARENT} ${TEMP_UNIT})"
    echo " Maximum aujourd'hui  : ${TEMP_MAX} ${TEMP_UNIT}"
    echo " Minimum aujourd'hui  : ${TEMP_MIN} ${TEMP_UNIT}"
    echo " Conditions  		    : ${CONDITION}"    
    echo " Humidité    		    : ${HUMIDITY} ${HUM_UNIT}"
    echo " Vent        		: ${WIND} ${WIND_UNIT}"
    echo " Pression atmosphérique   : ${PRESSURE} ${PRESS_UNIT}"
    echo "=================================================="
}

main() {

    # Analyse des options (--json, -h, --help)
    RAW_JSON=false
    ARGS=()

    for arg in "$@"; do
        case "$arg" in
            --json)
                RAW_JSON=true
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                echo "$VERSION"
                exit 0
                ;;
            -*)
                echo "Erreur : option inconnue '$arg'"
                echo "Utilisez --help pour afficher l'aide."
                exit 1
                ;;
            *)
                ARGS+=("$arg")
                ;;
        esac
    done
    # Vérification : si aucun nom de ville n'est fourni, afficher l'aide et quitter
    if [ "${#ARGS[@]}" -eq 0 ]; then
        show_help
        exit 0
    fi
    # Reconstruction de la chaîne de recherche de la ville à partir des arguments restants
    SEARCH_INPUT="${ARGS[*]}"
    # Vérification des dépendances
    check_command curl
    check_command jq
    # Exécution du géocodage
    get_coordinates "$SEARCH_INPUT" || exit 1
    # Récupération des données météo
    fetch_weather
    # Si l'option --json est présente, on affiche directement le JSON brut formaté
    if [ "$RAW_JSON" = true ]; then
        echo "$RESPONSE" | jq .
        exit 0
    fi
    # On initialise les données
    get_weather_data
    # On affiche la météo
    display_weather
}
# --- Début du script ---
main "$@"
