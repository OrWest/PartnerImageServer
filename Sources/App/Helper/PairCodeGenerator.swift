struct PairCodeGenerator {
    private static let letterLength = 4
    private static let numberLength = 4
    private static let separator = "-"
    
    static func generateCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let lettersCode = String((0..<letterLength).map{ _ in letters.randomElement()! })
        let numbersCode = (0..<numberLength).map{ _ in String(Int.random(in: 0..<10)) }.reduce("") { $0 + $1 }

        return lettersCode + separator + numbersCode
    }
}