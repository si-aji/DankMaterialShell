// Stock theme definitions for DankMaterialShell
// Separated from Theme.qml to keep that file clean

const CatppuccinMocha = {
    surface: "#45475a",
    surfaceText: "#cdd6f4",
    surfaceVariant: "#45475a",
    surfaceVariantText: "#a6adc8",
    background: "#1e1e2e",
    backgroundText: "#cdd6f4",
    outline: "#6c7086",
    surfaceContainer: "#313244",
    surfaceContainerHigh: "#585b70"
}

const CatppuccinLatte = {
    surface: "#bcc0cc",
    surfaceText: "#4c4f69",
    surfaceVariant: "#bcc0cc",
    surfaceVariantText: "#6c6f85",
    background: "#eff1f5",
    backgroundText: "#4c4f69",
    outline: "#9ca0b0",
    surfaceContainer: "#ccd0da",
    surfaceContainerHigh: "#acb0be"
}

const CatppuccinVariants = {
    "cat-rosewater": {
        name: "Rosewater",
        dark: { primary: "#f5e0dc", secondary: "#f2cdcd", primaryText: "#1e1e2e", primaryContainer: "#8b6b5e", surfaceTint: "#f5e0dc" },
        light: { primary: "#dc8a78", secondary: "#dd7878", primaryText: "#ffffff", primaryContainer: "#f4d2ca", surfaceTint: "#dc8a78" }
    },
    "cat-flamingo": {
        name: "Flamingo",
        dark: { primary: "#f2cdcd", secondary: "#f5e0dc", primaryText: "#1e1e2e", primaryContainer: "#885d62", surfaceTint: "#f2cdcd" },
        light: { primary: "#dd7878", secondary: "#dc8a78", primaryText: "#ffffff", primaryContainer: "#f4caca", surfaceTint: "#dd7878" }
    },
    "cat-pink": {
        name: "Pink",
        dark: { primary: "#f5c2e7", secondary: "#cba6f7", primaryText: "#1e1e2e", primaryContainer: "#8b537a", surfaceTint: "#f5c2e7" },
        light: { primary: "#ea76cb", secondary: "#8839ef", primaryText: "#ffffff", primaryContainer: "#f7c9e7", surfaceTint: "#ea76cb" }
    },
    "cat-mauve": {
        name: "Mauve",
        dark: { primary: "#cba6f7", secondary: "#b4befe", primaryText: "#1e1e2e", primaryContainer: "#61378a", surfaceTint: "#cba6f7" },
        light: { primary: "#8839ef", secondary: "#7287fd", primaryText: "#ffffff", primaryContainer: "#e4d3ff", surfaceTint: "#8839ef" }
    },
    "cat-red": {
        name: "Red",
        dark: { primary: "#f38ba8", secondary: "#eba0ac", primaryText: "#1e1e2e", primaryContainer: "#891c3b", surfaceTint: "#f38ba8" },
        light: { primary: "#d20f39", secondary: "#e64553", primaryText: "#ffffff", primaryContainer: "#f1b8c4", surfaceTint: "#d20f39" }
    },
    "cat-maroon": {
        name: "Maroon",
        dark: { primary: "#eba0ac", secondary: "#f38ba8", primaryText: "#1e1e2e", primaryContainer: "#81313f", surfaceTint: "#eba0ac" },
        light: { primary: "#e64553", secondary: "#d20f39", primaryText: "#ffffff", primaryContainer: "#f4c3c8", surfaceTint: "#e64553" }
    },
    "cat-peach": {
        name: "Peach",
        dark: { primary: "#fab387", secondary: "#f9e2af", primaryText: "#1e1e2e", primaryContainer: "#90441a", surfaceTint: "#fab387" },
        light: { primary: "#fe640b", secondary: "#df8e1d", primaryText: "#ffffff", primaryContainer: "#ffddcc", surfaceTint: "#fe640b" }
    },
    "cat-yellow": {
        name: "Yellow",
        dark: { primary: "#f9e2af", secondary: "#a6e3a1", primaryText: "#1e1e2e", primaryContainer: "#8f7342", surfaceTint: "#f9e2af" },
        light: { primary: "#df8e1d", secondary: "#40a02b", primaryText: "#ffffff", primaryContainer: "#fff3cc", surfaceTint: "#df8e1d" }
    },
    "cat-green": {
        name: "Green",
        dark: { primary: "#a6e3a1", secondary: "#94e2d5", primaryText: "#1e1e2e", primaryContainer: "#3c7534", surfaceTint: "#a6e3a1" },
        light: { primary: "#40a02b", secondary: "#179299", primaryText: "#ffffff", primaryContainer: "#d4f5d4", surfaceTint: "#40a02b" }
    },
    "cat-teal": {
        name: "Teal",
        dark: { primary: "#94e2d5", secondary: "#89dceb", primaryText: "#1e1e2e", primaryContainer: "#2a7468", surfaceTint: "#94e2d5" },
        light: { primary: "#179299", secondary: "#04a5e5", primaryText: "#ffffff", primaryContainer: "#ccf2f2", surfaceTint: "#179299" }
    },
    "cat-sky": {
        name: "Sky",
        dark: { primary: "#89dceb", secondary: "#74c7ec", primaryText: "#1e1e2e", primaryContainer: "#196e7e", surfaceTint: "#89dceb" },
        light: { primary: "#04a5e5", secondary: "#209fb5", primaryText: "#ffffff", primaryContainer: "#ccebff", surfaceTint: "#04a5e5" }
    },
    "cat-sapphire": {
        name: "Sapphire",
        dark: { primary: "#74c7ec", secondary: "#89b4fa", primaryText: "#1e1e2e", primaryContainer: "#0a597f", surfaceTint: "#74c7ec" },
        light: { primary: "#209fb5", secondary: "#1e66f5", primaryText: "#ffffff", primaryContainer: "#d0f0f5", surfaceTint: "#209fb5" }
    },
    "cat-blue": {
        name: "Blue",
        dark: { primary: "#89b4fa", secondary: "#b4befe", primaryText: "#1e1e2e", primaryContainer: "#19468d", surfaceTint: "#89b4fa" },
        light: { primary: "#1e66f5", secondary: "#7287fd", primaryText: "#ffffff", primaryContainer: "#ccd9ff", surfaceTint: "#1e66f5" }
    },
    "cat-lavender": {
        name: "Lavender",
        dark: { primary: "#b4befe", secondary: "#cba6f7", primaryText: "#1e1e2e", primaryContainer: "#4a5091", surfaceTint: "#b4befe" },
        light: { primary: "#7287fd", secondary: "#8839ef", primaryText: "#ffffff", primaryContainer: "#dde1ff", surfaceTint: "#7287fd" }
    }
}

