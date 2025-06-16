# bash main.sh

echo -e "🧶 Häkelanleitungs-Komponierer 🧵\n"

# Ziel-Datei
read -p "Name des fertigen Wesens: " name
ziel_datei="anleitungen/${name// /_}_anleitung.csv"
> "$ziel_datei"

# Teil-Auswahl-Funktion
function addPart() {
    typ=$1
    typ_lowercase="${typ,,}"
    verzeichnis="haekelteile"
    
    echo ""
    case "$typ_lowercase" in
        kopf) symbol="😊" ;;
        koerper) symbol="🧸" ;;
        beine) symbol="🦵" ;;
        schwaenzchen) symbol="🪱" ;;
        *) symbol="🔸" ;;
    esac
    
    echo "$symbol Verfügbare $typ:"
    echo "Suche Dateien in: $verzeichnis/${typ_lowercase}/*.csv"
    teile=($verzeichnis/${typ_lowercase}/*.csv)
    echo "Gefundene Dateien: ${#teile[@]}"
    
    for i in "${!teile[@]}"; do
        echo "$((i+1))) $(basename "${teile[$i]}")"
    done
    
    while true; do
        echo ""
        read -p "Welche $typ möchtest du verwenden? (Zahl, q = Überspringen, a = Abbrechen) " wahl
        
        if [[ "$wahl" =~ ^[Aa]$ ]]; then
            echo "🛑 Vorgang abgebrochen. Keine Anleitung erstellt."
            rm -f "$ziel_datei"
            exit 1
        fi
        
        if [[ "$wahl" =~ ^[Qq]$ ]]; then
            echo "⏭️  $typ wird übersprungen."
            break
        fi
        
        if [[ "$wahl" =~ ^[0-9]+$ ]]; then
            index=$((wahl-1))
            if [[ $index -ge 0 && $index -lt ${#teile[@]} ]]; then
                datei="${teile[$index]}"
                dateiname=$(basename "$datei")
                echo "Gewählte Datei: $datei"
                inhalt=$(<"$datei")
                
                # BOM entfernen (falls vorhanden), Inhalt mit Zeilenumbrüchen einlesen
                inhalt=$(sed '1 s/^\xEF\xBB\xBF//' "$datei")
                
                # Doppelte Anführungszeichen escapen, echte Zeilenumbrüche bleiben erhalten
                csv_inhalt=$(echo "$inhalt" | sed 's/"/""/g')
                
                echo "$csv_inhalt" >> "$ziel_datei"
                
                echo -e "💾 Teil \"$dateiname\" gespeichert."
                break
            fi
        fi
        
        echo "❌ Ungültige Eingabe. Bitte Zahl eingeben oder 'q' zum Überspringen, 'a' zum Abbrechen."
    done
}


# Auswählen und Einfügen
addPart "head"
addPart "ears"
addPart "nose"
addPart "arms"
addPart "body"
addPart "legs"
addPart "tail"

echo -e "\n✅ Deine Anleitung wurde gespeichert in: $ziel_datei"

# Anleitung öffnen
echo -e "📖 Öffne die Anleitung in Excel ...\n"

case "$OSTYPE" in
    linux*)   libreoffice --calc "$ziel_datei" & ;;
    darwin*)  open -a "Microsoft Excel" "$ziel_datei" ;;
    msys*|cygwin*)  start excel.exe "$ziel_datei" ;;
    *)        echo "⚠️ Dein Betriebssystem wird nicht direkt unterstützt. Bitte öffne die Datei manuell in Excel: $ziel_datei" ;;
esac

