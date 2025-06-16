# bash main.sh

echo -e "🧶 Häkelanleitungs-Komponierer 🧵\n"

# Ziel-Datei
read -p "Name des fertigen Wesens: " name
ziel_datei="anleitungen/${name// /_}_anleitung.txt"
> "$ziel_datei"

# Teil-Auswahl-Funktion
function addPart() {
    typ=$1
    typ_lowercase="${typ,,}"
    verzeichnis="haekelteile"
    
    echo ""
    case "$typ_lowercase" in
        kopf) symbol="😊" ;;
        koerper) symbol="🌰" ;;
        beine) symbol="🦵" ;;
        schwaenzchen) symbol="🪱" ;;
        *) symbol="🔸" ;;
    esac
    
    echo "$symbol Verfügbare $typ:"
    
    teile=($verzeichnis/${typ_lowercase}/*.txt)
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
                echo -e "💾 Füge ${teile[$index]} hinzu..."
                echo -e "--- ${typ^^} ---" >> "$ziel_datei"
                cat "${teile[$index]}" >> "$ziel_datei"
                echo -e "\n" >> "$ziel_datei"
                break
            fi
        fi
        
        echo "❌ Ungültige Eingabe. Bitte Zahl eingeben oder 'q' zum Überspringen, 'a' zum Abbrechen."
    done
}


# Auswählen und Einfügen
addPart "Kopf"
addPart "Koerper"
addPart "Beine"
addPart "Schwaenzchen"

echo -e "\n✅ Deine Anleitung wurde gespeichert in: $ziel_datei"

# Anleitung öffnen
echo -e "📖 Öffne die Anleitung im Editor ...\n"
case "$OSTYPE" in
    linux*)   xdg-open "$ziel_datei" ;;
    darwin*)  open "$ziel_datei" ;;
    msys*)    start "" "$ziel_datei" ;;
    cygwin*)  cygstart "$ziel_datei" ;;
    *)        echo "⚠️ Dein Betriebssystem wird nicht unterstützt. Öffne die Datei manuell: $ziel_datei" ;;
esac
