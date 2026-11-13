// Les échelles de couleur, développées en OKLCH par jetons.mjs : pas = 1000 × (1 − clarté), de 50 en 50.
// fabriqué depuis tokens.json par sophos/outils/jetons.mjs ; ne pas modifier à la main (patron 1.2.0).
import SwiftUI

enum DesignPrimitive {
    /// oklch(0.9506 0.0052 67.8) · Graphite chaud : texte en clair, fond et surfaces en sombre.
    static let ink50: UInt32 = 0xF1EEEB
    /// oklch(0.8990 0.0052 67.8) · Graphite chaud : texte en clair, fond et surfaces en sombre.
    static let ink100: UInt32 = 0xE0DDDA
    /// oklch(0.7999 0.0054 67.7) · Graphite chaud : texte en clair, fond et surfaces en sombre.
    static let ink200: UInt32 = 0xC0BDBA
    /// oklch(0.7009 0.0056 67.7) · Graphite chaud : texte en clair, fond et surfaces en sombre.
    static let ink300: UInt32 = 0xA19E9B
    /// oklch(0.6007 0.0051 78.3) · Graphite chaud : texte en clair, fond et surfaces en sombre.
    static let ink400: UInt32 = 0x82807D
    /// oklch(0.5005 0.0053 78.3) · Graphite chaud : texte en clair, fond et surfaces en sombre.
    static let ink500: UInt32 = 0x656360
    /// oklch(0.4002 0.0052 56.3) · Graphite chaud : texte en clair, fond et surfaces en sombre.
    static let ink600: UInt32 = 0x4A4745
    /// oklch(0.3498 0.0044 67.7) · Graphite chaud : texte en clair, fond et surfaces en sombre.
    static let ink650: UInt32 = 0x3C3A38
    /// oklch(0.2879 0.0093 67.4) · Graphite chaud : texte en clair, fond et surfaces en sombre.
    static let ink700: UInt32 = 0x2E2A26
    /// oklch(0.2492 0.0048 67.6) · Graphite chaud : texte en clair, fond et surfaces en sombre.
    static let ink750: UInt32 = 0x23211F
    /// oklch(0.1838 0.0052 67.5) · Graphite chaud : texte en clair, fond et surfaces en sombre.
    static let ink800: UInt32 = 0x141210
    /// oklch(0.0986 0.0063 72.5) · Graphite chaud : texte en clair, fond et surfaces en sombre.
    static let ink900: UInt32 = 0x040302
    /// oklch(0.9796 0.0057 84.6) · Papier et pierre : fond et surfaces en clair, texte en sombre.
    static let paper0: UInt32 = 0xFAF8F4
    /// oklch(0.9495 0.0058 84.6) · Papier et pierre : fond et surfaces en clair, texte en sombre.
    static let paper50: UInt32 = 0xF0EEEA
    /// oklch(0.9051 0.0133 82.4) · Papier et pierre : fond et surfaces en clair, texte en sombre.
    static let paper100: UInt32 = 0xE4DFD6
    /// oklch(0.7991 0.0048 78.3) · Papier et pierre : fond et surfaces en clair, texte en sombre.
    static let paper200: UInt32 = 0xBFBDBA
    /// oklch(0.6997 0.0062 84.6) · Papier et pierre : fond et surfaces en clair, texte en sombre.
    static let paper300: UInt32 = 0xA09E9A
    /// oklch(0.6004 0.0064 84.6) · Papier et pierre : fond et surfaces en clair, texte en sombre.
    static let paper400: UInt32 = 0x82807C
    /// oklch(0.5005 0.0053 78.3) · Papier et pierre : fond et surfaces en clair, texte en sombre.
    static let paper500: UInt32 = 0x656360
    /// oklch(0.3988 0.0056 78.3) · Papier et pierre : fond et surfaces en clair, texte en sombre.
    static let paper600: UInt32 = 0x494744
    /// oklch(0.3011 0.0055 91.6) · Papier et pierre : fond et surfaces en clair, texte en sombre.
    static let paper700: UInt32 = 0x2F2E2B
    /// oklch(0.2002 0.0061 91.6) · Papier et pierre : fond et surfaces en clair, texte en sombre.
    static let paper800: UInt32 = 0x171613
    /// oklch(0.0986 0.0063 72.5) · Papier et pierre : fond et surfaces en clair, texte en sombre.
    static let paper900: UInt32 = 0x040302
    /// oklch(0.9509 0.0245 26.9) · Rouge : l'erreur et la suppression ; jamais une décoration.
    static let red50: UInt32 = 0xFFE9E6
    /// oklch(0.9007 0.0516 27.0) · Rouge : l'erreur et la suppression ; jamais une décoration.
    static let red100: UInt32 = 0xFFD2CC
    /// oklch(0.8503 0.0815 27.3) · Rouge : l'erreur et la suppression ; jamais une décoration.
    static let red150: UInt32 = 0xFFBAB1
    /// oklch(0.7992 0.1149 26.4) · Rouge : l'erreur et la suppression ; jamais une décoration.
    static let red200: UInt32 = 0xFFA096
    /// oklch(0.6996 0.1705 27.0) · Rouge : l'erreur et la suppression ; jamais une décoration.
    static let red300: UInt32 = 0xF66D62
    /// oklch(0.6008 0.1706 26.9) · Rouge : l'erreur et la suppression ; jamais une décoration.
    static let red400: UInt32 = 0xD34D45
    /// oklch(0.5496 0.1706 26.9) · Rouge : l'erreur et la suppression ; jamais une décoration.
    static let red450: UInt32 = 0xC13C36
    /// oklch(0.5001 0.1712 26.9) · Rouge : l'erreur et la suppression ; jamais une décoration.
    static let red500: UInt32 = 0xB02A27
    /// oklch(0.4005 0.1632 26.9) · Rouge : l'erreur et la suppression ; jamais une décoration.
    static let red600: UInt32 = 0x8B000B
    /// oklch(0.3009 0.1226 26.8) · Rouge : l'erreur et la suppression ; jamais une décoration.
    static let red700: UInt32 = 0x5D0005
    /// oklch(0.1994 0.0814 27.5) · Rouge : l'erreur et la suppression ; jamais une décoration.
    static let red800: UInt32 = 0x320001
    /// oklch(0.0999 0.0410 29.2) · Rouge : l'erreur et la suppression ; jamais une décoration.
    static let red900: UInt32 = 0x0D0000
    /// oklch(0.9497 0.0838 149.9) · Vert : la réussite confirmée ; jamais une décoration.
    static let green50: UInt32 = 0xC7FFD1
    /// oklch(0.9005 0.1208 149.6) · Vert : la réussite confirmée ; jamais une décoration.
    static let green100: UInt32 = 0xA3F5B3
    /// oklch(0.8007 0.1213 150.0) · Vert : la réussite confirmée ; jamais une décoration.
    static let green200: UInt32 = 0x82D494
    /// oklch(0.6992 0.1204 149.7) · Vert : la réussite confirmée ; jamais une décoration.
    static let green300: UInt32 = 0x63B375
    /// oklch(0.6001 0.1207 149.9) · Vert : la réussite confirmée ; jamais une décoration.
    static let green400: UInt32 = 0x439458
    /// oklch(0.5512 0.1207 149.8) · Vert : la réussite confirmée ; jamais une décoration.
    static let green450: UInt32 = 0x33854A
    /// oklch(0.5012 0.1207 149.9) · Vert : la réussite confirmée ; jamais une décoration.
    static let green500: UInt32 = 0x21763C
    /// oklch(0.3992 0.1104 149.8) · Vert : la réussite confirmée ; jamais une décoration.
    static let green600: UInt32 = 0x005724
    /// oklch(0.3509 0.0976 149.6) · Vert : la réussite confirmée ; jamais une décoration.
    static let green650: UInt32 = 0x00481C
    /// oklch(0.3011 0.0834 149.8) · Vert : la réussite confirmée ; jamais une décoration.
    static let green700: UInt32 = 0x003915
    /// oklch(0.2015 0.0564 149.3) · Vert : la réussite confirmée ; jamais une décoration.
    static let green800: UInt32 = 0x001D07
    /// oklch(0.1005 0.0274 150.5) · Vert : la réussite confirmée ; jamais une décoration.
    static let green900: UInt32 = 0x000501
    /// oklch(0.9503 0.0363 70.0) · Ambre : l'avertissement ; jamais une décoration.
    static let amber50: UInt32 = 0xFFEBD5
    /// oklch(0.9001 0.0753 69.9) · Ambre : l'avertissement ; jamais une décoration.
    static let amber100: UInt32 = 0xFFD6A8
    /// oklch(0.8008 0.1195 70.2) · Ambre : l'avertissement ; jamais une décoration.
    static let amber200: UInt32 = 0xEFB063
    /// oklch(0.6991 0.1186 69.9) · Ambre : l'avertissement ; jamais une décoration.
    static let amber300: UInt32 = 0xCD9043
    /// oklch(0.6006 0.1192 70.1) · Ambre : l'avertissement ; jamais une décoration.
    static let amber400: UInt32 = 0xAD721E
    /// oklch(0.5502 0.1192 70.0) · Ambre : l'avertissement ; jamais une décoration.
    static let amber450: UInt32 = 0x9D6300
    /// oklch(0.4999 0.1085 69.6) · Ambre : l'avertissement ; jamais une décoration.
    static let amber500: UInt32 = 0x8A5600
    /// oklch(0.4006 0.0868 70.0) · Ambre : l'avertissement ; jamais une décoration.
    static let amber600: UInt32 = 0x653E00
    /// oklch(0.3000 0.0649 70.3) · Ambre : l'avertissement ; jamais une décoration.
    static let amber700: UInt32 = 0x422700
    /// oklch(0.1999 0.0431 70.9) · Ambre : l'avertissement ; jamais une décoration.
    static let amber800: UInt32 = 0x221200
    /// oklch(0.0977 0.0227 60.9) · Ambre : l'avertissement ; jamais une décoration.
    static let amber900: UInt32 = 0x070200
    /// oklch(0.9506 0.0240 253.9) · Bleu Graker : accent, focus et information (nuances distinctes via les rôles).
    static let blue50: UInt32 = 0xE4F0FF
    /// oklch(0.8989 0.0499 254.9) · Bleu Graker : accent, focus et information (nuances distinctes via les rôles).
    static let blue100: UInt32 = 0xC8E0FF
    /// oklch(0.7998 0.1027 254.7) · Bleu Graker : accent, focus et information (nuances distinctes via les rôles).
    static let blue200: UInt32 = 0x90C1FF
    /// oklch(0.6980 0.1252 249.1) · Bleu Graker : accent, focus et information (nuances distinctes via les rôles).
    static let blue300: UInt32 = 0x5BA3E8
    /// oklch(0.6026 0.1467 254.5) · Bleu Graker : accent, focus et information (nuances distinctes via les rôles).
    static let blue400: UInt32 = 0x3B82D6
    /// oklch(0.5010 0.1463 254.4) · Bleu Graker : accent, focus et information (nuances distinctes via les rôles).
    static let blue500: UInt32 = 0x1863B4
    /// oklch(0.3993 0.1301 254.7) · Bleu Graker : accent, focus et information (nuances distinctes via les rôles).
    static let blue600: UInt32 = 0x00468B
    /// oklch(0.3007 0.0974 254.5) · Bleu Graker : accent, focus et information (nuances distinctes via les rôles).
    static let blue700: UInt32 = 0x002D5D
    /// oklch(0.1985 0.0650 254.8) · Bleu Graker : accent, focus et information (nuances distinctes via les rôles).
    static let blue800: UInt32 = 0x001532
    /// oklch(0.0988 0.0330 255.4) · Bleu Graker : accent, focus et information (nuances distinctes via les rôles).
    static let blue900: UInt32 = 0x00030D
}
