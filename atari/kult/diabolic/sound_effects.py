"""Space-shooter instruments for the original four-channel POKEY driver.

Keep every sequence in its original allocation, including its FF terminator.
Volume loops end on silence; no change to driver timing or channel ownership.
"""
INSTRUMENTS = {
    # id: distortion, pitch offsets, volume envelope
    0: (0x80, [110, 18, 160, 52, 210], [12, 8, 6, 3, 0]),  # metallic impact
    2: (0xA0, [40, 40, 16, 16, 28, 28, 8, 8, 20, 20, 4, 4, 1, 1, 1, 1],
        [8, 6, 4, 3, 8, 6, 4, 3, 6, 5, 4, 3, 2, 1, 1, 0]),  # pickup arpeggio
    3: (0x80, [180, 24, 220, 65, 150, 100],
        [13, 10, 8, 12, 9, 7, 10, 8, 6, 8, 6, 5, 6, 5, 4, 5, 4, 3, 4, 3, 2, 3, 2, 2, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0]),
    4: (0xA0, [26, 3, 12, 38, 90], [8, 6, 4, 2, 1, 0, 0, 0, 0, 0, 0]),  # short laser
}

def patches(ram):
    result = {}
    def put(address, values):
        values = bytes(values)
        result[address] = (bytes(ram[address:address+len(values)]).hex(), values.hex())
    for instrument, (distortion, pitch, volume) in INSTRUMENTS.items():
        for table, values in ((0xF636, pitch), (0xF640, volume)):
            pointer = int.from_bytes(ram[table+instrument*2:table+instrument*2+2], 'little')
            assert ram[pointer+len(values)] == 255
            put(pointer, values)
        put(0xF64A+instrument, [distortion])
    put(0xF64F, [4])  # Impact decays to silence instead of looping audibly.
    put(0xFA86, [0])  # Enemy hit uses its own metallic impact instrument.
    put(0xFA88, [16])
    put(0xF391, [3])  # Bomb uses the noise-burst instrument, not the laser.
    put(0xF393, [28])
    return result
