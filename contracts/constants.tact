const MIN_TONS_FOR_STORAGE: Int = ton("0.01");
const GAS_CONSUMPTION: Int = ton("0.01");


fun gasCheckConsumption(fwdFee: Int, fwdCount: Int): Int {
    if (fwdCount <= 0) {
        fwdCount = 1;
    }
    return (fwdCount * fwdFee + 2 * GAS_CONSUMPTION) + MIN_TONS_FOR_STORAGE;
}