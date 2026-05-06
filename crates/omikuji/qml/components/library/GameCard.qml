import QtQuick
import "../widgets"

// dont re-declare required props here, QML rejects the redeclaration and model roles never reach the card
BaseCard {
    id: card

    readonly property string effectiveRunnerType: {
        if (runnerType === "steam") return "steam"
        if (runnerType === "flatpak") return "flatpak"
        if (runner !== "" && (runner.includes("wine") || runner.includes("Proton"))) return "wine"
        return runnerType
    }

    title: name
    imageSource: coverart || banner
    leftIconName: effectiveRunnerType === "steam"
        ? "steam"
        : (effectiveRunnerType === "wine" ? "wine_bar" : "")
    leftIconSize: 20
    clickable: true
    contextEnabled: true
}