function getCatppuccinTheme(variant, isLight = false) {
    const variantData = CatppuccinVariants[variant]
    if (!variantData) return null

    const baseColors = isLight ? CatppuccinLatte : CatppuccinMocha
    const accentColors = isLight ? variantData.light : variantData.dark

    return Object.assign({
        name: `${variantData.name}${isLight ? ' Light' : ''}`
    }, baseColors, accentColors)
}

const StockThemes = {
    DARK: {
        blue: {
            name: "Blue",
            primary: "#9dcbfb",
            primaryText: "#003355",
            primaryContainer: "#124a73",
            secondary: "#b9c8da",
            surface: "#101418",
            surfaceText: "#e0e2e8",
            surfaceVariant: "#42474e",
            surfaceVariantText: "#c2c7cf",
            surfaceTint: "#9dcbfb",
            background: "#101418",
            backgroundText: "#e0e2e8",
            outline: "#8c9199",
            surfaceContainer: "#1d2024",
            surfaceContainerHigh: "#272a2f"
        },
        purple: {
            name: "Purple",
            primary: "#d0bcfe",
            primaryText: "#36265d",
            primaryContainer: "#4d3d75",
            secondary: "#ccc2db",
            surface: "#141218",
            surfaceText: "#e6e0e9",
            surfaceVariant: "#49454e",
            surfaceVariantText: "#cac4cf",
            surfaceTint: "#d0bcfe",
            background: "#141218",
            backgroundText: "#e6e0e9",
            outline: "#948f99",
            surfaceContainer: "#211f24",
            surfaceContainerHigh: "#2b292f"
        },
        green: {
            name: "Green",
            primary: "#a1d39a",
            primaryText: "#0a390f",
            primaryContainer: "#235024",
            secondary: "#baccb3",
            surface: "#10140f",
            surfaceText: "#e0e4db",
            surfaceVariant: "#424940",
            surfaceVariantText: "#c2c9bd",
            surfaceTint: "#a1d39a",
            background: "#10140f",
            backgroundText: "#e0e4db",
            outline: "#8c9388",
            surfaceContainer: "#1d211b",
            surfaceContainerHigh: "#272b25"
        },
        orange: {
            name: "Orange",
            primary: "#ffb692",
            primaryText: "#542103",
            primaryContainer: "#703717",
            secondary: "#e6beac",
            surface: "#1a120e",
            surfaceText: "#f0dfd8",
            surfaceVariant: "#52443d",
            surfaceVariantText: "#d7c2b9",
            surfaceTint: "#ffb692",
            background: "#1a120e",
            backgroundText: "#f0dfd8",
            outline: "#a08d85",
            surfaceContainer: "#271e1a",
            surfaceContainerHigh: "#322824"
        },
        red: {
            name: "Red",
            primary: "#ffb3ad",
            primaryText: "#68000a",
            primaryContainer: "#ce2029",
            secondary: "#ffb3ad",
            surface: "#1f0f0e",
            surfaceText: "#fbdbd9",
            surfaceVariant: "#5c403d",
            surfaceVariantText: "#e5bdba",
            surfaceTint: "#ffb3ad",
            background: "#1f0f0e",
            backgroundText: "#fbdbd9",
            outline: "#ac8885",
            surfaceContainer: "#2c1b1a",
            surfaceContainerHigh: "#382524",
            matugen_type: "scheme-content"
        },
        cyan: {
            name: "Cyan",
            primary: "#83d3e3",
            primaryText: "#00363e",
            primaryContainer: "#004e59",
            secondary: "#b1cbd1",
            surface: "#0e1416",
            surfaceText: "#dee3e5",
            surfaceVariant: "#3f484a",
            surfaceVariantText: "#bfc8ca",
            surfaceTint: "#83d3e3",
            background: "#0e1416",
            backgroundText: "#dee3e5",
            outline: "#899295",
            surfaceContainer: "#1b2122",
            surfaceContainerHigh: "#252b2c"
        },
        pink: {
            name: "Pink",
            primary: "#ffb0ca",
            primaryText: "#541d34",
            primaryContainer: "#6f334a",
            secondary: "#e2bdc7",
            surface: "#191114",
            surfaceText: "#efdfe2",
            surfaceVariant: "#514347",
            surfaceVariantText: "#d5c2c6",
            surfaceTint: "#ffb0ca",
            background: "#191114",
            backgroundText: "#efdfe2",
            outline: "#9e8c91",
            surfaceContainer: "#261d20",
            surfaceContainerHigh: "#31282a"
        },
        amber: {
            name: "Amber",
            primary: "#e9c16c",
            primaryText: "#3f2e00",
            primaryContainer: "#5b4300",
            secondary: "#d8c4a0",
            surface: "#17130b",
            surfaceText: "#ebe1d4",
            surfaceVariant: "#4d4639",
            surfaceVariantText: "#d0c5b4",
            surfaceTint: "#e9c16c",
            background: "#17130b",
            backgroundText: "#ebe1d4",
            outline: "#998f80",
            surfaceContainer: "#231f17",
            surfaceContainerHigh: "#2e2921"
        },
        coral: {
            name: "Coral",
            primary: "#ffb59c",
            primaryText: "#55200b",
            primaryContainer: "#72351f",
            secondary: "#e7bdb0",
            surface: "#1a110f",
            surfaceText: "#f1dfd9",
            surfaceVariant: "#53433e",
            surfaceVariantText: "#d8c2bb",
            surfaceTint: "#ffb59c",
            background: "#1a110f",
            backgroundText: "#f1dfd9",
            outline: "#a08d86",
            surfaceContainer: "#271d1a",
            surfaceContainerHigh: "#322824"
        },
        monochrome: {
            name: "Monochrome",
            primary: "#ffffff",
            primaryText: "#2b303c",
            primaryContainer: "#424753",
            secondary: "#c4c6d0",
            surface: "#2a2a2a",
            surfaceText: "#e4e2e3",
            surfaceVariant: "#474648",
            surfaceVariantText: "#c8c6c7",
            surfaceTint: "#c2c6d6",
            background: "#131315",
            backgroundText: "#e4e2e3",
            outline: "#929092",
            surfaceContainer: "#2a2a2a",
            surfaceContainerHigh: "#2a2a2b",
            matugen_type: "scheme-monochrome"
        }
    },
    LIGHT: {
        blue: {
            name: "Blue Light",
            primary: "#31628d",
            primaryText: "#ffffff",
            primaryContainer: "#cfe5ff",
            secondary: "#526070",
            surface: "#f7f9ff",
            surfaceText: "#181c20",
            surfaceVariant: "#dee3eb",
            surfaceVariantText: "#42474e",
            surfaceTint: "#31628d",
            background: "#f7f9ff",
            backgroundText: "#181c20",
            outline: "#72777f",
            surfaceContainer: "#eceef4",
            surfaceContainerHigh: "#e6e8ee"
        },
        purple: {
            name: "Purple Light",
            primary: "#66558f",
            primaryText: "#ffffff",
            primaryContainer: "#e9ddff",
            secondary: "#625b70",
            surface: "#fef7ff",
            surfaceText: "#1d1b20",
            surfaceVariant: "#e7e0eb",
            surfaceVariantText: "#49454e",
            surfaceTint: "#66558f",
            background: "#fef7ff",
            backgroundText: "#1d1b20",
            outline: "#7a757f",
            surfaceContainer: "#f2ecf4",
            surfaceContainerHigh: "#ece6ee"
        },
        green: {
            name: "Green Light",
            primary: "#3b6939",
            primaryText: "#ffffff",
            primaryContainer: "#bcf0b4",
            secondary: "#52634f",
            surface: "#f7fbf1",
            surfaceText: "#191d17",
            surfaceVariant: "#dee5d8",
            surfaceVariantText: "#424940",
            surfaceTint: "#3b6939",
            background: "#f7fbf1",
            backgroundText: "#191d17",
            outline: "#72796f",
            surfaceContainer: "#ecefe6",
            surfaceContainerHigh: "#e6e9e0"
        },
        orange: {
            name: "Orange Light",
            primary: "#8d4e2c",
            primaryText: "#ffffff",
            primaryContainer: "#ffdbcb",
            secondary: "#765849",
            surface: "#fff8f6",
            surfaceText: "#221a16",
            surfaceVariant: "#f4ded5",
            surfaceVariantText: "#52443d",
            surfaceTint: "#8d4e2c",
            background: "#fff8f6",
            backgroundText: "#221a16",
            outline: "#85736c",
            surfaceContainer: "#fceae3",
            surfaceContainerHigh: "#f6e5de"
        },
        red: {
            name: "Red Light",
            primary: "#a80017",
            primaryText: "#ffffff",
            primaryContainer: "#ce2029",
            secondary: "#a43b37",
            surface: "#fff8f7",
            surfaceText: "#281716",
            surfaceVariant: "#ffdad7",
            surfaceVariantText: "#5c403d",
            surfaceTint: "#bd0f1f",
            background: "#fff8f7",
            backgroundText: "#281716",
            outline: "#906f6c",
            surfaceContainer: "#ffe9e7",
            surfaceContainerHigh: "#ffe2df",
            matugen_type: "scheme-content"
        },
        cyan: {
            name: "Cyan Light",
            primary: "#006876",
            primaryText: "#ffffff",
            primaryContainer: "#a1efff",
            secondary: "#4a6268",
            surface: "#f5fafc",
            surfaceText: "#171d1e",
            surfaceVariant: "#dbe4e6",
            surfaceVariantText: "#3f484a",
            surfaceTint: "#006876",
            background: "#f5fafc",
            backgroundText: "#171d1e",
            outline: "#6f797b",
            surfaceContainer: "#e9eff0",
            surfaceContainerHigh: "#e3e9eb"
        },
        pink: {
            name: "Pink Light",
            primary: "#8b4a62",
            primaryText: "#ffffff",
            primaryContainer: "#ffd9e3",
            secondary: "#74565f",
            surface: "#fff8f8",
            surfaceText: "#22191c",
            surfaceVariant: "#f2dde2",
            surfaceVariantText: "#514347",
            surfaceTint: "#8b4a62",
            background: "#fff8f8",
            backgroundText: "#22191c",
            outline: "#837377",
            surfaceContainer: "#faeaed",
            surfaceContainerHigh: "#f4e4e7"
        },
        amber: {
            name: "Amber Light",
            primary: "#775a0b",
            primaryText: "#ffffff",
            primaryContainer: "#ffdf9e",
            secondary: "#6b5d3f",
            surface: "#fff8f2",
            surfaceText: "#1f1b13",
            surfaceVariant: "#ede1cf",
            surfaceVariantText: "#4d4639",
            surfaceTint: "#775a0b",
            background: "#fff8f2",
            backgroundText: "#1f1b13",
            outline: "#7f7667",
            surfaceContainer: "#f6ecdf",
            surfaceContainerHigh: "#f1e7d9"
        },
        coral: {
            name: "Coral Light",
            primary: "#8f4c34",
            primaryText: "#ffffff",
            primaryContainer: "#ffdbcf",
            secondary: "#77574c",
            surface: "#fff8f6",
            surfaceText: "#231a17",
            surfaceVariant: "#f5ded7",
            surfaceVariantText: "#53433e",
            surfaceTint: "#8f4c34",
            background: "#fff8f6",
            backgroundText: "#231a17",
            outline: "#85736d",
            surfaceContainer: "#fceae5",
            surfaceContainerHigh: "#f7e4df"
        },
        monochrome: {
            name: "Monochrome Light",
            primary: "#c2c6d6",
            primaryText: "#2b303c",
            primaryContainer: "#424753",
            secondary: "#c4c6d0",
            surface: "#131315",
            surfaceText: "#e4e2e3",
            surfaceVariant: "#474648",
            surfaceVariantText: "#c8c6c7",
            surfaceTint: "#c2c6d6",
            background: "#131315",
            backgroundText: "#e4e2e3",
            outline: "#929092",
            surfaceContainer: "#1f1f21",
            surfaceContainerHigh: "#2a2a2b",
            matugen_type: "scheme-monochrome"
        }
    }
}

