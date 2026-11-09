/// Découpe les octets reçus en lignes SSE et garde les lignes vides.
/// Une ligne vide ferme un événement SSE : la perdre fusionne deux événements.
/// Fins de ligne acceptées : LF, CR et CRLF, comme le demande la norme SSE.
public struct LineDecoder {
    private var buffer: [UInt8] = []
    private var isAfterCarriageReturn = false

    public init() {}

    /// Nombre d'octets reçus depuis la dernière fin de ligne.
    public var pendingByteCount: Int { buffer.count }

    /// Renvoie la ligne que cet octet termine, ou nil si la ligne continue.
    public mutating func receive(_ byte: UInt8) -> String? {
        let wasAfterCarriageReturn = isAfterCarriageReturn
        isAfterCarriageReturn = byte == 0x0D
        switch byte {
        case 0x0A where wasAfterCarriageReturn: return nil
        case 0x0A, 0x0D: return flushLine()
        default:
            buffer.append(byte)
            return nil
        }
    }

    /// Renvoie la dernière ligne quand le flux s'arrête sans fin de ligne.
    public mutating func finish() -> String? {
        isAfterCarriageReturn = false
        return buffer.isEmpty ? nil : flushLine()
    }

    private mutating func flushLine() -> String {
        let line = String(decoding: buffer, as: UTF8.self)
        buffer.removeAll(keepingCapacity: true)
        return line
    }
}