const ThemeCategories = {
    GENERIC: {
        name: "Generic",
        variants: ["blue", "purple", "green", "orange", "red", "cyan", "pink", "amber", "coral", "monochrome"]
    },
    CATPPUCCIN: {
        name: "Catppuccin",
        variants: Object.keys(CatppuccinVariants)
    }
}

const ThemeNames = {
    BLUE: "blue",
    PURPLE: "purple",
    GREEN: "green",
    ORANGE: "orange",
    RED: "red",
    CYAN: "cyan",
    PINK: "pink",
    AMBER: "amber",
    CORAL: "coral",
    MONOCHROME: "monochrome",
    DYNAMIC: "dynamic"
}

function isStockTheme(themeName) {
    return Object.keys(StockThemes.DARK).includes(themeName)
}

function isCatppuccinVariant(themeName) {
    return Object.keys(CatppuccinVariants).includes(themeName)
}

function getAvailableThemes(isLight = false) {
    return isLight ? StockThemes.LIGHT : StockThemes.DARK
}

function getThemeByName(themeName, isLight = false) {
    if (isCatppuccinVariant(themeName)) {
        return getCatppuccinTheme(themeName, isLight)
    }
    const themes = getAvailableThemes(isLight)
    return themes[themeName] || themes.blue
}

function getAllThemeNames() {
    return Object.keys(StockThemes.DARK)
}

function getCatppuccinVariantNames() {
    return Object.keys(CatppuccinVariants)
}

function getThemeCategories() {
    return ThemeCategories
}